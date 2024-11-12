use lib_flutter_rust_bridge_codegen::codegen;
use lib_flutter_rust_bridge_codegen::codegen::Config;
use lib_flutter_rust_bridge_codegen::utils::logs::configure_opinionated_logging;

fn main() -> anyhow::Result<()> {
    // configure_opinionated_logging("./logs/", true)?;

    // codegen::generate(
    //     Config::from_config_file("../flutter_rust_bridge.yaml")?.unwrap(),
    //     Default::default(),
    // )
    Ok(())
}
