# Building Linux Image for VPK180 Target



## Registering UART on Linux Runtime
Since the UART device is a PL IP, the generated Linux image does not initially identify the physical address region dedicated to the UARTLite module as an actual UART device. Although it is possible to add this address range to the device tree before building the PetaLinux image, this can result in a boot fault if segmented configuration is enabled for your Vivado project. The reason is that the boot PDI file does not activate the address range related to the PL region, including the region dedicated to the UARTLite IP. Therefore, Linux may fault during boot while checking for all available devices.

One solution is to compile and add the device tree overlay after the Linux image has been built and successfully booted, and after the PL has been successfully programmed. In order to do so, you need to create a .dts file with the following content:

```
/dts-v1/;
/plugin/;

/ {
    fragment@0 {
        target-path = "/amba_pl@0";

        __overlay__ {
            serial@a4040000 {
                compatible = "xlnx,xps-uartlite-1.00.a";

                reg = <0x0 0xa4040000 0x0 0x10000>;

                interrupt-parent = <&gic>;
                interrupts = <0 92 4>;

                current-speed = <9600>;

                xlnx,data-bits = <8>;
                xlnx,use-parity = <0>;
                xlnx,odd-parity = <0>;

                status = "okay";
            };
        };
    };
};
```

Make sure to configure the physical address of the UART module, the address range size, and the baud rate based on your design. The above file contains the default values from `hw/fpga/xheep_fpga_support/scripts/vpk180/xilinx_generate_ps_wizard.tcl`.


Then you can compile the above device tree file using the following command:

```bash
    dtc -@ -I dts -O dtb \
        -o uart_overlay.dtbo \
        <DTS_FILE_NAME>.dts
```

Finally, add the overlay using the Xilinx `fpgautil` package:

```bash
    sudo fpgautil -o "$(pwd)/uart_overlay.dtbo"
```


Now you can verify that the device has been registered:

```bash
    ls /dev/ttyUL*
```

You should see a new device listed (ttyUL0).