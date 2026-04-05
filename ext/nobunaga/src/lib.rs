//! Nobunaga native extension: Prism parse + Lint cops (AST).

#![deny(unsafe_op_in_unsafe_fn)]

use magnus::{function, prelude::*, Error, RArray, RHash, Ruby};
use ruby_prism::{visit_call_node, CallNode, ConstantReadNode, Node, Visit};

fn offset_to_line_col(source: &[u8], offset: usize) -> (i32, i32) {
    let offset = offset.min(source.len());
    let prefix = &source[..offset];
    let line = prefix.iter().filter(|&&b| b == b'\n').count() as i32 + 1;
    let line_start = prefix
        .iter()
        .rposition(|&b| b == b'\n')
        .map_or(0, |i| i + 1);
    let col = (offset - line_start) as i32 + 1;
    (line, col)
}

fn offense_hash(
    ruby: &Ruby,
    path: &str,
    line: i32,
    column: i32,
    message: &str,
    rule_id: &str,
) -> Result<RHash, Error> {
    let h = ruby.hash_new();
    h.aset(ruby.to_symbol("path"), path)?;
    h.aset(ruby.to_symbol("line"), line)?;
    h.aset(ruby.to_symbol("column"), column)?;
    h.aset(ruby.to_symbol("message"), message)?;
    h.aset(ruby.to_symbol("rule_id"), rule_id)?;
    h.aset(ruby.to_symbol("corrections"), ruby.ary_new())?;
    Ok(h)
}

fn is_bigdecimal_root<'pr>(node: &'pr Node<'pr>) -> Option<ConstantReadNode<'pr>> {
    let c = node.as_constant_read_node()?;
    (c.name().as_slice() == b"BigDecimal").then_some(c)
}

#[derive(Default)]
struct NativeLintVisitor {
    bigdecimal_hits: Vec<usize>,
    /// (start_byte, message)
    debugger_hits: Vec<(usize, String)>,
}

impl<'pr> Visit<'pr> for NativeLintVisitor {
    fn visit_call_node(&mut self, node: &CallNode<'pr>) {
        // Lint/Debugger — subset of RuboCop defaults: `debugger`, `binding.pry`
        if node.name().as_slice() == b"debugger" && node.receiver().is_none() {
            let loc = node.location();
            let snippet = std::str::from_utf8(loc.as_slice()).unwrap_or("debugger");
            self.debugger_hits.push((
                loc.start_offset(),
                format!("Remove debugger entry point `{snippet}`."),
            ));
        } else if node.name().as_slice() == b"pry" {
            if let Some(recv) = node.receiver() {
                if let Some(inner) = recv.as_call_node() {
                    if inner.receiver().is_none() && inner.name().as_slice() == b"binding" {
                        let loc = node.location();
                        let snippet = std::str::from_utf8(loc.as_slice()).unwrap_or("binding.pry");
                        self.debugger_hits.push((
                            loc.start_offset(),
                            format!("Remove debugger entry point `{snippet}`."),
                        ));
                    }
                }
            }
        }

        // Lint/BigDecimalNew
        if node.call_operator_loc().is_some() {
            if let Some(recv) = node.receiver() {
                if let Some(cread) = is_bigdecimal_root(&recv) {
                    if node.name().as_slice() == b"new" {
                        self.bigdecimal_hits.push(cread.location().start_offset());
                    }
                }
            }
        }

        visit_call_node(self, node);
    }
}

fn collect_offenses(path: String, source: String) -> Result<RArray, Error> {
    let ruby = Ruby::get().unwrap();
    let bytes = source.as_bytes();
    let parsed = ruby_prism::parse(bytes);

    let mut rows: Vec<RHash> = Vec::new();

    for diag in parsed.errors() {
        let start = diag.location().start_offset();
        let (line, col) = offset_to_line_col(bytes, start);
        rows.push(offense_hash(
            &ruby,
            &path,
            line,
            col,
            diag.message(),
            "Syntax/PrismParseError",
        )?);
    }

    let mut visitor = NativeLintVisitor::default();
    visitor.visit(&parsed.node());

    for off in visitor.debugger_hits {
        let (line, col) = offset_to_line_col(bytes, off.0);
        rows.push(offense_hash(
            &ruby,
            &path,
            line,
            col,
            &off.1,
            "Lint/Debugger",
        )?);
    }

    for off in visitor.bigdecimal_hits {
        let (line, col) = offset_to_line_col(bytes, off);
        rows.push(offense_hash(
            &ruby,
            &path,
            line,
            col,
            "Use `BigDecimal()` instead of `BigDecimal.new`.",
            "Lint/BigDecimalNew",
        )?);
    }

    drop(parsed);

    let arr = ruby.ary_new();
    for h in rows {
        arr.push(h)?;
    }
    Ok(arr)
}

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    let nobunaga = ruby.define_module("Nobunaga")?;
    let native = nobunaga.define_module("Native")?;
    native.define_singleton_method("inspect_source", function!(collect_offenses, 2))?;
    Ok(())
}
