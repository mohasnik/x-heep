// Copyright (C) 2013-2018 ETH Zurich, University of Bologna
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Author: Manuel Eggimann <meggimann@iis.ee.ethz.ch>

// Description: This module calculates the hamming weight (number of ones) in
// its input vector. Any unsigned INPUT_WIDTH larger or equal 1 is legal. The output result
// width is ceil(log2(INPUT_WIDTH))+1.
//
// This module used to be implemented using a binary added tree. However,
// the heuristics of modern logic Synthesizers work much better with a flat high
// level description using a for loop and yield exactly the same or even better results.


module popcount #(
    parameter  int unsigned INPUT_WIDTH   = 256,
    localparam int unsigned PopcountWidth = $clog2(INPUT_WIDTH) + 1
) (
    input  logic [  INPUT_WIDTH-1:0] data_i,
    output logic [PopcountWidth-1:0] popcount_o
);

<<<<<<< HEAD
  localparam int unsigned PaddedWidth = 1 << $clog2(INPUT_WIDTH);

  logic [PaddedWidth-1:0] padded_input;
  logic [PopcountWidth-2:0] left_child_result, right_child_result;

  //Zero pad the input to next power of two
  always_comb begin
    padded_input = '0;
    padded_input[INPUT_WIDTH-1:0] = data_i;
  end

  //Recursive instantiation to build binary adder tree
  if (INPUT_WIDTH == 1) begin : gen_single_node
    assign left_child_result  = 1'b0;
    assign right_child_result = padded_input[0];
  end else if (INPUT_WIDTH == 2) begin : gen_leaf_node
    assign left_child_result  = padded_input[1];
    assign right_child_result = padded_input[0];
  end else begin : gen_non_leaf_node
    popcount #(
        .INPUT_WIDTH(PaddedWidth / 2)
    ) left_child (
        .data_i(padded_input[PaddedWidth-1:PaddedWidth/2]),
        .popcount_o(left_child_result)
    );

    popcount #(
        .INPUT_WIDTH(PaddedWidth / 2)
    ) right_child (
        .data_i(padded_input[PaddedWidth/2-1:0]),
        .popcount_o(right_child_result)
    );
  end

  //Output assignment
  assign popcount_o = left_child_result + right_child_result;
=======
  if (INPUT_WIDTH < 1)
    $error("INPUT_WIDTH must be larger or equal to 1.");

  always_comb begin
    popcount_o = 0;
    for (int i = 0; i < INPUT_WIDTH; i++) begin
      popcount_o += data_i[i];
    end
  end
>>>>>>> main

endmodule : popcount
