module lab1bpart3a(w, x, y, z, f);
input w, x, y, z;
output f;

assign f = (y & ~z) |  (x & y) | (w & ~x);

endmodule 