module lab6b(CLK, SPEED, PLAYER1, PLAYER2, Q, SCORE1, SCORE2);
input CLK, PLAYER1, PLAYER2;
input [1:0] SPEED;
output [10:0] Q;
output [3:0] SCORE1, SCORE2;
reg left = 0, alternate = 0;
reg [2:0] game;
reg [3:0] SCORE1, SCORE2;
reg [10:0] Q;

initial begin Q = 0; SCORE1 = 0; SCORE2 = 0; end

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
			if (!PLAYER1 && !PLAYER2) game <= 2;
		end
		1: begin // game play mode, ball shifts, if buttons are pressed return ball, if not point to other player -> new round mode (state 2)
			if (Q > 10'b1000000000) begin SCORE1 <= SCORE1 + 1; game <= 2; end
			if (Q < 10'b0000000001) begin SCORE2 <= SCORE2 + 1; game <= 2; end
			Q <= shift(Q, left);
			if ((Q == 10'b0000000001 || Q == 10'b0000000010) && !PLAYER1) left <= 1;
			if ((Q == 10'b1000000000 || Q == 10'b0100000000) && !PLAYER2) left <= 0;
		end
		2: begin // new round mode, set direction of ball to alternate directions -> game play mode (state 1)
			Q <= (alternate) ? 10'b0000010000 : 10'b0000100000;
			left <= (alternate) ? 1 : 0;
			alternate <= ~alternate;
			game <= 1;
		end
		3: begin // game over mode -> press both buttons to return to idle mode (state 2) and play again 
			Q <= 10'b1111111111;
			if (!PLAYER1 && !PLAYER2) begin game <= 2; SCORE1 <= 0; SCORE2 <= 0; end
		end
		default: game <= 0;
	endcase 
	if (SCORE1 == 3 || SCORE2 == 3) game <= 3; // first to 3 wins
end

endmodule

// test bench

module tblab6b ();

reg CLK, PLAYER1, PLAYER2;
reg [1:0] SPEED;
wire [10:0] Q;
wire [3:0] SCORE1, SCORE2;

lab6b tblab6b(CLK, SPEED, PLAYER1, PLAYER2, Q, SCORE1, SCORE2);

always begin
  case (SPEED)
		0:  #5 CLK = ~CLK;
		1:  #10 CLK = ~CLK;
		2:  #20 CLK = ~CLK;
		3:  #30 CLK = ~CLK;
		default:  #10 CLK = ~CLK;					
	endcase
end

initial begin
    SPEED = 0; CLK = 0; PLAYER1 = 1; PLAYER2 = 1;
    #30 PLAYER1 = 0; PLAYER2 = 0;
    #30 PLAYER1 = 1; PLAYER2 = 1;
    #200 SPEED = 1;
    #130 $stop;
end
endmodule
