// Copyright 2026 Huawei Technologies Co., Ltd.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

// Converts the flat X-HEEP OBI request/response structs to the nested OBI
// structs expected by pulp-platform/axi_obi's obi_to_axi bridge.
module xheep_obi_to_axi_bridge
  import obi_pkg::*;
  import core_v_mini_mcu_pkg::*;
  import xheep_obi_to_axi_bridge_pkg::*;
#(
    // X-HEEP's external OBI data bus is currently 32-bit. The bridge address
    // width is usually wider than X-HEEP's flat 32-bit address because the VPK180
    // DDR NoC lives in a 64-bit physical address map.
    parameter int unsigned ObiAddrWidth = VPK180_DDR_AXI_ADDR_WIDTH,
    parameter int unsigned ObiDataWidth = 32,
    parameter int unsigned ObiIdWidth = 1,
    parameter int unsigned ObiRspUserWidth = 1,

    parameter bit AxiLite = 1'b0,
    parameter int unsigned AxiAddrWidth = VPK180_DDR_AXI_ADDR_WIDTH,
    parameter int unsigned AxiDataWidth = VPK180_DDR_AXI_DATA_WIDTH,
    parameter int unsigned AxiUserWidth = VPK180_DDR_AXI_USER_WIDTH,
    parameter int unsigned AxiBurstType = axi_pkg::BURST_INCR,
    parameter int unsigned MaxRequests = 2,

    // When enabled, translate accesses from X-HEEP's external slave window to
    // the physical AXI address window exposed by the VPK180 PS/NoC DDR path:
    //
    //   AXI address = AxiBaseAddr + (OBI address - ObiWindowBaseAddr)
    //
    parameter bit TranslateAddress = 1'b1,
    parameter logic [31:0] ObiWindowBaseAddr = EXT_SLAVE_START_ADDRESS,
    parameter logic [AxiAddrWidth-1:0] AxiBaseAddr = VPK180_DDR_BASE_ADDR,

    // AXI request/response structs are parameterized so the top-level wrapper
    // can pass the exact type matching the PS wizard exported AXI port.
    parameter type axi_req_t = vpk180_ddr_axi_req_t,
    parameter type axi_rsp_t = vpk180_ddr_axi_rsp_t
) (
    input logic clk_i,
    input logic rst_ni,

    input  obi_pkg::obi_req_t  obi_req_i,
    output obi_pkg::obi_resp_t obi_resp_o,

    input logic [AxiUserWidth-1:0] axi_user_i,

    output axi_req_t axi_req_o,
    input  axi_rsp_t axi_rsp_i
);

  typedef logic [ObiAddrWidth-1:0] obi_to_axi_addr_t;
  typedef logic [ObiDataWidth-1:0] obi_to_axi_data_t;
  typedef logic [ObiDataWidth/8-1:0] obi_to_axi_be_t;
  typedef logic [ObiIdWidth-1:0] obi_to_axi_id_t;
  typedef logic [ObiRspUserWidth-1:0] obi_to_axi_ruser_t;

  // Optional fields are present in the type so it matches the shape expected by
  // obi_to_axi. The configuration below disables their protocol use.
  typedef struct packed {
    logic [2:0] prot;
    logic [5:0] atop;
    logic [1:0] memtype;
  } obi_to_axi_a_optional_t;

  typedef struct packed {
    logic              exokay;
    obi_to_axi_ruser_t ruser;
  } obi_to_axi_r_optional_t;

  typedef struct packed {
    obi_to_axi_addr_t       addr;
    logic                   we;
    obi_to_axi_be_t         be;
    obi_to_axi_data_t       wdata;
    obi_to_axi_id_t         aid;
    obi_to_axi_a_optional_t a_optional;
  } obi_to_axi_a_chan_t;

  typedef struct packed {
    obi_to_axi_data_t       rdata;
    obi_to_axi_id_t         rid;
    logic                   err;
    obi_to_axi_r_optional_t r_optional;
  } obi_to_axi_r_chan_t;

  typedef struct packed {
    obi_to_axi_a_chan_t a;
    logic               req;
  } obi_to_axi_req_t;

  typedef struct packed {
    obi_to_axi_r_chan_t r;
    logic               gnt;
    logic               rvalid;
  } obi_to_axi_rsp_t;

  localparam obi_pkg::obi_optional_cfg_t ObiToAxiOptionalCfg = '{
      UseAtop: 1'b0,
      UseMemtype: 1'b0,
      UseProt: 1'b0,
      UseDbg: 1'b0,
      AUserWidth: 0,
      WUserWidth: 0,
      RUserWidth: ObiRspUserWidth,
      MidWidth: 0,
      AChkWidth: 0,
      RChkWidth: 0
  };

  localparam obi_pkg::obi_cfg_t ObiToAxiCfg = '{
      UseRReady: 1'b0,
      CombGnt: 1'b0,
      AddrWidth: ObiAddrWidth,
      DataWidth: ObiDataWidth,
      IdWidth: ObiIdWidth,
      Integrity: 1'b0,
      BeFull: 1'b1,
      OptionalCfg: ObiToAxiOptionalCfg
  };

  obi_to_axi_req_t obi_to_axi_req;
  obi_to_axi_rsp_t obi_to_axi_rsp;

  logic [31:0] obi_addr_offset;
  logic [AxiAddrWidth-1:0] translated_axi_addr;

  assign obi_addr_offset = obi_req_i.addr - ObiWindowBaseAddr;
  assign translated_axi_addr = TranslateAddress ? AxiBaseAddr + AxiAddrWidth'(obi_addr_offset) :
                               AxiAddrWidth'(obi_req_i.addr);

  always_comb begin
    obi_to_axi_req = '0;

    obi_to_axi_req.req     = obi_req_i.req;
    obi_to_axi_req.a.addr  = obi_to_axi_addr_t'(translated_axi_addr);
    obi_to_axi_req.a.we    = obi_req_i.we;
    obi_to_axi_req.a.be    = obi_to_axi_be_t'(obi_req_i.be);
    obi_to_axi_req.a.wdata = obi_to_axi_data_t'(obi_req_i.wdata);
    obi_to_axi_req.a.aid   = '0;

    obi_to_axi_req.a.a_optional = '0;
  end

  assign obi_resp_o.gnt    = obi_to_axi_rsp.gnt;
  assign obi_resp_o.rvalid = obi_to_axi_rsp.rvalid;
  assign obi_resp_o.rdata  = obi_to_axi_rsp.r.rdata[31:0];

  obi_to_axi #(
      .ObiCfg      (ObiToAxiCfg),
      .obi_req_t   (obi_to_axi_req_t),
      .obi_rsp_t   (obi_to_axi_rsp_t),
      .AxiLite     (AxiLite),
      .AxiAddrWidth(AxiAddrWidth),
      .AxiDataWidth(AxiDataWidth),
      .AxiUserWidth(AxiUserWidth),
      .AxiBurstType(AxiBurstType),
      .axi_req_t   (axi_req_t),
      .axi_rsp_t   (axi_rsp_t),
      .MaxRequests (MaxRequests)
  ) obi_to_axi_i (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .obi_req_i(obi_to_axi_req),
      .obi_rsp_o(obi_to_axi_rsp),
      .user_i   (axi_user_i),

      .axi_req_o(axi_req_o),
      .axi_rsp_i(axi_rsp_i),

      .axi_rsp_channel_sel(),
      .axi_rsp_b_user_o   (),
      .axi_rsp_r_user_o   (),
      .obi_rsp_user_i     ('0)
  );

  // pragma translate_off
  `ifndef SYNTHESIS
    initial begin : gen_parameter_assertions
      assert (ObiDataWidth == 32)
      else $fatal(1, "xheep_obi_to_axi_bridge expects the current flat X-HEEP OBI data width.");

      assert (ObiAddrWidth <= AxiAddrWidth)
      else $fatal(1, "OBI address width must not exceed AXI address width.");

      assert (AxiDataWidth >= ObiDataWidth && AxiDataWidth % ObiDataWidth == 0)
      else $fatal(1, "AXI data width must be an integer multiple of OBI data width.");
    end
  `endif
  // pragma translate_on

endmodule : xheep_obi_to_axi_bridge
