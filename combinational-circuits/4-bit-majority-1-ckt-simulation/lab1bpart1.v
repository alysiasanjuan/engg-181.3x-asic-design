module lab1bpart1(a, b, c, d, out);
input a, b, c, d;
output out;

assign out =  (a & c & d) | (b & c & d) | (a & b & c) | (a & b & d);

endmodule 