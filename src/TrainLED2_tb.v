`timescale 1ns / 10ps

// MCPU5 testbench
// File ending changed to *.vtb to hide from github action

module TrainLED_tb;

wire dout;
wire led1,led2,led3;

reg clk, reset;
reg din;

// assign io_in = {inst_inputn, reset, clk};

TrainLED2 TrainLED2_top (clk,reset,din,dout,led1,led2,led3);

initial begin
  $dumpfile("TrainLED_tb.vcd");
  $dumpvars(0, TrainLED_tb);
end

initial begin
   #160000; // Wait a long time in simulation units (adjust as needed).
   $display("Caught by trap");
   $finish;
 end

parameter CLK_FREQ_KHZ=9600;
parameter TCLK= 1E6/CLK_FREQ_KHZ;
parameter CLK_HALF_PERIOD = TCLK/2;
// parameter TCLK = 2*CLK_HALF_PERIOD;
parameter OCLK = 4*TCLK;
parameter DCLK = 4*TCLK;

always begin
    clk = 1'b1;
    #(CLK_HALF_PERIOD);
    clk = 1'b0;
    #(CLK_HALF_PERIOD);
end


task write_byte;
  input [7:0] bytein;
  // output dx;
  integer i;

  begin
    $display("Sending byte: %h",bytein);

    for (i=0; i<8; i=i+1) begin
      din = 1;
      #(DCLK);
      din = bytein[7-i];
      #(DCLK);
      din = 0;
      #(DCLK);
    end
  end
endtask

task pulse_sweep;
  integer i;
  
  begin
    $display("Pulse length sweep.");
    for (i=0; i<16; i=i+1) begin
      din = 1;
      #(TCLK*i);
      din = 0;
      #(DCLK);
      #(DCLK);
      #(DCLK);
    end
  end
endtask

initial  begin
    din = 0;
    #(CLK_HALF_PERIOD);
    reset = 1;
    #(DCLK*2);
    reset = 0;
    #(DCLK*2);
  
    write_byte(1);
      #(DCLK*2);
    write_byte(4);
      #(DCLK*4);
    write_byte(27);
      #(DCLK*4);
    write_byte(8'h55);
      #(DCLK*4);
//   pulse_sweep();
end


endmodule
