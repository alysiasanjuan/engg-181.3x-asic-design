module assign1part2(s, m, a, b, out);
input [3:0] s;
input m;
input [1:0] a, b;
output [2:0] out;
reg [2:0] out;
reg [1:0] out2;



always @(*) begin
    if (m == 0) begin
        case (s)
            0000: out = a;
            0001: out = a | b;
            0010: begin
                out2 = ~b;
                out = a | out2;
                end
            0011: out = -1;
            0100: begin
                out2 = ~b;
                out = a + (a & out2);
                end
            0101: begin
                out2 = ~b; 
                out = (a | b) + (a & out2);
                end
            0110: out = a - b;
            0111: begin
                out2 = ~b ;
                out = (a & out2) - 1;
                end
            1000: out = a + (a & b);
            1001: out = a + b + 1;
            1010: begin
                out2 = ~b;
                out = (a | out2) + (a & b);
                end
            1011: out = (a & b) - 1;
            1100: out = a + a;
            1101: out = (a | b) + a;
            1110: begin
                out2 = ~b;
                out = (a | out2) + a;
                end
            1111: out = a - 1; //mali
            default: ;
        endcase
    end
    else begin
        case (s)
            0000: out2 = ~a;
            0001: out2 = ~(a | b); 
            0010: out2 = ~a & b;
            0011: out2 = 0;
            0100: out2 = ~(a &b);
            0101: out2 = ~b;
            0110: out2 = a ^ b;
            0111: out2 = a & ~b;
            1000: out2 = ~a | b;
            1001: out2 = ~(a ^ b);
            1010: out2 = b;
            1011: out2 = a & b;
            1100: out2 = 1;
            1101: out2 = a | ~b;
            1110: out2 = a | b;
            1111: out = a; // mali
            default: ;
        endcase
        out = out2;
    end
end

endmodule

