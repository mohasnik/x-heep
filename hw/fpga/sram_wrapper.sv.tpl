// Copyright (c) 2020 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

module sram_wrapper #(
    parameter int unsigned NumWords = 32'd1024,  // Number of Words in data array
    parameter int unsigned DataWidth = 32'd32,  // Data signal width
    // DEPENDENT PARAMETERS, DO NOT OVERWRITE!
    parameter int unsigned AddrWidth = (NumWords > 32'd1) ? $clog2(NumWords) : 32'd1,
    parameter int unsigned VERSAL_MEM_USE_URAM = 0
) (
    input logic clk_i,
    input logic rst_ni,
    // input ports
    input logic req_i,
    input logic we_i,
    input logic [AddrWidth-1:0] addr_i,
    input logic [31:0] wdata_i,
    input logic [3:0] be_i,
    // power manager signals that goes to the ASIC macros
    input logic pwrgate_ni,
    output logic pwrgate_ack_no,
    input logic set_retentive_ni,
    // output ports
    output logic [31:0] rdata_o
);

assign pwrgate_ack_no = pwrgate_ni;

`ifdef FPGA_VPK180
  // Classical inferred block RAM (byte-enabled, single-port, 1-cycle read latency)
  logic [31:0] rdata_q;
  localparam logic [63:0] RAM_STYLE = VERSAL_MEM_USE_URAM ? "ultra" : "block";
  
  (* ram_style = RAM_STYLE *) logic [31:0] mem [0:NumWords-1];

  always_ff @(posedge clk_i) begin
    if (req_i) begin
      if (we_i) begin
        if (be_i[0]) mem[addr_i][ 7: 0] <= wdata_i[ 7: 0];
        if (be_i[1]) mem[addr_i][15: 8] <= wdata_i[15: 8];
        if (be_i[2]) mem[addr_i][23:16] <= wdata_i[23:16];
        if (be_i[3]) mem[addr_i][31:24] <= wdata_i[31:24];
      end
      rdata_q <= mem[addr_i];
    end
  end

  assign rdata_o = rdata_q;
`else

<%el = ""%>
% for num_words in xheep.memory_ss().iter_bank_numwords():
  ${el}if (NumWords == 32'd${num_words}) begin
    xilinx_mem_gen_${num_words} tc_ram_i (
        .clka (clk_i),
        .ena  (req_i),
        .wea  ({4{req_i & we_i}} & be_i),
        .addra(addr_i),
        .dina (wdata_i),
        // output ports
        .douta(rdata_o)
    );
  end
<%el = "else "%>
% endfor
  else begin
    $error("Bank size not generated.");
  end
`endif
endmodule
