// Copyright 2019 ETH Zurich and University of Bologna.
//
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Author: Robert Balas (balasr@iis.ee.ethz.ch)

`include "axi/assign.svh"

package automatic soc_node_pkg;
  localparam int unsigned N_SLAVES = 4;
  localparam int unsigned N_MASTERS = 3;

  // function int unsigned axi_iw_oup(input int unsigned axi_iw);
  //   return axi_iw + $clog2(N_SLAVES);
  // endfunction // axi_iw_oup

endpackage // soc_node_pkg

module soc_node #(
  parameter int unsigned  AXI_AW = 0,               // [bit]
  parameter int unsigned  AXI_DW = 0,               // [bit]
  parameter int unsigned  AXI_UW = 0,               // [bit]
  parameter int unsigned  AXI_IW_INP = 0,            // [bit]
  parameter int unsigned  AXI_IW_OUP = 0,            // [bit]
  parameter int unsigned  MST_SLICE_DEPTH = 0,
  parameter int unsigned  SLV_SLICE_DEPTH = 0
) (
  input  logic   clk_i,
  input  logic   rst_ni,
  // AXI_BUS.Slave  cl_slv
  AXI_BUS.Slave  cl_slv,
  AXI_BUS.Master soc_mst,
  AXI_BUS.Slave  c07_slv,
  AXI_BUS.Master c07_mst,
  AXI_BUS.Slave  nocr07_slv,
  AXI_BUS.Master nocr07_mst,
  AXI_BUS.Slave  sms_slv
);

  localparam int unsigned N_REGIONS = 1;

  localparam int unsigned IDX_SOC = 0;
  localparam int unsigned IDX_C07 = 1;
  localparam int unsigned IDX_NOCR07 = 2;
  localparam int unsigned IDX_CLUSTER = 3;


  typedef logic [AXI_AW-1:0] addr_t;

  addr_t  [N_REGIONS-1:0][soc_node_pkg::N_MASTERS-1:0]  start_addr,
                                                        end_addr;
  // logic   [N_REGIONS-1:0][soc_node_pkg::N_MASTERS-1:0]  valid_rule;

  AXI_BUS #(
    .AXI_ADDR_WIDTH (AXI_AW),
    .AXI_DATA_WIDTH (AXI_DW),
    .AXI_ID_WIDTH   (AXI_IW_OUP),
    .AXI_USER_WIDTH (AXI_UW)
  ) masters [soc_node_pkg::N_MASTERS-1:0]();

  AXI_BUS #(
    .AXI_ADDR_WIDTH (AXI_AW),
    .AXI_DATA_WIDTH (AXI_DW),
    .AXI_ID_WIDTH   (AXI_IW_INP),
    .AXI_USER_WIDTH (AXI_UW)
  ) slaves [soc_node_pkg::N_SLAVES-1:0]();

  `AXI_ASSIGN(soc_mst, masters[IDX_SOC]);
  `AXI_ASSIGN(c07_mst, masters[IDX_C07]);
  `AXI_ASSIGN(nocr07_mst, masters[IDX_NOCR07]);
  //`AXI_ASSIGN(cl_mst, masters[IDX_CLUSTER]);

  `AXI_ASSIGN(slaves[0], c07_slv);
  `AXI_ASSIGN(slaves[1], nocr07_slv);
  `AXI_ASSIGN(slaves[2], sms_slv);
  `AXI_ASSIGN(slaves[3], cl_slv);

  // Address Map
  always_comb begin
    start_addr  = '0;
    end_addr    = '0;
    // valid_rule  = '0;

    // Cluster
    // start_addr[0][IDX_CLUSTER] = 32'h1000_0000;
    // end_addr[0][IDX_CLUSTER]   = start_addr[0][IDX_CLUSTER] + 32'h002F_FFFF;
    // valid_rule[0][IDX_CLUSTER] = 1'b1;

    // SoC
    start_addr[0][IDX_SOC] = 32'h1C00_0000;
    end_addr[0][IDX_SOC]   = 32'h1FFF_FFFF; // NOTE: 0x1c091FFF is normally the upper limit
    // valid_rule[0][IDX_SOC] = 1'b1;

    // c07
    start_addr[0][IDX_C07] = 32'h2000_0000;
    end_addr[0][IDX_C07]   = 32'h4000_0000; // NOTE: arbitrarily assigned this range
    // valid_rule[0][IDX_C07] = 1'b1;

    // NoCr07
    start_addr[0][IDX_NOCR07] = 32'h4000_0000;
    end_addr[0][IDX_NOCR07]   = 32'hFFFF_FFFF; // NOTE: map everything else to global memory
    // valid_rule[0][IDX_NOCR07] = 1'b1;

  end

  // TODO: we use a version that doesn't support region or valid rules. For that
  // we would have to go to the atop branch
  axi_node_wrap_with_slices #(
    .NB_MASTER          (soc_node_pkg::N_MASTERS),
    .NB_SLAVE           (soc_node_pkg::N_SLAVES),
    // .NB_REGION          (N_REGIONS),
    .AXI_ADDR_WIDTH     (AXI_AW),
    .AXI_DATA_WIDTH     (AXI_DW),
    .AXI_ID_WIDTH       (AXI_IW_INP),
    .AXI_USER_WIDTH     (AXI_UW),
    .MASTER_SLICE_DEPTH (MST_SLICE_DEPTH),
    .SLAVE_SLICE_DEPTH  (SLV_SLICE_DEPTH)
  ) i_axi_node_wrap (
    .clk          (clk_i),
    .rst_n        (rst_ni),
    .test_en_i    (1'b0),
    .slave        (slaves),
    .master       (masters),
    .start_addr_i (start_addr),
    .end_addr_i   (end_addr)
    // .valid_rule_i (valid_rule)
  );

endmodule
