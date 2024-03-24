# ULX3S VGA Example

This repo provides an example for usage of VGA Pmod with ULX3S FPGA. Provided as an example for those hoping to use VGA for their final project in 18-224 Intro to Open-Source Chip Design.

## Hardware Setup

Attach the PMOD on the right side of the ULX3S, aligned to the bottom of the Pmod connector, as pictured.

![](hardware.png)

## Running the Demo

Build the system: `./build.sh`

Flash the FPGA: `fujprog build/bitstream.bit`

Connect the VGA display and verify that the test pattern is visible.

## License

MIT
