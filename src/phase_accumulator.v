`default_nettype none

module phase_accumulator (
  input  wire clk,
  input  wire reset,
  input  wire [7:0] PHASE_INC,
  output reg  [7:0] addr
);

  always @(posedge clk or posedge reset) begin
    if (reset)
      addr <= 8'd0;
    else
      addr <= addr + PHASE_INC;
  end

endmodule
