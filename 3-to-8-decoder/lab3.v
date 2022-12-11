module lab3(g1, a, b, c, y);
input g1, a, b, c;
output [7:0] y;

assign y[0] = (~g1) | a | b | c;
assign y[1] = (~g1) | a | b | (~c);
assign y[2] = (~g1) | a | (~b) | c;
assign y[3] = (~g1) | a | (~b) | (~c);
assign y[4] = (~g1) | (~a) | b | c;
assign y[5] = (~g1) | (~a) | b | (~c);
assign y[6] = (~g1) | (~a) | (~b) | c;
assign y[7] = (~g1) | (~a) | (~b) | (~c);

endmodule 