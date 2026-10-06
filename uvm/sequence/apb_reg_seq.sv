`ifndef __GUARD_APB_REG_SEQ_SV__
`define __GUARD_APB_REG_SEQ_SV__

`include "apb/apb_seq_item.sv"

class apb_reg_seq extends uvm_sequence #(apb_seq_item);
  `uvm_object_utils(apb_reg_seq)

  int test_id;

  function new(string name = "apb_reg_seq");
    super.new(name);
  endfunction

  task automatic access_reg(
      input bit is_write,
      input logic [31:0] target_addr,
      input logic [31:0] write_data,
      output logic [31:0] read_data
  );
    apb_seq_item item;
    item = apb_seq_item::type_id::create("item");
    start_item(item);
    if (!item.randomize() with {
          tx_type == is_write;
          addr == target_addr;
          data == write_data;
        }) begin
      `uvm_fatal("RANDFAIL", $sformatf("Could not create APB transaction at 0x%08h", target_addr))
    end
    finish_item(item);
    read_data = item.data;
  endtask

  virtual task body();
    logic [31:0] data;
    case (test_id)
      0: begin
        access_reg(0, 'h04, '0, data);
        if (data !== 'h0003_405B)
          `uvm_error("RESET_CFG", $sformatf("Expected reset CFG 0x0003405B, got 0x%08h", data))
        access_reg(0, 'h08, '0, data);
        if (data[23:20] !== 4'b0101)
          `uvm_error("RESET_STAT", $sformatf("Expected empty FIFOs, got STAT 0x%08h", data))
      end
      1: begin
        access_reg(1, 'h04, 'h0005_4321, data);
        access_reg(0, 'h04, '0, data);
        if (data !== 'h0005_4321)
          `uvm_error("CFG_READBACK", $sformatf("CFG readback mismatch: 0x%08h", data))
        access_reg(1, 'h00, 'h0000_0000, data);
        access_reg(1, 'h1C, 'hA5, data);
        access_reg(1, 'h1C, 'h5A, data);
        access_reg(0, 'h08, '0, data);
        if (data[9:0] !== 2)
          `uvm_error("TX_COUNT", $sformatf("Expected two queued TX bytes, got STAT 0x%08h", data))
      end
      default: begin
        access_reg(1, 'h00, 'h0000_0018, data);
        access_reg(0, 'h00, '0, data);
        if (data[4:0] !== 'h18)
          `uvm_error("CTRL_READBACK", $sformatf("CTRL readback mismatch: 0x%08h", data))
        access_reg(1, 'h00, '0, data);
        access_reg(1, 'h30, 'h0000_000B, data);
        access_reg(0, 'h30, '0, data);
        if (data[3:0] !== 'hB)
          `uvm_error("INT_READBACK", $sformatf("INT readback mismatch: 0x%08h", data))
        access_reg(0, 'h14, '0, data);
        if (data !== 'h8000_0001)
          `uvm_error("TX_GRANT", $sformatf("Unexpected TX grant value: 0x%08h", data))
        access_reg(0, 'h24, '0, data);
        if (data !== 'h8000_0001)
          `uvm_error("RX_GRANT", $sformatf("Unexpected RX grant value: 0x%08h", data))
      end
    endcase
  endtask
endclass

`endif