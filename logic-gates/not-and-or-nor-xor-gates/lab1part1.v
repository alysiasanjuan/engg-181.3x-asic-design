module lab1part1(a, b, not1, and1, or1, nor1, xor1);
input a, b;  
output not1, and1, or1, nor1, xor1;

//structural design
not (not1, a);
and (and1, a, b);
or (or1, a, b);
nor (nor1, a, b);
xor (xor1, a, b);

endmodule