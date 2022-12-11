module lab5(CLK, SW, Q);
input CLK;
input [2:0] SW;
reg [2:0] SW_reg;
output [7:0] Q;
reg [7:0] Q, q;
initial Q=0;

// shift function

function [3:0] shift;
	input [3:0] Q;
	input left;
	begin
	 shift[3] = left ? Q[2] : 1;
	 shift[2] = left ? Q[1] : Q[3];
	 shift[1] = left ? Q[0] : Q[2];
	 shift[0] = left ? 1 : Q[1];
	 if (Q == 4'b1111) shift = 0;
	end
endfunction

always @(posedge CLK) begin 
  if (SW != SW_reg) Q = 0; // if state changed, reset Q to 0
  else Q <= q; 
end

always @(*) begin
	case (SW)
		0 : q <= 8'b00000000; // all off
		1 : begin // right shift
		  q[7:4] <= 4'b0000 ; 
		  q[3:0] <= shift(Q, 0); 
		  end 
		2 : begin // left shift
		  q[7:4] <= shift(Q[7:4], 1); 
		  q[3:0] <= 0000; 
		  end 
		3 : begin // both shift 
		  q[7:4] <= shift(Q[7:4], 1); 
		  q[3:0] <= shift(Q, 0); 
		  end 
		4 : q <= 8'b11111111; // all on
		5 : begin // right shift left on
		  q[7:4] <= 4'b1111 ; 
		  q[3:0] <= shift(Q, 0); 
		  end 
		6 : begin // left shift right on 
		  q[7:4] <= shift(Q[7:4], 1); 
		  q[3:0] <= 4'b1111; 
		  end 
		7 : begin // both shift 
		  q[7:4] <= shift(Q[7:4], 1); 
		  q[3:0] <= shift(Q, 0); 
		  end 
		default : q <= 8'b00000000; 
	endcase
	SW_reg <= SW;
end

endmodule

// test bench

module tblab5 ();

reg CLK;
reg [2:0] SW;
wire [7:0] Q;

lab5 tblab5(CLK, SW, Q);

always #10 CLK = ~CLK;

initial begin
    SW = 000; CLK = 0;
    #60 SW = 001;
    #70 SW = 010;
    #80 SW = 011;
    #90 SW = 100;
    #100 SW = 101;
    #110 SW = 110;
    #120 SW = 111;
    #130 $stop;
end
endmodule
