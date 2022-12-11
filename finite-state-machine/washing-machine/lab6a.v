module lab6a(CLK, C, DW, L, state, t);
input CLK, C, DW, L;
output [2:0] state, t;
reg [2:0] state, t;
reg T;
initial begin t = 0; state = 0; end

always @(posedge CLK) begin
	T <= (t == 1) ? 1 : 0;
	case (state)
		0 : if (C==1) state<=1; // idle
		1 : begin if (T == 1) begin state <= 2; t <= 0; end else t <= t + 1; end // soak
		2 : begin if (T == 1) begin state <= 3; t <= 0; end else t <= t + 1; end // wash 1
		3 : begin if (T == 1) begin if (DW == 1) state <= 4; else state <= 6; t <= 0; end else t <= t + 1; end // rinse 1
		4 : begin if (T == 1) begin state <= 5; t <= 0; end else t <= t + 1; end // wash 2
		5 : begin if (T == 1) begin state <= 6; t <= 0; end else t <= t + 1; end  // rinse 2
		6 : begin if (L == 1) state <= 7; else if (T == 1) begin state <= 0; t <= 0; end else t <= t + 1; end //spin
		7 : if (L == 0) state <= 6; //stop
		default : state <= 0; 
	endcase
	
end
endmodule

// test bench

module tblab6a ();

reg CLK, C, DW, L;
wire [2:0] state, t;

lab6a tblab6a(CLK, C, DW, L, state, t);

always #10 CLK = ~CLK;

initial begin
    CLK = 0; C = 0; DW = 0; L = 0;
    #20 C = 1;
    #30 C = 0;
    #140 DW = 1;
    #30 DW = 0;
    #150 L = 1;
    #50 L = 0;
    #1590 $stop;
end
endmodule