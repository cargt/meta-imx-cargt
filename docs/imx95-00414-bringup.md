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
- [ ] SD boot (BOOT_MODE 11)
- [x] Kernel boot to rootfs from eMMC (`cargt-image-dev`, login on ttyLP0, 2026-10-08). Expected failures in that boot: Weston (no display DT yet). The NXP Wi-Fi/BT services failed too; they are now only installed when MACHINE_FEATURES has `wifi`/`bluetooth`, which the 00414 does not.
- [ ] Software updates by `.swu` from microSD until Ethernet works: copy `cargt-image-<type>-swu-<machine>.rootfs.swu` to the card, then on the target `swupdate -v -i /run/media/<card>/<file>.swu` and reboot.
- [ ] `i2cdetect` on I2C_A (lpi2c2): 0x20 (TCA9555), 0x51 (PTN5110 USB_A), 0x52 (PTN5110 USB_C)
- [ ] ETH_A (enetc_port0, NETC EMDIO): link and ping, in U-Boot and Linux
- [ ] ETH_B (enetc_port1, bit-banged MDIO): link and ping, in U-Boot and Linux. The PHY (RTL8211F at address 0) answers on the bit-banged bus in U-Boot (`mdio list`), and so does the ETH_A PHY on NETC EMDIO (2026-10-08).
- [ ] I2C_A (lpi2c2) in U-Boot: `i2c: Error check busy bus: 0x8`, and the pca953x at 0x20 cannot be read. Linux (`i2c-1`) fails the same way: pca953x 1-0020, tcpci 1-0051 and 1-0052 all time out (-110). Check the SCL/SDA idle levels and the 00365 I2C_A 3.3 V level-shifter supply. Knock-on effects: both USB-C ports (no TCPC, no SS mux) and, before the workaround below, both Ethernet ports.
- [ ] Restore the 00365 PHY `reset-gpios` (pca9555 P00/P01) in the kernel DT once I2C_A works. They are commented out because an unprobed pca9555 kept both PHYs from registering (`net eth0/eth1: could not attach to PHY`); the resets are released by pull-ups when undriven.
- [ ] `ci_hdrc ci_hdrc.0: Aliasing StreamID 0xf (from 4c200000.usb) unsupported, expect DMA to be broken` on usb2: check once USB_A can be exercised.
- [ ] USB-C(A), OSM USB_A (usb2, high-speed only): host and device role switching
- [ ] USB-C(C), OSM USB_C (usb3): role switching, and SuperSpeed in both plug orientations (CBTU02043 mux, pca9555 P12)
- [ ] microSD card detect and read/write
- [ ] CAN_A (flexcan1) and CAN_B (flexcan3) loopback between the two ports
- [ ] UART_B (lpuart5, MikroBus) and UART_C (lpuart6)
- [ ] ADC (adc1) readings
- [ ] PMIC and SoC thermal zones in `/sys/class/thermal` (SCMI sensors)
- [ ] Watchdog reset (wdog3 → WDOG_ANY → PF09)

### 00428 carrier

- [ ] Recovery/flash path. On the 00414, OSM USB_C is the i.MX 95 USB1 (USB 3.0) controller, and that is likely the ROM serial-download port. On the 00428, USB_C is a host-only port with a VBUS enable. On the 00363 the ROM used USB1 = OSM USB_A, the 00428's USB-C connector. Confirm which port `uuu` serial download works on; SD or eMMC flashing may be needed instead.
- [ ] `i2cdetect` on I2C_A (lpi2c2): 0x51 (PTN5110 USB_A)
- [ ] ETH_A (enetc_port0, NETC EMDIO, reset on GPIO_IO09): link and ping, in U-Boot and Linux
- [ ] USB-C, OSM USB_A (usb2): role switching, plus U-Boot fastboot (`usb_gadget0`)
- [ ] OSM USB_C (usb3) host with VBUS (GPIO_IO15)
- [ ] UART_B (lpuart5, MikroBus)
- [ ] `/data` mounted from `LABEL=data` (base-files fstab)

## Open items / TODO

1. **DDR parts and EEPROM-based selection.** i.MX 95 trains DDR in OEI on the M33, before the SM and SPL, so the i.MX 93 SPL selection (`cargt_eeprom`) does not apply. Today OEI builds exactly one timing file (`OEI_DDR_CONFIG`). Only one part is fitted so far: MT62F512M32D2DR-031 WT:B (2 GB). The BOM part MT62F4G32D8DV (16 GB) has no timing yet.
   - [ ] Requirement: one image for every 00414 DDR fit, with the part read from the SOM EEPROM (M24C02 at 0x50 on LPI2C1) at boot. OEI runs before the SM claims LPI2C1, so the bus is free then. OEI has no I2C driver, so port the imx-sm `fsl_lpi2c` driver.
   - [ ] Space constraint (measured 2026-10-08): OEI plus the four LPDDR5 FW2024.09 training images must fit in 0x59000 (356 KB). The firmware takes 221 KB. OEI with one timing table is 102 KB (about 64 KB of that is timing data), so a second full table does not fit. Design: keep one full table (the board-level PHY setup, PIE image and DQ/CA swizzle, which are shared because the routing is the same) plus a small per-part delta (DDRC CS bounds/config, FSP DDRC timings, message-block mode registers). That is roughly 1 KB per part, applied before training. Generate each part's timing with the DDR Tool keeping the same CA/DQ mapping, and diff it against the base.
   - [ ] EEPROM layout for the DDR part ID (reuse or extend the Cargt EEPROM format from U-Boot `board/cargt/common/cargt_eeprom.c`), and a defined fallback when the EEPROM is blank.
2. **LPI2C1 is owned by the SM.** The RX8111 RTC (0x32) and the M24C02 EEPROM (0x50) share the bus with the PMICs.
   - [ ] RTC: add an RX8111 board RTC to the `cargt00414` SM port, exposed to Linux over SCMI BBM, in place of the EVK PCA2131. Until then only the SoC BBM RTC is available.
   - [ ] EEPROM (serial number, MAC): expose it through SM board controls (SCMI misc) or read it in OEI. Otherwise move it off LPI2C1 in a SOM respin.
3. **PF09 interrupt.** On the EVK it is routed through the PCAL6408A; on the 00414 it goes to GPIO_IO35 and is not handled by the SM port yet.
4. **SM/OEI debug UART.** The SM and OEI both use `DEBUG_UART_INSTANCE=2` (the EVK default). On the 00414 the UART2 pads are the BOOT_MODE strap nets, so check that this is harmless, or disable the debug UART.
5. **USB_A TCPC address.** 0x51 is used, carried over from the tested 00363-00365 kernel DT. The 00363 U-Boot DT used 0x50. Verify against the 00365 SLV_ADDR strap.
6. **PHY reset polarity (resolved 2026-10-07).** On both the 00365 and the 00428, ETH_x_RST reaches PHYRST through a non-inverting FET level shifter: the FET gate is on VDD_1V8, with a 100k pull-up to 1V8 on the SoC side and a pull-up to 3V3 on the PHY side. So the line is active low, and the pull-up releases the PHY by default. The 00414 kernel DTs and U-Boot `board_init()` now use active low. The 00363 U-Boot DTs still declare `ethphy1` reset-gpios GPIO_ACTIVE_HIGH on the 00365; that is wrong, but it is outside this branch.
7. **Not ported yet:** display variants (glt028240320is1 SPI, glt0557201280is1 DSI, glt1011280800is1 LVDS). On the 00428 the 5.5" GLT0557201280IS1 panel is fitted on every board and its DT is the 00363-00428 default, so `imx95-cargt-00414-00428` currently boots its base DT with no display. Also not ported: PCIe (OSM PCIe_A/B, pca9555 P11 PCIE_PWR_EN), ETH_C, camera, audio (SAI1/I2S_A).
8. **ETH_x_nINT.** The PHY interrupts are not wired up in the DT, so the PHYs are polled.
9. **Schematic revision.** Confirm whether the prototypes are rev 00 (the PDF used here) or rev 01 (Altium project `105-00414-01`).
