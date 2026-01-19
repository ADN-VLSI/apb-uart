# APB-UART

A Universal Asynchronous Receiver/Transmitter (UART) peripheral with Advanced Peripheral Bus (APB) interface for embedded systems.

## Overview

The APB-UART peripheral provides a standard UART interface for serial communication in embedded systems. It features a full APB4 compliant interface, configurable baud rates, programmable parity settings, and dual FIFOs for buffering transmit and receive data.

## Features

- **APB4 Compliant Interface** - Full Advanced Peripheral Bus integration
- **Configurable Baud Rate** - Programmable clock divider for flexible baud rate generation
- **Programmable Parity** - Supports even/odd parity or no parity
- **Flexible Stop Bits** - Configurable 1 or 2 stop bits
- **Large Buffer Capacity** - 1KB transmit FIFO and 1KB receive FIFO
- **Interrupt Support** - Multiple interrupt sources for efficient CPU utilization
- **Clock Domain Crossing** - Safe data transfer between APB and UART clock domains
- **Parameterizable** - Configurable data and address bus widths

## Architecture

The APB-UART consists of the following key components:

- **apb_memif** - APB bus interface and transaction handler
- **uart_regif** - Register file management for configuration and status
- **cdc_fifo** - Clock domain crossing FIFO for safe data transfer (TX and RX)
- **clk_div** - Programmable clock divider for baud rate generation
- **uart_tx** - UART transmitter with configurable frame format
- **uart_rx** - UART receiver with parity checking

![Architecture Diagram](docs/svg/arch.svg)

## Parameters

| Parameter  | Description              | Default Value |
|------------|--------------------------|---------------|
| DATA_WIDTH | Width of the data bus    | 32            |
| ADDR_WIDTH | Width of the address bus | 8             |

## Interface Signals

### APB Interface

| Signal    | Direction | Width        | Description            |
|-----------|-----------|--------------|------------------------|
| arst_ni   | Input     | 1            | Async reset, active low|
| clk_i     | Input     | 1            | System clock           |
| psel_i    | Input     | 1            | APB select             |
| penable_i | Input     | 1            | APB enable             |
| paddr_i   | Input     | ADDR_WIDTH   | APB address bus        |
| pwrite_i  | Input     | 1            | APB write signal       |
| pwdata_i  | Input     | DATA_WIDTH   | APB write data         |
| pstrb_i   | Input     | DATA_WIDTH/8 | APB write strobe       |
| pready_o  | Output    | 1            | APB ready              |
| prdata_o  | Output    | DATA_WIDTH   | APB read data          |
| pslverr_o | Output    | 1            | APB slave error        |

### UART Interface

| Signal | Direction | Width | Description         |
|--------|-----------|-------|---------------------|
| rx_i   | Input     | 1     | UART receive input  |
| tx_o   | Output    | 1     | UART transmit output|

### Interrupt Signals

| Signal              | Direction | Width | Description                      |
|---------------------|-----------|-------|----------------------------------|
| irq_tx_almost_full  | Output    | 1     | TX FIFO almost full interrupt    |
| irq_rx_almost_full  | Output    | 1     | RX FIFO almost full interrupt    |
| irq_rx_parity_error | Output    | 1     | RX parity error interrupt        |
| irq_rx_valid        | Output    | 1     | RX data valid interrupt          |

## Register Map

| Address | Register      | Access | Description                      |
|---------|---------------|--------|----------------------------------|
| 0x00    | CTRL          | RW     | Control register                 |
| 0x04    | CLK_DIV       | RW     | Clock divider (baud rate)        |
| 0x08    | CFG           | RW     | UART configuration               |
| 0x0C    | TX_FIFO_COUNT | RO     | TX FIFO data count               |
| 0x10    | RX_FIFO_COUNT | RO     | RX FIFO data count               |
| 0x14    | TX_DATA       | WO     | Transmit data register           |
| 0x18    | RX_DATA       | RO     | Receive data register            |
| 0x1C    | INTR_CTRL     | RW     | Interrupt control and status     |

### Register Details

#### CTRL (0x00) - Control Register

| Bit   | Field    | Access | Description                      |
|-------|----------|--------|----------------------------------|
| 0     | CLK_EN   | RW     | Clock enable                     |
| 1     | TX_FLUSH | RW     | TX FIFO flush (self-clearing)    |
| 2     | RX_FLUSH | RW     | RX FIFO flush (self-clearing)    |
| 31: 3  | RESERVED | --     | Reserved                         |

#### CLK_DIV (0x04) - Clock Divider Register

| Bit   | Field   | Access | Default | Description                    |
|-------|---------|--------|---------|--------------------------------|
| 31:0  | DIVIDER | RW     | 0x28B0  | Clock divider for baud rate    |

**Baud Rate Calculation:** `Baud Rate = APB_Clock / (DIVIDER + 1)`

Default value 0x28B0 (10416) provides 9600 baud with 100 MHz APB clock.

#### CFG (0x08) - Configuration Register

| Bit   | Field       | Access | Description                           |
|-------|-------------|--------|---------------------------------------|
| 0     | PARITY_EN   | RW     | Parity enable (1=enabled, 0=disabled) |
| 1     | PARITY_TYPE | RW     | Parity type (1=odd, 0=even)           |
| 2     | EXTRA_STOP  | RW     | Stop bits (1=two bits, 0=one bit)     |
| 31:3  | RESERVED    | --     | Reserved                              |

#### INTR_CTRL (0x1C) - Interrupt Control Register

| Bit   | Field           | Access | Description                        |
|-------|-----------------|--------|------------------------------------|
| 0     | RX_VALID        | RW     | RX data valid interrupt            |
| 1     | RX_PARITY_ERROR | RW     | RX parity error interrupt          |
| 2     | RX_ALMOST_FULL  | RW     | RX FIFO almost full interrupt      |
| 3     | TX_ALMOST_FULL  | RW     | TX FIFO almost full interrupt      |
| 31:4  | RESERVED        | --     | Reserved                           |

*Note: Write 1 to clear interrupt flags.*

## Usage Example

### Initialization

```c
// Enable UART clock
write_reg(CTRL, 0x1);

// Configure baud rate to 115200 (assuming 100 MHz APB clock)
// Divider = (100,000,000 / 115200) - 1 = 867
write_reg(CLK_DIV, 867);

// Configure: Even parity enabled, 1 stop bit
write_reg(CFG, 0x1);

// Enable RX valid interrupt
write_reg(INTR_CTRL, 0x1);
```

### Transmitting Data

```c
// Check TX FIFO has space
while (read_reg(TX_FIFO_COUNT) >= 1024) {
    // Wait for space
}

// Write data to transmit
write_reg(TX_DATA, 'A');
```

### Receiving Data

```c
// Check if data is available
if (read_reg(RX_FIFO_COUNT) > 0) {
    // Read received data
    uint8_t data = read_reg(RX_DATA) & 0xFF;
}
```

## Documentation

Detailed design documentation is available in [`docs/design.md`](docs/design.md), including:

- Complete functional specification
- Block diagrams for all modules
- State machine diagrams for TX/RX
- Timing specifications
- Integration guidelines

## License

Copyright (c) 2026 ADN Semiconductors
