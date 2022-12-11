module assign5(CLK, SW, PB, HEX0, HEX1, HEX2, HEX3);
input CLK;
input [5:0] SW, PB;
output [6:0] HEX0, HEX1, HEX2, HEX3;
reg [6:0] HEX0, HEX1, HEX2, HEX3;
wire [5:0] m, s, shot;
wire [7:0] Score1, Score2;
wire [7:0] bcd_score1, bcd_score2, bcd_shot, bcd_m, bcd_s;
wire [25:0] clk;

// converting bcd value to 7-segment display
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

// configure 7- segment display per display state
always @(*) begin 
	if (SW[3]) begin  // display main clock
		HEX0 = bcdto7seg(bcd_s[3:0]);
		HEX1 = bcdto7seg(bcd_s[7:4]);
		HEX2 = bcdto7seg(bcd_m[3:0]);
		HEX3 = bcdto7seg(bcd_m[7:4]);
	end
	else if (SW[4])  begin // display shot clock
		HEX0 = bcdto7seg(bcd_shot[3:0]);
		HEX1 = bcdto7seg(bcd_shot[7:4]);
		HEX2 = 7'b1111111;
		HEX3 = 7'b1111111;
	end
	else  begin // display score
		HEX0 = bcdto7seg(bcd_score1[3:0]);
		HEX1 = bcdto7seg(bcd_score1[7:4]);
		HEX2 = bcdto7seg(bcd_score2[3:0]);
		HEX3 = bcdto7seg(bcd_score2[7:4]);
	end					
end 

clock #26 clk50(CLK, 1, 50_000_000, clk);
basketball bbal(CLK, (clk == 50_000_000), SW, PB, Score1, Score2, m, s, shot);
bin2bcd cnvrtm(m, bcd_m);
bin2bcd cnvrts(s, bcd_s);
bin2bcd cnvrtsh(shot, bcd_shot);
bin2bcd cnvrts1(Score1, bcd_score1);
bin2bcd cnvrts2(Score2, bcd_score2);
endmodule

// clock module
module clock(CLK, START, STOP, Q);
parameter N = 26;
input CLK;
input [N-1:0] START, STOP;
output [N-1:0] Q;
reg [N-1:0] Q;
initial Q = START;
always @(posedge CLK) Q <= (Q==STOP) ? START : Q + 1;
endmodule

// bin2bcd module 
module bin2bcd(bin, bcd);
parameter N = 7;
parameter M = 28;
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

// main basketball module
module basketball(CLK, EN, SW, PB, Score1, Score2, m, s, shot);
input CLK, EN;
input [5:0] SW, PB;
output [7:0] Score1, Score2;
output [5:0] m, s, shot;
reg [7:0] Score1, Score2;
reg [5:0] m, s, shot;
initial begin m = 12; s = 0; shot = 24; Score1 = 0; Score2 = 0;end
always @(posedge CLK) begin
	if (EN) begin
		if (SW[5]) begin  // master reset 
			Score1 <= 0;
			Score2 <= 0; 
			m <= 12;
			s <= 0; 
			shot <= 24; 
		end
		else if (SW[0] && (SW[3] || SW[4])) begin // reset all
			m <= 12;
			s <= 0;
			shot <= 24; end
		else if (SW[4] && SW[2]) shot <= 24; // reset shot clock
		else if (SW[1] && (SW[3] || SW[4])) begin // countdown main clock and shot clock
			if (s == 0) begin s <= 59; m <= m - 1; end
			else	s <= s - 1;
			if (shot == 0) shot <= 24;
			else shot <= shot - 1; end
		else if (!SW[3] && !SW[4]) begin // increment or decrement scores
			if (!PB[0]) Score1 <= Score1 + 1;
			if (!PB[1]) Score1 <= Score1 - 1;
			if (!PB[2]) Score2 <= Score2 + 1;
			if (!PB[3]) Score2 <= Score2 - 1;
		end
	end
end
endmodule