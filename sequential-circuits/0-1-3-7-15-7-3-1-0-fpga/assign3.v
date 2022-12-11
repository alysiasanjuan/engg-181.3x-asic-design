module assign3(CLK, LEDR, HEX0, HEX1);
input CLK;
output [3:0] LEDR;
output [6:0] HEX0, HEX1;
wire [15:0] bcd;
wire [25:0] clk;

function [6:0] bcdto7seg;
	input [4:0] bcd;
	case (bcd)
		0:  bcdto7seg = 7'b1000000; 
		1:  bcdto7seg = 7'b1111001; 
		2:  bcdto7seg = 7'b0100100; 
		3:  bcdto7seg = 7'b0110000; 
		4:  bcdto7seg = 7'b0011001; 
		5:  bcdto7seg = 7'b0010010; 
		6:  bcdto7seg = 7'b0000010; 
		7:  bcdto7seg = 7'b1111000; 
		8:  bcdto7seg = 7'b0000000; 
		9:  bcdto7seg = 7'b0010000;
		default:  bcdto7seg = 7'b1111111; 						
	endcase
endfunction

clock #26 clk50(CLK, 1, 50_000_000, clk);
shift shiftct((clk==50_000_000), LEDR);
//shift shiftct(CLK, LEDR);

assign HEX0 = bcdto7seg(bcd[3:0]);
assign HEX1 = bcdto7seg(bcd[7:4]);

endmodule

// clock module

module clock(CLK, START, STOP, Q);
parameter N = 26;
input CLK;
input [N-1:0] START, STOP;
output [N-1:0] Q;
reg [N-1:0] Q;
 
initial Q = START;

always @(posedge CLK) begin
	if (Q==STOP) Q <= START;
	else         Q <= Q + 1;
end
endmodule

// bin2bcd module 

module bin2bcd(bin, bcd);
parameter N = 10;
parameter M = 16;
input [N-1:0] bin;
output [M-1:0] bcd;
reg [M-1:0] bcd;
integer i, j;

always @(*) begin
	for (i = 0; i <= M-1; i = i+1) bcd[i] = 0;
	bcd[N-1:0] = bin;
	for(i = 0; i <= N-4; i = i+1)                       
      for(j = 0; j <= i/3; j = j+1)                     
        if (bcd[N-i+4*j -: 4] > 4) bcd[N-i+4*j -: 4] = bcd[N-i+4*j -: 4] + 4'd3; 
end

endmodule

// shift module

module shift(CLK, Q);
input CLK;
output [3:0] Q;
reg [3:0] Q;
reg up = 1;

always @(posedge CLK) begin
case(Q)
	4'b0000: begin Q <= 4'b0001; up = 1; end
	4'b0001: Q <= up ? 4'b0011 : 4'b0000;
	4'b0011: Q <= up ? 4'b0111 : 4'b0001;
	4'b0111: Q <= up ? 4'b1111 : 4'b0011;
	4'b1111: begin Q <= 4'b0111; up = 0; end
	default: Q <= 4'b0000; 
endcase
end

endmodule


	