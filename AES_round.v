`timescale 1ns/1ps





module AES_round(
input      [127:0] plaintext,
/*
input      [127:0] key,    //not used in SnowV
*/


output wire [127:0] ciphertext
);
//used in this module
wire [7:0] sbox0_out;
wire [7:0] sbox1_out;
wire [7:0] sbox2_out;
wire [7:0] sbox3_out;
wire [7:0] sbox4_out;
wire [7:0] sbox5_out;
wire [7:0] sbox6_out;
wire [7:0] sbox7_out;
wire [7:0] sbox8_out;
wire [7:0] sbox9_out;
wire [7:0] sbox10_out;
wire [7:0] sbox11_out;
wire [7:0] sbox12_out;
wire [7:0] sbox13_out;
wire [7:0] sbox14_out;
wire [7:0] sbox15_out;
wire [7:0] r0_new;
wire [7:0] r1_new;
wire [7:0] r2_new;
wire [7:0] r3_new;
wire [7:0] r4_new;
wire [7:0] r5_new;
wire [7:0] r6_new;
wire [7:0] r7_new;
wire [7:0] r8_new;
wire [7:0] r9_new;
wire [7:0] r10_new;
wire [7:0] r11_new;
wire [7:0] r12_new;
wire [7:0] r13_new;
wire [7:0] r14_new;
wire [7:0] r15_new;
wire [7:0] cipher0;
wire [7:0] cipher1;
wire [7:0] cipher2;
wire [7:0] cipher3;
wire [7:0] cipher4;
wire [7:0] cipher5;
wire [7:0] cipher6;
wire [7:0] cipher7;
wire [7:0] cipher8;
wire [7:0] cipher9;
wire [7:0] cipher10;
wire [7:0] cipher11;
wire [7:0] cipher12;
wire [7:0] cipher13;
wire [7:0] cipher14;
wire [7:0] cipher15;

assign r0_new=sbox0_out;
assign r1_new=sbox5_out;
assign r2_new=sbox10_out;
assign r3_new=sbox15_out;
assign r4_new=sbox4_out;
assign r5_new=sbox9_out;
assign r6_new=sbox14_out;
assign r7_new=sbox3_out;
assign r8_new=sbox8_out;
assign r9_new=sbox13_out;
assign r10_new=sbox2_out;
assign r11_new=sbox7_out;
assign r12_new=sbox12_out;
assign r13_new=sbox1_out;
assign r14_new=sbox6_out;
assign r15_new=sbox11_out;


assign cipher0=aes_mul2(r0_new)^aes_mul3(r1_new)^r2_new^r3_new;
assign cipher4=aes_mul2(r4_new)^aes_mul3(r5_new)^r6_new^r7_new;
assign cipher8=aes_mul2(r8_new)^aes_mul3(r9_new)^r10_new^r11_new;
assign cipher12=aes_mul2(r12_new)^aes_mul3(r13_new)^r14_new^r15_new;
assign cipher1=r0_new ^aes_mul2(r1_new )^aes_mul3(r2_new )^r3_new ;
assign cipher5=r4_new ^aes_mul2(r5_new )^aes_mul3(r6_new )^r7_new ;
assign cipher9=r8_new ^aes_mul2(r9_new )^aes_mul3(r10_new)^r11_new;
assign cipher13=r12_new^aes_mul2(r13_new)^aes_mul3(r14_new)^r15_new;
assign cipher2=r0_new^r1_new^aes_mul2(r2_new)^aes_mul3(r3_new);
assign cipher6=r4_new^r5_new^aes_mul2(r6_new)^aes_mul3(r7_new);
assign cipher10=r8_new^r9_new^aes_mul2(r10_new)^aes_mul3(r11_new);
assign cipher14=r12_new^r13_new^aes_mul2(r14_new)^aes_mul3(r15_new);
assign cipher3=aes_mul3(r0_new)^r1_new^r2_new^aes_mul2(r3_new);
assign cipher7=aes_mul3(r4_new)^r5_new^r6_new^aes_mul2(r7_new);
assign cipher11=aes_mul3(r8_new)^r9_new^r10_new^aes_mul2(r11_new);
assign cipher15=aes_mul3(r12_new)^r13_new^r14_new^aes_mul2(r15_new);


assign ciphertext={cipher15,cipher14,cipher13,cipher12,cipher11,cipher10,cipher9,cipher8,
                   cipher7,cipher6,cipher5,cipher4,cipher3,cipher2,cipher1,cipher0};



function [7:0] aes_mul2;
input [7:0]a;
begin
    aes_mul2=a>127?((a<<1)^7'd27):(a<<1);
end
endfunction


function [7:0] aes_mul3;
input [7:0]a;
begin
    aes_mul3=a>127?(((a<<1)^7'd27)^a):((a<<1)^a);
end
endfunction



aes_sbox u0(
.sbox_in(plaintext[7:0]),
.sbox_out(sbox0_out)
);


aes_sbox u1(
.sbox_in(plaintext[15:8]),
.sbox_out(sbox1_out)
);

aes_sbox u2(
.sbox_in(plaintext[23:16]),
.sbox_out(sbox2_out)
);

aes_sbox u3(
.sbox_in(plaintext[31:24]),
.sbox_out(sbox3_out)
);

aes_sbox u4(
.sbox_in(plaintext[39:32]),
.sbox_out(sbox4_out)
);

aes_sbox u5(
.sbox_in(plaintext[47:40]),
.sbox_out(sbox5_out)
);

aes_sbox u6(
.sbox_in(plaintext[55:48]),
.sbox_out(sbox6_out)
);

aes_sbox u7(
.sbox_in(plaintext[63:56]),
.sbox_out(sbox7_out)
);

aes_sbox u8(
.sbox_in(plaintext[71:64]),
.sbox_out(sbox8_out)
);

aes_sbox u9(
.sbox_in(plaintext[79:72]),
.sbox_out(sbox9_out)
);

aes_sbox u10(
.sbox_in(plaintext[87:80]),
.sbox_out(sbox10_out)
);

aes_sbox u11(
.sbox_in(plaintext[95:88]),
.sbox_out(sbox11_out)
);

aes_sbox u12(
.sbox_in(plaintext[103:96]),
.sbox_out(sbox12_out)
);

aes_sbox u13(
.sbox_in(plaintext[111:104]),
.sbox_out(sbox13_out)
);

aes_sbox u14(
.sbox_in(plaintext[119:112]),
.sbox_out(sbox14_out)
);

aes_sbox u15(
.sbox_in(plaintext[127:120]),
.sbox_out(sbox15_out)
);

endmodule