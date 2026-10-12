# uart_regif_pkg.sv  (package)

### Source: uart_regif_pkg.sv

## Parameters

|Name|Type|Dimension|Default|Description|
|-|-|-|-|-|
|ADDR_CTRL|int||8'h00|---------------- Register byte-address offsets ----------------|
|ADDR_CFG|int||8'h04||
|ADDR_STATUS|int||8'h08||
|ADDR_TXD|int||8'h0C||
|ADDR_RXD|int||8'h10||
|ADDR_INTR|int||8'h14||
|CTRL_RST|uart_ctrl_t||'{         reserved : '0,         rx_flush : 1'b0,         tx_flush : 1'b0,         rx_en : 1'b0,         tx_en : 1'b0     }|---------------- Reset values ----------------|
|CFG_RST|uart_cfg_t||'{         reserved : '0,         extra_stop : 1'b0,         parity_type : 1'b0,         parity_en : 1'b0,         num_bits : 2'd3,         baud_div : 16'h28B0     }||
|INTR_RST|uart_intr_t||'{         reserved : '0,         rx_empty : 1'b0,         tx_empty : 1'b0,         rx_full : 1'b0,         tx_full : 1'b0     }||


## Typedefs

|Name|
|-|
|uart_ctrl_t|
|uart_cfg_t|
|uart_status_t|
|uart_intr_t|


## Description

_No top-level description found._
