# i.MX 95 00414 OSM-L SOM bring-up (wrynose)

Living TODO / test checklist for `imx95-cargt-00414-00365` (primary) and
`imx95-cargt-00414-osm-som`. Check items off in the same commit that closes them.

Sources used:
- 00414 SOM schematic `014-00414-00.PDF` (rev 00). A rev 01 Altium project also exists.
- 00365 carrier schematic `00365.pdf` (rev 05).
- 00363 SOM schematic `014-00363-FE.PDF` (rev 04). Used to translate the
  00363-00365 device tree by OSM-L signal name.
- NXP 19x19 LPDDR5 EVK (`imx95-19x19-lpddr5-evk`, lf-6.18.20_2.0.0). Used as the
  SoC-level reference.

## Boot chain and where the 00414 support lives

| Stage | Runs on | Cargt 00414 support |
|---|---|---|
| OEI (DDR init) | M33 | stock `mx95lp5` board, EVK 19x19 LPDDR5 6400 MT/s timing (machine conf) |
| System Manager | M33 | `recipes-bsp/imx-system-manager`: board `cargt00414` (copy of `mcimx95evk` + optional-device patch), config `mx95cargt00414.cfg` |
| SPL / ATF / OP-TEE / U-Boot | A55 | `u-boot-imx` patch 0030 (`board/cargt/imx95_00414`), `files/dts/imx95-cargt-00414-*` |
| Linux | A55 | `files/dts/freescale/imx95-cargt-00414-*.dts`, `cargt_00414_kernel_config_mods.cfg` |

`IMXBOOT_TARGETS = "flash_a55"`: A55-only container, no M7 image.

## Build verification

- [x] Kernel DTBs compile with `dtc`. Checked outside bitbake against the lf-6.18.20 tree.
- [x] U-Boot builds for both defconfigs. Checked outside bitbake with the Yocto aarch64 cross-compiler.
- [x] System Manager builds with `CONFIG=mx95cargt00414`. Checked outside bitbake with arm-none-eabi 13.2.
- [ ] `bitbake -e` parse check for both machines
- [ ] `bitbake virtual/kernel`, `u-boot-imx`, `imx-system-manager`, `imx-oei`, `imx-boot`
- [ ] `bitbake cargt-image-core`, for both machines

## Hardware bring-up checklist

- [ ] Serial download (BOOT_MODE 01) with `uuu`. Expected on the console: OEI output, then the SM banner "Cargt i.MX95 00414", then SPL.
- [ ] DDR training passes with the EVK timing (see open item 1)
- [ ] U-Boot prompt; `mmc list` shows eMMC (mmc0) and microSD (mmc1)
- [ ] eMMC boot (BOOT_MODE 10) and SD boot (BOOT_MODE 11)
- [ ] Kernel boot to rootfs from eMMC
- [ ] `i2cdetect` on I2C_A (lpi2c2): 0x20 (TCA9555), 0x51 (PTN5110 USB_A), 0x52 (PTN5110 USB_C)
- [ ] ETH_A (enetc_port0, NETC EMDIO): link and ping, in U-Boot and Linux
- [ ] ETH_B (enetc_port1, bit-banged MDIO): link and ping, in U-Boot and Linux
- [ ] USB-C(A), OSM USB_A (usb2, high-speed only): host and device role switching
- [ ] USB-C(C), OSM USB_C (usb3): role switching, and SuperSpeed in both plug orientations (CBTU02043 mux, pca9555 P12)
- [ ] microSD card detect and read/write
- [ ] CAN_A (flexcan1) and CAN_B (flexcan3) loopback between the two ports
- [ ] UART_B (lpuart5, MikroBus) and UART_C (lpuart6)
- [ ] ADC (adc1) readings
- [ ] PMIC and SoC thermal zones in `/sys/class/thermal` (SCMI sensors)
- [ ] Watchdog reset (wdog3 → WDOG_ANY → PF09)

## Open items / TODO

1. **DDR timing selection.** i.MX 95 trains DDR in OEI on the M33, before the SM and SPL. The SPL EEPROM-based selection used on i.MX 93 (`cargt_eeprom`) therefore does not apply. OEI builds exactly one timing file (`OEI_DDR_CONFIG`) and has no I2C driver.
   - [ ] Confirm the 00414 part (MT62F4G32D8DV, 16 GB) matches the EVK timing, or generate a 00414 timing file with the NXP Config Tools DDR tool.
   - [ ] If one SOM image must support several DDR fits: add a Cargt OEI board port that reads the M24C02 at 0x50 on LPI2C1 and picks among compiled-in timings. OEI runs before the SM claims LPI2C1, so the bus is free at that point. Options are to port the imx-sm `fsl_lpi2c` driver into OEI, or to use fuses or strap GPIOs instead.
2. **LPI2C1 is owned by the SM.** The RX8111 RTC (0x32) and the M24C02 EEPROM (0x50) share the bus with the PMICs.
   - [ ] RTC: add an RX8111 board RTC to the `cargt00414` SM port, exposed to Linux over SCMI BBM, in place of the EVK PCA2131. Until then only the SoC BBM RTC is available.
   - [ ] EEPROM (serial number, MAC): expose it through SM board controls (SCMI misc) or read it in OEI. Otherwise move it off LPI2C1 in a SOM respin.
3. **PF09 interrupt.** On the EVK it is routed through the PCAL6408A; on the 00414 it goes to GPIO_IO35 and is not handled by the SM port yet.
4. **SM/OEI debug UART.** The SM and OEI both use `DEBUG_UART_INSTANCE=2` (the EVK default). On the 00414 the UART2 pads are the BOOT_MODE strap nets, so check that this is harmless, or disable the debug UART.
5. **USB_A TCPC address.** 0x51 is used, carried over from the tested 00363-00365 kernel DT. The 00363 U-Boot DT used 0x50. Verify against the 00365 SLV_ADDR strap.
6. **PHY reset polarity.** The 00365 ETH_x_RST drive an N-FET that pulls PHYRST low, so they are asserted high. The 00414 files use GPIO_ACTIVE_HIGH. The 00363-00365 kernel DT uses GPIO_ACTIVE_LOW for its eqos reset (only U-Boot there is active-high); worth reviewing on that board too.
7. **Not ported yet:** display variants (glt028240320is1 SPI, glt0557201280is1 DSI, glt1011280800is1 LVDS), PCIe (OSM PCIe_A/B, pca9555 P11 PCIE_PWR_EN), ETH_C, camera, audio (SAI1/I2S_A).
8. **ETH_x_nINT.** The PHY interrupts are not wired up in the DT, so the PHYs are polled.
9. **Schematic revision.** Confirm whether the prototypes are rev 00 (the PDF used here) or rev 01 (Altium project `105-00414-01`).
