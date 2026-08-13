# Overview

The APB UART is a synthesizable, AMBA APB4-compliant Universal Asynchronous Receiver/Transmitter (UART) IP core. It provides a standard serial communication interface between an APB-based SoC and external UART devices. The design is intended for reuse across multiple projects and is fully parameterized for baud rate, data width, FIFO depth, and parity/stop bit configuration.

# Architecture & Block Diagram

<img src="./apb_uart_top.svg">

# Interface Specification

## Top-Level Port List

### APB Interface (Slave)

| Port      | Width | Direction | Description                                      |
| --------- | ----- | --------- | ------------------------------------------------ |
| `PCLK`    | 1     | Input     | APB clock - all logic synchronous to rising edge |
| `PRESETn` | 1     | Input     | Active-low asynchronous reset                    |
| `PADDR`   | 12    | Input     | APB address bus                                  |
| `PSEL`    | 1     | Input     | APB peripheral select                            |
| `PENABLE` | 1     | Input     | APB enable (2nd cycle of transfer)               |
| `PWRITE`  | 1     | Input     | APB write enable (1 = write, 0 = read)           |
| `PWDATA`  | 32    | Input     | APB write data bus                               |
| `PRDATA`  | 32    | Output    | APB read data bus                                |
| `PREADY`  | 1     | Output    | APB ready (always 1 - zero wait states)          |
| `PSLVERR` | 1     | Output    | APB slave error (always 0)                       |

### UART Serial Interface

| Port      | Width | Direction | Description             |
| --------- | ----- | --------- | ----------------------- |
| `UART_TX` | 1     | Output    | UART transmit data line |
| `UART_RX` | 1     | Input     | UART receive data line  |

### Interrupt Interface

| Port       | Width | Direction | Description                                               |
| ---------- | ----- | --------- | --------------------------------------------------------- |
| `UART_IRQ` | 1     | Output    | Combined interrupt request (active-high, level-sensitive) |

# Register Map

## Address Map (APB Word-Aligned)

All registers are 32-bit wide, word-aligned. Only `[11:2]` of PADDR is decoded.

| Offset | Name        | Type | Reset Value   | Description                               |
| ------ | ----------- | ---- | ------------- | ----------------------------------------- |
| `0x00` | `UART_DR`   | RW   | `0x0000_0000` | Data Register (TX/RX FIFO access)         |
| `0x04` | `UART_SR`   | RO   | `0x0000_0060` | Status Register                           |
| `0x08` | `UART_CR`   | RW   | `0x0000_0000` | Control Register                          |
| `0x0C` | `UART_BR`   | RW   | `0x0000_0001` | Baud Rate Divisor Register                |
| `0x10` | `UART_FCR`  | RW   | `0x0000_0000` | FIFO Control Register                     |
| `0x14` | `UART_IER`  | RW   | `0x0000_0000` | Interrupt Enable Register                 |
| `0x18` | `UART_ISR`  | RWC  | `0x0000_0000` | Interrupt Status Register (write-1-clear) |
| `0x1C` | `UART_MCR`  | RW   | `0x0000_0000` | Modem Control Register (optional)         |
| `0x20` | `UART_MSR`  | RO   | `0x0000_0000` | Modem Status Register (optional)          |
| `0x24` | `UART_TOUT` | RW   | `0x0000_0000` | RX Timeout Register                       |

```
module apb_uart_top #(
    parameter int ADDR_WIDTH = 8,             // APB address width
    parameter int DATA_WIDTH = 32,            // APB/register data width
    parameter int FIFO_DEPTH = 16,            // TX and RX FIFO depth (power of 2)
    parameter int CLK_FREQ_HZ = 50_000_000    // System clock frequency
) (
    // ─── APB Slave Interface ────────────────────────
    input  logic                  PCLK,       // APB clock
    input  logic                  PRESETn,    // APB active-low synchronous reset
    input  logic                  PSEL,       // Peripheral select
    input  logic                  PENABLE,    // Enable phase
    input  logic                  PWRITE,     // Write=1 / Read=0
    input  logic [ADDR_WIDTH-1:0] PADDR,      // Register address
    input  logic [DATA_WIDTH-1:0] PWDATA,     // Write data
    output logic [DATA_WIDTH-1:0] PRDATA,     // Read data
    output logic                  PREADY,     // Ready (wait state)
    output logic                  PSLVERR,    // Slave error

    // ─── UART Serial Interface ──────────────────────
    output logic                  uart_txd,   // Serial TX
    input  logic                  uart_rxd,   // Serial RX

    // ─── Interrupt ──────────────────────────────────
    output logic                  uart_irq    // Level-high interrupt to SoC
);
```
