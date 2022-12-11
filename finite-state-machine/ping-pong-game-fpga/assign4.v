module assign4(CLK, SW, PB, LEDR, HEX0, HEX1, HEX2, HEX3, LEDG);
input CLK;
input [1:0] SW, PB;
output [6:0] HEX0, HEX1, HEX2, HEX3;
output [10:0] LEDR, LEDG;
reg [6:0] HEX0, HEX1, HEX2, HEX3;
reg [25:0] speed;
wire [2:0] game;
wire [3:0] bcd1, bcd2, score1, score2;
wire [25:0] clk;

function [6:0] bcdto7seg; // converting bcd value to 7-segment display
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

always @(*) begin // set speed by switches
	case (SW)
		0:  speed <= 14_000_000;
		1:  speed <= 28_000_000;
		2:  speed <= 42_000_000;
		3:  speed <= 56_000_000;
		default:  speed <= 25_000_000;					
	endcase
end

always @(*) begin // 7- segment display per game state
	case (game)
		0:  begin  //idle mode, display "PLAY" 
			HEX0 = 7'b0010001;
			HEX1 = 7'b0001000;
			HEX2 = 7'b1000111;
			HEX3 = 7'b0001100;
		end
		3:  begin //game over mode, display "1111" or "2222" for winner
			if (score1 > score2) begin
				HEX0 = 7'b1111001; 
				HEX1 = 7'b1111001;
				HEX2 = 7'b1111001;
				HEX3 = 7'b1111001;
			end
			else begin
				HEX0 = 7'b0100100; 
				HEX1 = 7'b0100100;
				HEX2 = 7'b0100100;
				HEX3 = 7'b0100100;
			end
		end
		default:  begin // game running, display score
			HEX0 = bcdto7seg(bcd1[3:0]);
			HEX1 = 7'b0111111;
			HEX2 = 7'b0111111;
			HEX3 = bcdto7seg(bcd2[3:0]);
		end					
	endcase
end 

clock #26 clk50(CLK, 1, speed, clk);
pong pongstate((clk == speed), LEDR, PB, score1, score2, LEDG, game);
//pong ponggame(CLK, LEDR, PB, score1, score2, LEDG, game);
bin2bcd cnvrt1(score1, bcd1);
bin2bcd cnvrt2(score2, bcd2);
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
parameter N = 4;
parameter M = 5;
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

// pong module

module pong(CLK, Q, PB, score1, score2, check, game);
input CLK;
input [1:0] PB;
output [2:0] game;
output [3:0] score1, score2;
output [10:0] Q, check;
reg left, alternate;
reg [2:0] game;
reg [3:0] score1, score2;
reg [10:0] Q, check;

function [10:0] shift;
	input [10:0] Q;
	input left;
	integer i;
	begin
	 shift[10] = left ? Q[9] : 0; 
	 for (i=1; i < 10; i=i+1) shift[i] = left ? Q[i-1] : Q[i+1];
	 shift[0] = left ? 0 : Q[1];
	end
endfunction

always @(posedge CLK) begin	
	case (game)
		0: begin //idle mode, press both buttons to begin -> new round mode (state 2)
			if (!PB[0] && !PB[1]) begin game <= 2; check <= 8'b11111111; end
		end
		1: begin // game play mode, ball shifts, if buttons are pressed return ball, if not point to other player -> new round mode (state 2)
			check <= 0;
			if (Q > 10'b1000000000) begin score1 <= score1 + 1; game <= 2; end
			if (Q < 10'b0000000001) begin score2 <= score2 + 1; game <= 2; end
			Q <= shift(Q, left);
			if ((Q == 10'b0000000001 || Q == 10'b0000000010) && !PB[0]) begin left <= 1; check <= 8'b11111111; end
			if ((Q == 10'b1000000000 || Q == 10'b0100000000) && !PB[1]) begin left <= 0; check <= 8'b11111111; end 
		end
		2: begin // new round mode, set direction of ball to alternate directions -> game play mode (state 1)
			Q <= (alternate) ? 10'b0000010000 : 10'b0000100000;
			left <= (alternate) ? 1 : 0;
			alternate <= ~alternate;
			game <= 1;
		end
		3: begin // game over mode -> press both buttons to return to idle mode (state 2) and play again 
			Q <= 10'b1111111111;
			check <= 8'b11111111;
			if (!PB[0] && !PB[1]) begin game <= 2; score1 <= 0; score2 <= 0; check <= 0; end
		end
		default: game <= 0;
	endcase 
	if (score1 == 3 || score2 == 3) game <= 3; // first to 3 wins
end

endmodule