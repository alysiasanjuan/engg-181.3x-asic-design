module lab7(CLK, SW, PB, display1, display2);
input CLK;
input [4:0] SW, PB;
output [7:0] display1, display2;
reg [5:0] m, s, shot;
reg [7:0] Score1, Score2;
reg [7:0] display1, display2;

initial begin display1 = 0; display2 = 0; m = 12; s = 0; shot = 24; Score1 = 0; Score2 = 0;end

always @(*) begin // configure display
	if (SW[3]) begin  // display main clock
		display2 <= m;
		display1 <= s;
	end
	else if (SW[4])  begin // display shot clock
		display2 <= 0;
		display1 <= shot;
	end
	else  begin // display score
		display2 <= Score2;
		display1 <= Score1;
	end					
end 

always @(posedge CLK or negedge PB[4]) begin
	if (!PB[4]) begin  // master reset 
		Score1 <= 0;
		Score2 <= 0; 
		m <= 12;
		s <= 0; 
		shot <= 24; 
	end
	else if (SW[0] && (SW[3] || SW[4]))begin // reset main and shot clocks
		m <= 12;
		s <= 0;
		shot <= 24; end
	else if (SW[1] && (SW[3] || SW[4])) begin // countdown main clock and shot clock
		if (s == 0) begin s <= 59; m <= m - 1; end
		else	s <= s - 1;
		if (shot == 0) shot <= 24;
		else shot <= shot - 1; end
	else if (SW[4] && SW[2]) shot <= 24; // reset shot clock
	else begin
		if (!PB[0]) Score1 <= Score1 + 1;
		if (!PB[1]) Score1 <= Score1 - 1;
		if (!PB[2]) Score2 <= Score2 + 1;
		if (!PB[3]) Score2 <= Score2 - 1;
	end
end

endmodule

// test bench

module tblab7 ();

reg CLK;
reg [4:0] SW, PB;
wire [7:0] display1, display2;

lab7 tblab7(CLK, SW, PB, display1, display2);

always begin
  #10 CLK = ~CLK;					
end

initial begin
    CLK = 0; SW = 0; PB = 5'b11111;
    #30 PB[0] = 0; PB[0] = 0;
    #90 PB[0] = 1; PB[0] = 1;
    #30 PB[1] = 0; PB[1] = 0;
    #30 PB[1] = 1; PB[1] = 1;
    #30 PB[2] = 0; PB[2] = 0;
    #90 PB[2] = 1; PB[2] = 1;
    #30 PB[3] = 0; PB[3] = 0;
    #90 PB[3] = 1; PB[3] = 1;
    #30 SW[1] = 1; SW[3] = 1;
    #130 SW[3] = 0; SW[4] = 1;
    #130 SW[1] = 0;
    #50 SW[2] = 1;
    #130 $stop;
end
endmodule