`ifndef UART_RSP_ITEM_SV
`define UART_RSP_ITEM_SV

class uart_rsp_item extends uvm_sequence_item;

  bit      [7:0] data;
  bit            parity;
  bit            parity_err;
  bit            framing_err;
  realtime       frame_duration;

  `uvm_object_utils_begin(uart_rsp_item)
    `uvm_field_int(data, UVM_ALL_ON | UVM_HEX)
    `uvm_field_int(parity, UVM_ALL_ON | UVM_BIN)
    `uvm_field_int(parity_err, UVM_ALL_ON | UVM_BIN)
    `uvm_field_int(framing_err, UVM_ALL_ON | UVM_BIN)
    `uvm_field_real(frame_duration, UVM_ALL_ON | UVM_NOCOMPARE)
  `uvm_object_utils_end

  function new(string name = "uart_rsp_item");
    super.new(name);
  endfunction

  virtual function string convert2string();
    return $sformatf(
        "data=0x%02h parity=%0b parity_err=%0b framing_err=%0b duration=%0t",
        data,
        parity,
        parity_err,
        framing_err,
        frame_duration
    );
  endfunction

endclass : uart_rsp_item

`endif  // UART_RSP_ITEM_SV
