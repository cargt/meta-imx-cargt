# i.MX 95 00414 OSM-L SOM bring-up (wrynose)

Living TODO / test checklist for `imx95-cargt-00414-00365` (primary),
`imx95-cargt-00414-00428` and `imx95-cargt-00414-osm-som`. Check items off in the same commit that closes them.

Sources used:
- 00414 SOM schematic `014-00414-00.PDF` (rev 00). A rev 01 Altium project also exists.
- 00365 carrier schematic `00365.pdf` (rev 05).
- 00428 carrier schematic `014-00428-00.PDF` (rev 01, "Locker Display").
- 00363 SOM schematic `014-00363-FE.PDF` (rev 04). Used to translate the
  00363-00365 and 00363-00428 device trees by OSM-L signal name.
- NXP 19x19 LPDDR5 EVK (`imx95-19x19-lpddr5-evk`, lf-6.18.20_2.0.0). Used as the
  SoC-level reference.

## Boot chain and where the 00414 support lives

| Stage | Runs on | Cargt 00414 support |
|---|---|---|
| OEI (DDR init) | M33 | `recipes-bsp/imx-oei`: board `cargt00414` (copy of `mx95lp5` + patch, debug UART on LPUART1), DDR Tool timing for MT62F512M32D2DR (2 GB, 6400 MT/s, FW2024.09). SOM settings in `conf/machine/include/imx95-cargt-00414.inc` |
| System Manager | M33 | `recipes-bsp/imx-system-manager`: board `cargt00414` (copy of `mcimx95evk` + optional-device patch), config `mx95cargt00414.cfg` |
| SPL / ATF / OP-TEE / U-Boot | A55 | `u-boot-imx` patch 0030 (`board/cargt/imx95_00414`), `files/dts/imx95-cargt-00414-*`, `files/configs/imx95-cargt-00414-*_defconfig` |
| Linux | A55 | `files/dts/freescale/imx95-cargt-00414-*.dts`, `cargt_00414_kernel_config_mods.cfg` |

`IMXBOOT_TARGETS = "flash_a55"`: A55-only container, no M7 image.

## Build verification

- [x] Kernel DTBs compile with `dtc`. Checked outside bitbake against the lf-6.18.20 tree.
- [x] U-Boot builds for all three defconfigs (00365, 00428, osm-som). Checked outside bitbake with the Yocto aarch64 cross-compiler.
- [x] System Manager builds with `CONFIG=mx95cargt00414`. Checked outside bitbake with arm-none-eabi 13.2.
- [x] `bitbake -e` parse check (imx95-cargt-00414-00365)
- [x] `bitbake virtual/kernel`, `u-boot-imx`, `imx-system-manager`, `imx-oei`, `imx-boot` (imx95-cargt-00414-00365, via `cargt-image-dev-swu`, 2026-09-28)
- [x] `bitbake cargt-image-dev-swu` (imx95-cargt-00414-00365, 2026-09-28)
- [ ] Image build for imx95-cargt-00414-osm-som
- [ ] Image build for imx95-cargt-00414-00428

## Hardware bring-up checklist

- [x] Serial download (BOOT_MODE 01) with `uuu` (2026-10-08). `uuu imx-boot` and the built-in scripts stop after the ROM stage on i.MX 95 and skip the SPL (SDPV) stage, so use an explicit script: `SDPS: boot -f imx-boot`, then `SDPV: write -f imx-boot -skipspl`, `SDPV: jump`. Expected on the console (LPUART1): OEI DDR training output, then SPL. The SM banner "Cargt 00414 SOM" goes to LPUART2 (open item 4).
- [x] DDR Tool training and stress test pass at 6400 MT/s, 2 GB (MT62F512M32D2DR, one board, room temperature, 2026-10-07)
- [ ] DDR margins (PHY diagnostic/eye margin at 6400), long stress run, hot test, 3-5 boards
- [x] OEI with the exported timing trains DDR from `imx-boot` (err = 0, about 2.5 s) and U-Boot reports 1.75 GB at 0x90000000. That is 2 GB minus the 256 MB secure region (2026-10-08).
- [x] SM (`cargt00414` board port) and ELE 2.0.6 boot; BL31 and U-Boot run (2026-10-08)
- [x] U-Boot prompt; `mmc list` shows eMMC (mmc0, HS400ES 200 MHz, 8-bit, 29.1 GiB) and microSD (mmc1, card detect reports no card) (2026-10-08)
- [x] eMMC boot (BOOT_MODE 10): OEI → SM → SPL → BL31/OP-TEE → U-Boot → `bsp_bootcmd` (2026-10-08)
- [x] SD boot (BOOT_MODE 11), 2026-10-09, `cargt-image-ate` written with `bmaptool copy`: OEI → SM → SPL ("Trying to boot from MMC2") → U-Boot → kernel with root on mmcblk1p1. U-Boot keeps its environment on the boot MMC (MMC(1) when booted from SD), but the machine's `fw_env.config` always names mmcblk0 (eMMC), so `fw_printenv`/`fw_setenv` use the wrong copy after an SD boot. Fixed: the 00414 machines now set the `fw-env-bootdev` machine feature (wrynose 9498f54), so `/etc/fw_env.config` follows `root=`. [ ] Re-check `fw_printenv` after an SD boot and an eMMC boot.
- [x] Kernel boot to rootfs from eMMC (`cargt-image-dev`, login on ttyLP0, 2026-10-08). Expected failures in that boot: Weston (no display DT yet). The NXP Wi-Fi/BT services failed too; they are now only installed when MACHINE_FEATURES has `wifi`/`bluetooth`, which the 00414 does not.
- [ ] Software updates by `.swu` from microSD until Ethernet works: copy `cargt-image-<type>-swu-<machine>.rootfs.swu` to the card, then on the target `swupdate -v -i /run/media/<card>/<file>.swu` and reboot.
- [ ] `i2cdetect` on I2C_A (lpi2c2): 0x20 (TCA9555), 0x51 (PTN5110 USB_A), 0x52 (PTN5110 USB_C)
- [ ] ETH_A (enetc_port0, NETC EMDIO): link and ping, in U-Boot and Linux. Linux done (2026-10-08): 1 Gb/s, iperf3 941 Mb/s each way and 940 + 940 Mb/s bidirectional, UDP 950 Mb/s with 0 loss into the board, 0 RX/TX/CRC/FIFO errors. U-Boot not tested.
- [ ] ETH_B (enetc_port1, bit-banged MDIO): link and ping, in U-Boot and Linux. Linux done (2026-10-08): same iperf3 results as ETH_A, 0 errors; both ports at once limited only by the host's single 1 Gb/s NIC. U-Boot not tested. The PHY (RTL8211F at address 0) answers on the bit-banged bus in U-Boot (`mdio list`), and so does the ETH_A PHY on NETC EMDIO (2026-10-08).
- [ ] I2C_A (lpi2c2) in U-Boot: `i2c: Error check busy bus: 0x8`, and the pca953x at 0x20 cannot be read. Linux (`i2c-1`) fails the same way: pca953x 1-0020, tcpci 1-0051 and 1-0052 all time out (-110). Intermittent, not a hard fault (2026-10-08): with no hardware change, later boots work, 3000 back-to-back reads had 0 errors, and 10/10 warm reboots probed all three devices in both U-Boot and Linux. Both failures followed USB serial-download (uuu) sessions, so the suspect is a device left holding the bus across a reset; there is no bus recovery (the I2C2 pads' GPIO is GPIO1, owned by the SM). Still to test: cold power-up, and `i2c probe` in U-Boot right after a uuu load. The I2C_A/I2C_B pull-ups are present (an earlier note here saying they were missing was wrong). No recurrence since the bench supply's current limit was raised to 2 A, so the bus failures were most likely caused by supply over-current trips. Knock-on effects when it fails: both USB-C ports (no TCPC, no SS mux) and, before the workaround below, both Ethernet ports.
- [ ] Restore the 00365 PHY `reset-gpios` (pca9555 P00/P01) in the kernel DT once I2C_A works. They are commented out because an unprobed pca9555 kept both PHYs from registering (`net eth0/eth1: could not attach to PHY`); the resets are released by pull-ups when undriven.
- [ ] `ci_hdrc ci_hdrc.0: Aliasing StreamID 0xf (from 4c200000.usb) unsupported, expect DMA to be broken` on usb2: check once USB_A can be exercised.
- [ ] USB-C(A), OSM USB_A (usb2, high-speed only): host and device role switching
- [x] USB-C(C), OSM USB_C (usb3): host role and SuperSpeed in both plug orientations (2026-10-08). RTS5411 USB 3 hub + drive at 5000M with the plug either way (CBTU02043 select low = normal, high = reverse), 122 MB/s direct read. Device role and PD not tested yet.
  - The 00414 routes only USB1_TX0/RX0; TX1/RX1 are unconnected and orientation is done by the carrier's external mux, as the OSM spec expects. The i.MX 95 PHY's internal Type-C lane mux (TCA) must stay at FLIP = 0 (TX0/RX0); FLIP = 1 leaves the SS port in RxDetect. It does: the PHY is not in the connector's graph (the SS endpoint goes to `usb-c-ss-mux`), so nothing changes its orientation from the driver default.
  - SuperSpeed first came up only after a USB 2.0 reset: with `role-switch-default-mode = "peripheral"` the xHCI/PHY started after VBUS and the device had already fallen back to high speed. Fixed by defaulting the controller to host.
  - Test: plug a USB 3 device each way, `lsusb -t` shows it on bus 2 at 5000M, `cat /sys/class/typec/port1/orientation`, and `dd if=/dev/sda of=/dev/null bs=1M count=1024 iflag=direct` > 100 MB/s. Use a SuperSpeed-rated cable/adapter.
- [x] microSD card detect and read/write (2026-10-08, MB33A 32 GB): 3 loops of 1 GiB large-file and 2000 x 64 KiB small-file write + sha256 verify after a cache drop, 0 failures, no mmc errors; about 19 MB/s write, 17 MB/s read. Limited on purpose to 3.3 V high-speed (50 MHz, about 20 MB/s) with `no-1-8-v`, as on the 00363-00365, because of signal integrity problems on the 00365 at UHS-I rates. Do not remove it to gain speed.
- [x] CAN_A (flexcan1) and CAN_B (flexcan3) loopback between the two ports (2026-10-08, loopback cable): 20,000 frames each way and both ways at once at 250 k, 500 k and 1 Mbit/s, back to back, 0 lost or out of order, 0 bus errors, both ERROR-ACTIVE throughout. Note can0 = flexcan3 = CAN_B and can1 = flexcan1 = CAN_A.
- [ ] UART_B (lpuart5, MikroBus) and UART_C (lpuart6)
- [ ] ADC (adc1) readings
- [ ] PMIC and SoC thermal zones in `/sys/class/thermal` (SCMI sensors)
- [ ] Watchdog reset (wdog3 → WDOG_ANY → PF09)

- [x] OS08A20 camera on CSI-1 (J21, MIPI CSI0) and on CSI-2 (J22, OSM CSI_B), streaming 1920x1080 full screen through the NEO ISP (2026-10-08). Needs `LIBCAMERA_PIPELINES_MATCH_LIST=nxp/neo`, otherwise libcamera picks the raw-only imx8-isi handler: `LIBCAMERA_PIPELINES_MATCH_LIST=nxp/neo gst-launch-1.0 libcamerasrc ! video/x-raw,width=1920,height=1080 ! queue ! waylandsink fullscreen=true`. CSI-2 uses `imx95-cargt-00414-00365-glt1011280800is1-csi2.dtb`: OSM CSI_B is the combo PHY (MIPI CSI1) behind the TMUX646 shared with DSI, set to CSI with CSI_nDSI_SEL low, so CSI-2 and the DSI display cannot be used together.
- [ ] PCIe (OSM PCIe_A = PCIE1/pcie0, J4, NVMe on an M.2 adapter): root port up, but "Phy link never came up"; LTSSM cycles DETECT_QUIET/DETECT_ACT (no receiver detected on our TX pair), also at Gen1 with PCIE_PWR_EN on from boot. Check NVMe 3.3 V, TX/RX mapping SOM → J4 → adapter, and the 100 MHz refclk.

### 00428 carrier

- [ ] Recovery/flash path. On the 00414, OSM USB_C is the i.MX 95 USB1 (USB 3.0) controller, and that is likely the ROM serial-download port. On the 00428, USB_C is a host-only port with a VBUS enable. On the 00363 the ROM used USB1 = OSM USB_A, the 00428's USB-C connector. Confirm which port `uuu` serial download works on; SD or eMMC flashing may be needed instead.
- [ ] `i2cdetect` on I2C_A (lpi2c2): 0x51 (PTN5110 USB_A)
- [ ] ETH_A (enetc_port0, NETC EMDIO, reset on GPIO_IO09): link and ping, in U-Boot and Linux
- [ ] USB-C, OSM USB_A (usb2): role switching, plus U-Boot fastboot (`usb_gadget0`)
- [ ] OSM USB_C (usb3) host with VBUS (GPIO_IO15)
- [ ] UART_B (lpuart5, MikroBus)
- [ ] `/data` mounted from `LABEL=data` (base-files fstab)

## PREEMPT_RT (NXP Real-time Edge 3.5)

Distro `cargt-imx-rt`, image `cargt-image-rt` / `cargt-image-rt-swu` (00414-00365 only so far). Built in its own build directory, because adding `meta-real-time-edge` also patches ATF, imx-mkimage, linuxptp, iproute2 and lldpd for every machine:

```
cd <BSP directory>   # the repo checkout that holds imx-cargt-setup.sh
DISTRO=cargt-imx-rt MACHINE=imx95-cargt-00414-00365 source imx-cargt-setup.sh -b build-rt
bitbake cargt-image-rt-swu
```

- Kernel: NXP `real-time-edge-linux` `linux_6.18.20` (lf-6.18.20 plus PREEMPT_RT, TSN and DSA), pinned by meta-real-time-edge. All Cargt kernel patches, dts and config fragments apply on top unchanged. `imx_v8_defconfig` in that tree sets `CONFIG_PREEMPT_RT=y`, and `cargt_rt_kernel_config_mods.cfg` repeats it so that the config audit warns if it is ever dropped.
- U-Boot, OEI and System Manager are the Cargt BSP ones (`mx95cargt00414`), the same as in `cargt-imx-xwayland`. The distro uses its own `cargt-rt` override, not NXP's `real-time-edge`. Under that override, meta-real-time-edge replaces the whole linux-imx and u-boot-imx `SRC_URI`, which drops every Cargt patch and dts. It also switches to `real-time-edge-uboot` and the EVK `mx95rte` SM config.
- Userspace: cargt-image-dev plus the RTE networking (linuxptp, tsntool, isochron, rt-tests), industrial (IgH EtherCAT on ENETC, open62541, Modbus), system and tools (rteval) packagegroups. `packagegroup-real-time-edge-rtos` (EVK M-core demos) is left out.
- Not taken from RTE yet: SM patch `0001-devices-MIMX95-Disable-DDR-Auto-Clock-Gating` (gated on `real-time-edge`). It reduces DDR wake-up latency spikes. If the cyclictest worst case shows them, consider adding it to the Cargt SM bbappend.

- [x] `bitbake cargt-image-rt-swu` (imx95-cargt-00414-00365, 2026-10-15). The kernel is `6.18.20-rt4`, and the built `.config` has `CONFIG_PREEMPT_RT=y` as well as the 00414 options (`CONFIG_I2C_CARGT_SM_EEPROM`, `CONFIG_MDIO_GPIO`).
- [ ] Boots; `uname -a` shows `PREEMPT_RT`, and `/sys/kernel/realtime` is 1
- [ ] `cyclictest -m -S -p 98 -i 1000 -D 1h` under `stress-ng` load: record max latency
- [ ] ETH_A/ETH_B PTP (`ptp4l`) and EtherCAT master on ENETC

## Interim MAC addresses (until the eFuses are programmed)

The MAC fuses are blank and the SOM EEPROM is on the SM-owned LPI2C1, so
U-Boot (`CONFIG_NET_RANDOM_ETHADDR`) and Linux both pick a random MAC every
boot, and every boot gets a new DHCP lease. Until the eFuses are burned, set
`ethaddr`/`eth1addr` in the U-Boot environment. U-Boot uses them and passes
them to Linux as `local-mac-address` through the kernel DT `ethernet0`/
`ethernet1` aliases (`fdt_fixup_ethernet`), and the ENETC driver uses that
address instead of a random one.

Locally administered addresses derived from the SoC unique ID, so they are
stable and differ per board. Run once per board, from Linux, then reboot:

```
uid=$(cat /sys/devices/soc0/serial_number)
h=$(printf %s "$uid" | sha256sum | cut -c1-8)
base="02:${h:0:2}:${h:2:2}:${h:4:2}:${h:6:2}"
fw_setenv ethaddr  "${base}:00"   # ETH_A, enetc_port0, eth0
fw_setenv eth1addr "${base}:01"   # ETH_B, enetc_port1, eth1
fw_printenv ethaddr eth1addr
```

Remove with `fw_setenv ethaddr; fw_setenv eth1addr` once real MACs are fused.

- [ ] Program the MAC eFuses, then drop the env overrides

## Open items / TODO

1. **DDR parts and EEPROM-based selection.** i.MX 95 trains DDR in OEI on the M33, before the SM and SPL, so the i.MX 93 SPL selection (`cargt_eeprom`) does not apply. Branch `feature/imx95-00414-multi-ddr` builds every 00414 DDR configuration into one OEI and picks one from the SOM EEPROM.
   - [x] One image for every 00414 DDR fit. OEI reads the DDR configuration ID from the SOM EEPROM (M24C02 at 0x50 on LPI2C1) before the SM claims the bus, with a minimal polling LPI2C driver that leaves the controller reset and its clock root as found (imx-oei patches 0001/0002). The driver and the absent-EEPROM fallback were tested on an FRDM-IMX95 (2026-10-09); the 00414 EEPROM read is not tested on hardware yet.
   - [x] Space: the configurations share the trained-CSR list (same registers, all values 0) and the PIE table, and each configuration carries a small {index, value} PIE patch (9 entries for the 2 GB part). `scripts/cargt_ddr_merge.py` (patch 0003) does this at build time and checks that each configuration reproduces its original tables. OEI with both configurations is 110 KB (DEBUG=1); with the 221 KB of firmware about 35 KB of the 356 KB remain, roughly 5-6 KB per additional configuration.
   - [x] EEPROM layout: Cargt EEPROM record version 3 adds `ddr_cfg_id` at offset 38 (ate_pc `BuildEeprom`). Version 2 and older records are matched by size and rank count. Blank, invalid or unreadable EEPROM: OEI tries every configuration in list order, 2-rank first, since a 1-rank configuration can train on a 2-rank part and expose only half of it. Saved QuickBoot data is only used for the configuration the EEPROM names.
   - Configurations (`boards/cargt00414/ddr/cargt_ddr_cfgs.c`, generated from the 00414 DDR Tool project so they share the 00414 CA/DQ mapping):

     | ID | Part | Organization | Status |
     |---|---|---|---|
     | 2 | MT62F4G32D8DV-023 (LPDDR5X, 16 GB) | 2 rank, x8 byte mode, 6400 | Not validated on hardware: checked against the Micron Y42M datasheet and the NXP 19x19 LPDDR5 EVK table (same organization; identical message block) |
     | 1 | MT62F512M32D2DR-031 WT:B (2 GB) | 1 rank, x16, 6400 | DDR Tool training + stress at 6400 (2026-10-07) |
   - [x] Multi-DDR OEI on a 00414 with a blank EEPROM (2026-10-09, SD boot): `EEPROM blank or not a Cargt record` (LPI2C1 read OK, the M24C02 answers but is unprogrammed), bootstrap tried cfg 2 (16 GB) which failed in under a second, then cfg 1 (2 GB) trained in 2.54 s; the SM then took LPI2C1 for the PMICs and booted normally. U-Boot: DRAM 1.8 GiB; Linux MemTotal 1703 MB.
   - [ ] Boot `imx-boot` on a 00414 with a programmed EEPROM: expect `DDR OEI: cargt: EEPROM v3 ... -> cfg id 0x01` and `using cfg 1` on LPUART1, no bootstrap.
   - [ ] 16 GB part on hardware: training, stress, margins (needs a board with MT62F4G32D8DV).
   - [ ] Spread spectrum on/off at 6400 for each part during prototype validation (decide before EMC testing).
2. **LPI2C1 is owned by the SM.** The RX8111 RTC (0x32) and the M24C02 EEPROM (0x50) share the bus with the PMICs.
   - [ ] RTC: add an RX8111 board RTC to the `cargt00414` SM port, exposed to Linux over SCMI BBM, in place of the EVK PCA2131. Until then only the SoC BBM RTC is available.
   - [ ] EEPROM (serial number, MAC): expose it through SM board controls (SCMI misc) or read it in OEI. Otherwise move it off LPI2C1 in a SOM respin.
3. **PF09 interrupt.** On the EVK it is routed through the PCAL6408A; on the 00414 it goes to GPIO_IO35 and is not handled by the SM port yet.
4. **SM/OEI debug UART.** The SM and OEI both use `DEBUG_UART_INSTANCE=2` (the EVK default). On the 00414 the UART2 pads are the BOOT_MODE strap nets, so check that this is harmless, or disable the debug UART.
5. **USB_A TCPC address.** 0x51 is used, carried over from the tested 00363-00365 kernel DT. The 00363 U-Boot DT used 0x50. Verify against the 00365 SLV_ADDR strap.
6. **PHY reset polarity (resolved 2026-10-07).** On both the 00365 and the 00428, ETH_x_RST reaches PHYRST through a non-inverting FET level shifter: the FET gate is on VDD_1V8, with a 100k pull-up to 1V8 on the SoC side and a pull-up to 3V3 on the PHY side. So the line is active low, and the pull-up releases the PHY by default. The 00414 kernel DTs and U-Boot `board_init()` now use active low. The 00363 U-Boot DTs still declare `ethphy1` reset-gpios GPIO_ACTIVE_HIGH on the 00365; that is wrong, but it is outside this branch.
7. **Display variants on the 00365:** `imx95-cargt-00414-00365-glt0557201280is1` (5.5" MIPI-DSI) and `-glt1011280800is1` (10.1" LVDS) are built. Select one with `fw_setenv fdtfile boot/<name>.dtb`. The 10.1" backlight is on/off only: OSM LVDS_BL_PWM is CCM_CLKO2 on the 00414, a pad with no TPM function, so it is driven as GPIO3_IO27 with gpio-backlight. Route it to a PWM-capable pad in a SOM respin. Hardware checks: [x] 5.5" DSI image, backlight and touch (2026-10-08, with the DTB and Weston mode equivalent of the fixes below; re-check on a clean build); DSI needed three fixes: the display-mix irqsteer, the 00414 TMUX646 DSI/CSI_B switch (DSI_nOE low, CSI_nDSI_SEL high), and timing: VIDEOPLL1 500 MHz for an exact 50 MHz pixel clock plus kernel patch 0012 (htotal rounded to whole DSI lane byte clocks, 870 -> 872 for this panel). The switch also gates OSM CSI_B, so a CSI_B camera needs CSI_nDSI_SEL low;  [ ] 10.1" LVDS image, backlight and touch. **Not ported yet:** glt028240320is1 (SPI). On the 00428 the 5.5" GLT0557201280IS1 panel is fitted on every board and its DT is the 00363-00428 default, so `imx95-cargt-00414-00428` currently boots its base DT with no display. Also not ported: PCIe (OSM PCIe_A/B, pca9555 P11 PCIE_PWR_EN), ETH_C, camera, audio (SAI1/I2S_A).
8. **ETH_x_nINT.** The PHY interrupts are not wired up in the DT, so the PHYs are polled.
9. **Schematic revision.** Confirm whether the prototypes are rev 00 (the PDF used here) or rev 01 (Altium project `105-00414-01`).
