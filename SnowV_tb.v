`timescale 1ns/1ps




module SnowV_tb;
reg                   clk;
reg                   rst_n;
reg           [255:0] key;
reg           [127:0] iv;
reg           [63:0]  length;
reg                   start;


wire                  valid;
wire          [255:0] z;


always #5 clk=~clk;
initial
begin
rst_n=1'b1;
#10
rst_n=1'b0;
clk=1'b0;
start=1'b0;
#41
rst_n=1'b1;
key=256'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
iv=128'hffffffffffffffffffffffffffffffff;
length=64'd32;
#10
start=1'b1;
#10
start=1'b0;


#1000
$finish;
end



SNOW_V u1(
.clk(clk),
.rst_n(rst_n),
.key(key),
.iv(iv),
.length(length),  
.start(start),


.valid(valid),
.z(z)
);







endmodule