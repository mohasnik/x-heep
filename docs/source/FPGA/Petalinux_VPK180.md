# Building Linux Image for VPK180 Target
As it may not be feasible to use a pre-built Linux package, compared to other platforms supported by X-HEEP, this section gives brief instructions on how to build a Linux image with the minimum requirements using PetaLinux for VPK180. For this, you need to install Petalinux. Please refer to the following links for more information:

* [Petalinux Installation Guide](https://docs.amd.com/r/en-US/ug1144-petalinux-tools-reference-guide/Installing-the-PetaLinux-Tool)
* [Example Petalinux project for Versal Targets](https://docs.amd.com/r/2024.2-English/ug1305-versal-embedded-tutorial/System-Design-Example-using-Scalar-Engine-and-Adaptable-Engine?section=example-project-creating-linux-images-using-petalinux)

## Creating and Configuring the Project

1. Download the Board Support Package (BSP) file for VPK180 form [this link](https://www.xilinx.com/support/download.html/content/xilinx/en/downloadNav/embedded-design-tools/2024-2.html)

2. Run the following command to create a new Petalinux Project: 

```bash
petalinux-create -n xheep_versal_linux project -s /path/to/BSP/File
```
This will create a fresh project from the BSP with necessary board-specific constarints for you.

3. Configure the project with your synthesized hardware configuration.
In order to rpovide the information on you PS/PL design configurations to Petalinux project, you mujst provide the `.xsa` file recieved from Vivado. You can simply export xsa file suing the following commadn in Vviado :

```tcl
    write_hw_platform -fixed -include_bit -force' "file_name.xsa"
```
 file is already exported by the build flow triggered by the `make vivado-fpga FPGA_BOARD=vpk180` and can be found inside the FuseSoC build directory (e.g, `build/openhwgroup.org_systems_core-v-mini-mcu_<xheep_version>/vpk180-vivado`).

Or in GUI, `File > Export > Export Hardware ...`.  Make sure to incldue the pdi file while exporting.

After having the `xsa` file, run the following command inside the petalinux project:


```bash
cd xheep_versal_linux
petalinux-config --get-hw-description=/path/to/XSA/file.xsa
```


## Add OpenOCD Package 

In order to program VPK180 you need OpenOCD to interact with JTAG and flash the `main.elf` file to X-HEEP. However, this package does not exist in Petalinux packages, and requires additional steps in Yocto to download and build this package in your linux . In order to do so, do the followings : 

1. Create this directory:

```sh
mkdir -p project-spec/meta-user/recipes-devtools/openocd/files
```

2. Create `project-spec/meta-user/recipes-devtools/openocd/openocd_%.bbappend` with:

```bitbake
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Use the OpenOCD upstream repo/revision expected by the X-HEEP helper flow.
SRC_URI:remove = "git://repo.or.cz/openocd.git;protocol=http;name=openocd;branch=master"
SRC_URI:prepend = "git://github.com/openocd-org/openocd.git;protocol=https;name=openocd;branch=master "
SRC_URI:append = " file://openocd-xheep.patch"
SRCREV_openocd = "b9e40161613fd880fc85fdb357365b70e646ff23"

# Needed for AXI JTAG access through the Xilinx AXI XVC OpenOCD driver.
EXTRA_OECONF:append = " --enable-xlnx-axi-xvc --enable-internal-jimtcl"
```


3. Put [this patch](LINK TO THE PATCH) file here:

```text
project-spec/meta-user/recipes-devtools/openocd/files/openocd-xheep.patch
```

That patch changes OpenOCD RISC-V register probing for X-HEEP:
- checks `misa` before probing `vlenb`
- skips unsupported `mtopi` and `mtopei` probing
- avoids an assertion when those registers are treated as unavailable

4. Rebuild OpenOCD after adding/changing this override:

```sh
petalinux-build -c openocd -x cleansstate
petalinux-build -c openocd
```


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