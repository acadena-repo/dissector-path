//! Wireglass core library.
//!
//! State S0: empty scaffold. Tutorials 01-04 add `hexdump`, `Reader`,
//! `ParseError`, and the first Ethernet/IPv4 parsers here.

// Tests may use unwrap/expect/indexing for brevity; library code may not.
#![cfg_attr(
    test,
    allow(clippy::unwrap_used, clippy::expect_used, clippy::indexing_slicing)
)]

/// Crate version, taken from Cargo metadata.
pub const VERSION: &str = env!("CARGO_PKG_VERSION");

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn version_is_set() {
        assert!(!VERSION.is_empty());
    }
}
