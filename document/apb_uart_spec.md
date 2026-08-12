# Overview

The APB UART is a synthesizable, AMBA APB4-compliant Universal Asynchronous Receiver/Transmitter (UART) IP core. It provides a standard serial communication interface between an APB-based SoC and external UART devices. The design is intended for reuse across multiple projects and is fully parameterized for baud rate, data width, FIFO depth, and parity/stop bit configuration.

# Architecture & Block Diagram

<img src="./apb_uart_top.svg">

# Interface Specification

## Top-Level Port List

### APB Interface (Slave)

| Port      | Width | Direction | Description                                                    |
| --------- | ----- | --------- | -------------------------------------------------------------- |
| `PCLK`    | 1     | Input     | APB clock - all logic synchronous to rising edge               |
| `PRESETn` | 1     | Input     | Active-low asynchronous reset                                  |
| `PADDR`   | 12    | Input     | APB address bus `[11:2]` used for word-aligned register decode |
| `PSEL`    | 1     | Input     | APB peripheral select                                          |
| `PENABLE` | 1     | Input     | APB enable (2nd cycle of transfer)                             |
| `PWRITE`  | 1     | Input     | APB write enable (1 = write, 0 = read)                         |
| `PWDATA`  | 32    | Input     | APB write data bus                                             |
| `PRDATA`  | 32    | Output    | APB read data bus                                              |
| `PREADY`  | 1     | Output    | APB ready (always 1 - zero wait states)                        |
| `PSLVERR` | 1     | Output    | APB slave error (always 0)                                     |
