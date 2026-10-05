We use 'bunyan' CLI to prettify the logs.
Install Rust-port with `cargo install bunyan`

Test by running `$env:TEST_LOG = "true"; cargo test | bunyan` 

or `$env:TEST_LOG = "true"; cargo test health_check_wor ks | bunyan`