module lab1part2(a, b, c, out1, out2);
input a, b, c;  
output out1, out2;

// smtg
assign out1 = (a & ~b) | (b & c);
assign out2 = (a & b) | (b & c) | (a & c);

endmodule