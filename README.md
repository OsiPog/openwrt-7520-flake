# Installing OpenWrt on AVM Fritz!Box 7520 from a NixOS host

*Guide from https://openwrt.org/toh/avm/avm_fritz_box_7530#installation adapted to NixOS*

1. `nix develop` (or automatically with direnv)
    - adds necessary tools to path and downloads the uboot image for the 7520
2. Change IP address on ethernet port:
    1. find your ethernet port name: `ip link show` (for me it was `enp0s20f0u1u4`)
    2. change ip address on it: `sudo ip addr add 192.168.178.10/24 dev <ethernet port name>`

3. connect the fritz box to your ethernet port (use one of the yellow ports)

4. load uboot onto the router:
    1. In another terminal, start: `bash -c 'while true; do ip link show; usleep 500; done'` to see the state of your ethernet interface
    2. connect power to the router
    3. when you see 'UP' next to your ethernet interface in the other terminal run `eva_ramboot --offset 0x85000000 --ip 192.168.178.1 --image uboot-fritz7520.bin`

5. Assign yourself ip address 192.168.1.70/24 (like in step 2)
    - use `sudo ip addr del 192.168.178.10/24 dev <interface>` to remove the previous pre-uboot address

6. Download the "KERNEL" firmware file for the router at `https://firmware-selector.openwrt.org/` put it in this directory and rename it to `FRITZ7520.bin`

7. Start the TFTP server:
    1. (temporarily) open UDP port 69 (`networking.firewall.allowedUDPPorts = [69];` in your configuration.nix)
    2. in another terminal with the same working directory, start the TFTP server with `sudo tftpd -i 0.0.0.0`

8. Wait until you see `Sent FRITZ7520.bin to 192.168.1.1:1495`. Then stop the TFTP server.

9. Wait some time until the router booted into OpenWrt
    - you know that it booted when you can ssh into the router with: `ssh root@192.168.1.1`

10. Copy the uboot image and the "SYSUPGRADE" from https://firmware-selector.openwrt.org/ file to the router via SCP:
    ```bash
    scp -O uboot-fritz7520.bin root@192.168.1.1:/tmp/
    scp -O /path/to/sysupgrade.bin root@192.168.1.1:/tmp/
    ```
11. install OpenWrt via SSH with the uploaded files. use `ssh root@192.168.1.1` to log in
    1. write the uboot image to to the correct partitions
     ```
     mtd write /tmp/uboot-fritz7520.bin uboot0
     mtd write /tmp/uboot-fritz7520.bin uboot1
     ```
    2. remove the AVM filesystem partitions
     ```
     ubirmvol /dev/ubi0 --name=avm_filesys_0
     ubirmvol /dev/ubi0 --name=avm_filesys_1
     ```
    3. flash openwrt
     ```
     sysupgrade -n /tmp/<previously downloaded sysupgrade.bin>
     ```
