module tt_um_TrainLED2_top(
  input wire [7:0] ui_in, // Dedicated inputs
  output wire [7:0] uo_out, // Dedicated outputs
  input wire [7:0] uio_in, // IOs: Input path
  output wire [7:0] uio_out, // IOs: Output path
  output wire [7:0] uio_oe, // IOs: Output enable path (active high 0=input, 1=output)
  input wire ena,
  input wire clk,
  input wire rst_n
);

// Instance 1
TrainLED2 TrainLED2_top1 (
  .clk(clk),
  .rst(~rst_n),
  .din(ui_in[0]),
  .dout(uo_out[0]),
  .led1(uo_out[1]),
  .led2(uo_out[2]),
  .led3(uo_out[3])
  );

// Instance 2 - Requires an additionall tile
// TrainLED2 TrainLED2_top2 (
//   .clk(clk),
//   .rst(~rst_n),
//   .din(uio_in[1]),
//   .dout(uio_out[4]),
//   .led1(uio_out[5]),
//   .led2(uio_out[6]),
//   .led3(uio_out[7])
//   );

endmodule