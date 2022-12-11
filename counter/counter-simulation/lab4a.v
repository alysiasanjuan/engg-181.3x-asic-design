module lab4a(CLK, UDn, LOADn, CTENn, S, Q, MAXMIN, RCOn);
input CLK, UDn, LOADn, CTENn;
input [3:0] S;
output reg[3:0] Q;
output reg MAXMIN, RCOn;
//initial Q=0;

always @(posedge CLK) begin
	if (!LOADn) Q <= S;
	else if (!CTENn) begin
		if ((Q==9 && !UDn)||(Q==0 && UDn)) begin
			Q <= (!UDn) ? 0 : 9;
			MAXMIN <= 1;
		end
		else begin
			Q <= (!UDn) ? Q + 1 : Q - 1;
			MAXMIN <= 0;
		end
		RCOn <= ~MAXMIN;
	end
end

endmodule 

//testbench

module tb1();
reg CLK, UDn, LOADn, CTENn;
reg [3:0] S;
wire [3:0] Q;
wire MAXMIN, RCOn;

lab4a tb(CLK, UDn, LOADn, CTENn, S, Q, MAXMIN, RCOn);

always #20  CLK = ~CLK;

initial begin
  UDn=0; LOADn=1; CTENn=0; CLK=0; S=0; 
  #100 S=4'b0010; LOADn=0;
  #50 LOADn=1;
  #100 UDn=1;
  #100 CTENn=1;
  #50 CTENn=0;
  #200 $stop;
end
endmodule