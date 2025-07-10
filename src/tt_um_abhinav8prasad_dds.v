`default_nettype none

module tt_um_abhinav8prasad_dds (
  input  wire [7:0] ui_in,        // 8-bit phase step input from user
  output wire [7:0] uo_out,       // DDS sine output to be connected to external R-2R ladder
  input  wire [7:0] uio_in,       // uio_in[0] = load_freq trigger; other bits unused
  output wire [7:0] uio_out,      // unused
  output wire [7:0] uio_oe,       // direction control for uio (all input)
  input  wire ena,                // always 1 when powered
  input  wire clk,                // system clock (66 MHz)
  input  wire rst_n               // active-low reset
);

  wire rst = ~rst_n; // Convert to active-high reset internally

  // Inputs
  wire load_freq = uio_in[0];      // Rising edge loads new frequency
  wire [7:0]  phase_val = ui_in;   // Frequency control word

  // Phase increment register
  reg [7:0] phase_inc;

  always @(posedge clk or posedge rst) begin
    if (rst)
      phase_inc <= 8'd1;           // default = lowest valid freq (≈ 258 kHz)
    else if (load_freq)
      phase_inc <= phase_val;
  end

  // DDS block
  wire [7:0] addr;
  wire [7:0] amplitude;

  phase_accumulator accum (
    .clk(clk),
    .reset(rst),
    .PHASE_INC(phase_inc),
    .addr(addr)
  );

  sine_lut lut (
    .addr(addr),
    .amplitude(amplitude)
  );

  // Outputs
  assign uo_out   = amplitude;  // Sine amplitude output
  assign uio_out  = 8'h00;      // uio unused
  assign uio_oe   = 8'h00;      // all uio pins configured as inputs

endmodule
