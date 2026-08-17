# apb_uart_top (module)

### Author: Ahasan Ullah Khalid (aukhalid02@gmail.com)

### Source: apb_uart_top.sv

## Top IO

<img src="./apb_uart_top_top.svg">

## Parameters

|Name|Type|Dimension|Default|Description|
|-|-|-|-|-|
|APB_ADDR_WIDTH|int||32||
|APB_DATA_WIDTH|int||32||
|FIFO_SIZE|int||4|log2(16) -> Depth of 16 for FIFOs|


## Ports

|Name|Direction|Type|Dimension|Description|
|-|-|-|-|-|
|PCLK|input|logic||APB Bus Interface|
|PRESETn|input|logic|||
|PADDR|input|logic [APB_ADDR_WIDTH-1:0]|||
|PSEL|input|logic|||
|PENABLE|input|logic|||
|PWRITE|input|logic|||
|PWDATA|input|logic [APB_DATA_WIDTH-1:0]|||
|PRDATA|output|logic [APB_DATA_WIDTH-1:0]|||
|PREADY|output|logic|||
|PSLVERR|output|logic|||
|UART_TX|output|logic||UART External Interface|
|UART_RX|input|logic|||
|UART_IRQ|output|logic||Interrupt|


## Description

@foez---bhai, write the purpose of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

@foez---bhai, describe the use case of this module in markdown format here. This is already in multi-line comment, so don't add any additional comment syntax.

| REVISION | DATE       | AUTHOR              | DESCRIPTION                                            |
|----------|------------|---------------------|--------------------------------------------------------|
| 0.1      | 2026-08-13 | Ahasan Ullah Khalid | Initial version                                        |
| 1.0      | 2026-08-17 | Ahasan Ullah Khalid | Stable release                                         |

Author : Ahasan Ullah Khalid (aukhalid02@gmail.com)
