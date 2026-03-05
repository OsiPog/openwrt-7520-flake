{
  description = "Simple flake with a devshell";

  # Add all your dependencies here
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    blueprint.url = "github:osipog/blueprint/feat/allow-nixpkgs-package-definitions";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";

    openwrt = {
      url = "github:openwrt/openwrt";
      flake = false;
    };
  };

  # Load the blueprint
  outputs = inputs: inputs.blueprint {inherit inputs;};
}
