module lab2(a, b, out1, out2, out3, out4, out5);
input [1:0] a, b;
output [1:0] out1, out2, out5;
output [2:0] out3;
output [3:0] out4;

assign out1 = a & b;
assign out2 = a | b;
assign out3 = a + b;
assign out4 = a * b;
assign out5 = a / b;

endmodule 

//testbench

module tb1();
reg [1:0] a, b;
wire [1:0] out1, out2, out5;
wire [2:0] out3;
wire [3:0] out4;
 
lab2 dut2(a, b, out1, out2, out3, out4, out5);

initial
begin
  a=00; b=11;
  #100 a=01; b=10;
  #100 a=10; b=01; 
  #100 a=11; b=01; 
  #100 a=00; b=01; 
  #100 $stop;
end
  
endmodule