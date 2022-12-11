module lab4b(CLK, CLRn, S, SL, SR, Q, ABCD);
input CLK, CLRn, SL, SR;
input [1:0] S;
input [3:0] ABCD;
output [3:0] Q;
reg [3:0] Q, q;
initial Q=0;


function [3:0] shift;
	input [3:0] Q;
	input left;
	input serial;
	begin
	 shift[3] = left ? Q[2] : serial;
	 shift[2] = left ? Q[1] : Q[3];
	 shift[1] = left ? Q[0] : Q[2];
	 shift[0] = left ? serial : Q[1];
	 if (Q == 4'b1111) shift = 0;
	end
endfunction

always @(posedge CLK) Q <= q;

always @(*) begin
	if (!CLRn)	q <= 0; // clear
	else begin 
		case (S) 
			2'b00 : q <= Q; // do nothing
			2'b01 : q <= shift(Q, 0, SL); // shift left
			2'b10 : q <= shift(Q, 1, SR); // shift right
			2'b11 : q <= ABCD; // parallel load
			default: q <= Q;
		endcase
	end
end

endmodule

//test-bench

module tb ();

reg CLK, CLRn, SL, SR;
reg [1:0] S;
reg [3:0] ABCD;
wire [3:0] Q;

lab4b tb(CLK, CLRn, S, SL, SR, Q, ABCD);

always #10 CLK = ~CLK;

initial begin
	CLRn = 1; S = 00; ABCD = 1000; CLK = 0; SL = 1; SR = 1;
	#30 S = 10;
	#50 CLRn = 0;
	#50 CLRn = 1;
	#70 SR = 0;
	#70 S = 01;
	#70 SL = 0;
	#70 S = 11;
	#500 $stop;
end

endmodule

