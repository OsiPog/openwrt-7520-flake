{
  pkgs,
  flake,
}:
pkgs.mkShell {
  # Add build dependencies
  packages = with pkgs; [
    (writeShellApplication {
      name = "eva_ramboot";
      runtimeInputs = [pkgs.python3];
      text = ''
        python ${flake.inputs.openwrt}/scripts/flashing/eva_ramboot.py "$@"
      '';
    })

    rs-tftpd
  ];

  # Add environment variables
  env = {};

  # Load custom bash code
  shellHook = ''
    curl https://downloads.openwrt.org/snapshots/targets/ipq40xx/generic/u-boot-fritz7520/uboot-fritz7520.bin -o uboot-fritz7520.bin
  '';
}
