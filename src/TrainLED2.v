
`default_nettype none

module TrainLED2(clk,rst,din,dout,led1,led2,led3);

input clk,rst;
input din; // Assumes noise filtered Din. This needs to be done either in digital domain, or analog domain  
output dout;
output led1,led2,led3;

wire dataready;

reg [3:0] finecount;
reg outdff;
reg [23:00] shiftregister;
reg [4:0] bitcount;
reg [7:0] resetcount;
reg [7:0] pwmcounter;
reg [1:0] mode;  // 0=receive, 1=forward, 2=reset

// PWM+SD engine
PWMEngine_SD PWM1 (.clk(clk),.rst(rst),.counter(pwmcounter[3:0]+4'h0),.PW_in(shiftregister[07:00] ),.dataready(dataready),.led(led1));
PWMEngine_SD PWM2 (.clk(clk),.rst(rst),.counter(pwmcounter[3:0]+4'h0),.PW_in(shiftregister[15:08] ),.dataready(dataready),.led(led2));
PWMEngine_SD PWM3 (.clk(clk),.rst(rst),.counter(pwmcounter[3:0]+4'h0),.PW_in(shiftregister[23:16] ),.dataready(dataready),.led(led3));

    always @(posedge clk)
        if (rst) begin
            finecount <= 0;
            outdff <= 0;
            // shiftregister <= 0;
            bitcount <= 0;
            mode <= 2;
            pwmcounter <=0;
            resetcount <=0;
        end
        else begin
            // PWM mastercounter
            pwmcounter <= pwmcounter + 1'b1;

            // clock&data recovery
            if ((finecount < 4'b1011) && (finecount > 4'b0000))
                    finecount <= finecount + 1'b1;
            else 
                if (din)
                    finecount <= finecount + 1'b1;
                else
                    if (~din)
                        finecount <= 0;

            // state machine
            if (mode == 2'b00) begin // handle data store (mode=0, receive)
                if (finecount == 4'b0110) begin
                    shiftregister <= {shiftregister[22:0], din};
                    bitcount <= bitcount + 1'b1;
                    if (bitcount == 5'b10111)
                        mode <= 2'b01;        
                end
                outdff <= 1'b0;
            end
            else 
                if (mode == 2'b10) begin  // mode reset (10)
                    if (din) begin
                        mode <= 2'b00;
                        bitcount <= 5'b00000;
                    end
                end 
                else begin // mode forward (01)         
                    case(finecount)
                        4'b0010: outdff <= 1'b1; 
                        4'b0110: outdff <= din;
                        4'b1010: outdff <= 1'b0;
                    endcase;
                    end

            // Handle reset. 
            // Resetcounter is increased while no bits arrive
            if (~din) begin
                resetcount <= resetcount + 1'b1;
                if (resetcount == 8'd96) begin  // reset after 8 bit times
                    mode <= 2'b10;
                end
            end 
            else 
                resetcount <= 0;
        end

assign dataready = (bitcount == 5'b11000) && (mode == 2'b10);
assign dout = outdff;

endmodule

module PWMEngine_SD(clk,rst,PW_in,counter,dataready,led);

input [7:0] PW_in;   
input [3:0] counter;  
input clk;
input rst;
input dataready;
output led;

reg LEDdff;
reg [7:0] datalatch;
reg [3:0] modulator;
wire [4:0] modnext;

    // always@(*)
    //     if (rst) begin
    //         datalatch <= 0;
    //     end 
    //     else if (counter[3:0] == 4'b1111 && dataready) begin
    //         if (clk)
    //             datalatch <= PW_in;
    //     end

	always @(posedge clk)
		if (rst) begin
            LEDdff <= 0;
            modulator <= 0;
            datalatch <= 0;
		end
		else begin

            // Main PWM engine. Attention: order of 'if clauses' is very important!
            if (counter == 4'b1111) begin  
                LEDdff <= modnext[4];
                modulator <= modnext[3:0];

                if (dataready) 
                    datalatch <= PW_in;     // use register instead of latch

            end
            else if (counter == datalatch[7:4])
                LEDdff <= 1'b0;
            else if (counter == 0)
                LEDdff <= 1'b1;
        end

assign modnext = {1'b0, modulator[3:0]} + {1'b0, datalatch[3:0]}; // Sigma Delta Modulator. Asynchronous assignment saves a DFF and reduces phase delay. 
                                                                  // Note that LED output is buffered in register, so data latch transparency will not cause glitches.
assign led = LEDdff;

endmodule
