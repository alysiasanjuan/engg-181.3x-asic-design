module lab1bpart2(e, w, d, a);
input e, w, d;
output a;

reg a;
always @(*)
  if ((e & w) | (e & d)) 
    a = 1;
  else     
    a = 0;

endmodule 