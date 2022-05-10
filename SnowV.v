`timescale 1ns/1ps




module SNOW_V(
input              clk,
input              rst_n,
input      [255:0] key,
input      [127:0] iv,
input      [63:0]  length,  
input              start,


output reg         valid,
output wire[127:0] z
);


//used in this module
reg  [63:0]  length_cnt;
reg          initial_enable;


//lfsr
reg    [15:0]    a0;
reg    [15:0]    a1;
reg    [15:0]    a2;
reg    [15:0]    a3;
reg    [15:0]    a4;
reg    [15:0]    a5;
reg    [15:0]    a6;
reg    [15:0]    a7;
reg    [15:0]    a8;
reg    [15:0]    a9;
reg    [15:0]    a10;
reg    [15:0]    a11;
reg    [15:0]    a12;
reg    [15:0]    a13;
reg    [15:0]    a14;
reg    [15:0]    a15;
reg    [15:0]    b0;
reg    [15:0]    b1;
reg    [15:0]    b2;
reg    [15:0]    b3;
reg    [15:0]    b4;
reg    [15:0]    b5;
reg    [15:0]    b6;
reg    [15:0]    b7;
reg    [15:0]    b8;
reg    [15:0]    b9;
reg    [15:0]    b10;
reg    [15:0]    b11;
reg    [15:0]    b12;
reg    [15:0]    b13;
reg    [15:0]    b14;
reg    [15:0]    b15;



//fsm
wire   [127:0]   T1;
wire   [127:0]   T2;
reg    [127:0]   R1;
reg    [127:0]   R2;
reg    [127:0]   R3;
wire   [127:0]   AES_R1;
wire   [127:0]   AES_R2;
wire   [127:0]   T2xorR3;
wire   [31:0]    R1_before_reorder1;
wire   [31:0]    R1_before_reorder2;  
wire   [31:0]    R1_before_reorder3;  
wire   [31:0]    R1_before_reorder4;
wire   [31:0]    R1_add_T1_1;  
wire   [31:0]    R1_add_T1_2;    
wire   [31:0]    R1_add_T1_3;  
wire   [31:0]    R1_add_T1_4;


always@(posedge clk)
    if(!rst_n)
	    initial_enable<=1'b0;
	else if(start)
	    initial_enable<=1'b1;
	else if(length_cnt==64'd15)
	    initial_enable<=1'b0;
	else
	    initial_enable<=initial_enable;
		
		
always@(posedge clk)
    if(!rst_n)
        length_cnt<=64'b0;
	else if((valid&&length_cnt==length)||(length_cnt==64'd15&&initial_enable))
	    length_cnt<=64'b0;
    else if(valid||initial_enable)
        length_cnt<=length_cnt+64'd1;	
    else
	    length_cnt<=length_cnt;
		
		
always@(posedge clk)
    if(!rst_n)
        valid<=1'b0;
	else if(length_cnt==length-64'd1&&valid)
	    valid<=1'b0;
    else if(length_cnt==64'd15&&initial_enable)
        valid<=1'b1;
    else
        valid<=valid;	





//functions for lsfr
function [15:0] mul_alpha;
input [15:0] a;
begin
mul_alpha=(a>32767)?((a<<1)^16'd39183):(a<<1);
end
endfunction    

function [15:0] mul_beta;
input [15:0] a;
begin
mul_beta=(a>32767)?((a<<1)^16'd51555):(a<<1);
end
endfunction    


function [15:0] mul_alpha_inv;
input [15:0] a;
begin
mul_alpha_inv=(a[0])?((a>>1)^16'd52359):(a>>1);
end
endfunction   

function [15:0] mul_beta_inv;
input [15:0] a;
begin
mul_beta_inv=(a[0])?((a>>1)^16'd58545):(a>>1);
end
endfunction   



always@(posedge clk)
    if(!rst_n)
    begin
	a0<=16'b0;
	a1<=16'b0;
	a2<=16'b0;
	a3<=16'b0;
	a4<=16'b0;
	a5<=16'b0;
	a6<=16'b0;
	a7<=16'b0;
	a8<=16'b0;
	a9<=16'b0;
	a10<=16'b0;
	a11<=16'b0;
	a12<=16'b0;
        a13<=16'b0;
        a14<=16'b0;
        a15<=16'b0;
	b0<=16'b0;
        b1<=16'b0;
        b2<=16'b0;
        b3<=16'b0;
        b4<=16'b0;
        b5<=16'b0;
        b6<=16'b0;
        b7<=16'b0;
        b8<=16'b0;
        b9<=16'b0;
        b10<=16'b0;
        b11<=16'b0;
        b12<=16'b0;
        b13<=16'b0;
        b14<=16'b0;
        b15<=16'b0;
    end
    else if(start)
    begin
	a0 <=iv[15:0];
	a1 <=iv[31:16];
	a2 <=iv[47:32];
	a3 <=iv[63:48];
	a4 <=iv[79:64];
	a5 <=iv[95:80];
	a6 <=iv[111:96];
	a7 <=iv[127:112];
	a8 <=key[15:0];
	a9 <=key[31:16];
	a10<=key[47:32];
	a11<=key[63:48];
	a12<=key[79:64];
	a13<=key[95:80];
	a14<=key[111:96];
	a15<=key[127:112];
	b0 <=16'b0;
	b1 <=16'b0;
	b2 <=16'b0;
	b3 <=16'b0;
	b4 <=16'b0;
	b5 <=16'b0;
	b6 <=16'b0;
	b7 <=16'b0;
	b8 <=key[143:128];
	b9 <=key[159:144];
	b10<=key[175:160];
	b11<=key[191:176];
	b12<=key[207:192];
	b13<=key[223:208];
	b14<=key[239:224];
	b15<=key[255:240];
    end
    else if(initial_enable)
    begin
        a0 <=a8;
        a1 <=a9; 
        a2 <=a10;
        a3 <=a11;
        a4 <=a12;
        a5 <=a13;
        a6 <=a14;
        a7 <=a15;
        a8 <=b0^mul_alpha(a0)^a1^mul_alpha_inv(a8) ^z[15:0];
        a9 <=b1^mul_alpha(a1)^a2^mul_alpha_inv(a9) ^z[31:16];
        a10<=b2^mul_alpha(a2)^a3^mul_alpha_inv(a10)^z[47:32];
        a11<=b3^mul_alpha(a3)^a4^mul_alpha_inv(a11)^z[63:48];
        a12<=b4^mul_alpha(a4)^a5^mul_alpha_inv(a12)^z[79:64];
        a13<=b5^mul_alpha(a5)^a6^mul_alpha_inv(a13)^z[95:80];
        a14<=b6^mul_alpha(a6)^a7^mul_alpha_inv(a14)^z[111:96];
        a15<=b7^mul_alpha(a7)^a8^mul_alpha_inv(a15)^z[127:112];
        b0 <=b8; 
        b1 <=b9;
        b2 <=b10;
        b3 <=b11;
        b4 <=b12;
        b5 <=b13;
        b6 <=b14;
        b7 <=b15;
        b8 <=a0^mul_beta(b0)^b3^ mul_beta_inv(b8 );
        b9 <=a1^mul_beta(b1)^b4^ mul_beta_inv(b9 );
        b10<=a2^mul_beta(b2)^b5^ mul_beta_inv(b10);
        b11<=a3^mul_beta(b3)^b6^ mul_beta_inv(b11);
        b12<=a4^mul_beta(b4)^b7^ mul_beta_inv(b12);
        b13<=a5^mul_beta(b5)^b8^ mul_beta_inv(b13);
        b14<=a6^mul_beta(b6)^b9^ mul_beta_inv(b14);
        b15<=a7^mul_beta(b7)^b10^mul_beta_inv(b15);
    end
    else if(valid)
    begin
	a0 <=a8;
	a1 <=a9; 
	a2 <=a10;
	a3 <=a11;
	a4 <=a12;
	a5 <=a13;
	a6 <=a14;
	a7 <=a15;
	a8 <=b0^mul_alpha(a0)^a1^mul_alpha_inv(a8);
	a9 <=b1^mul_alpha(a1)^a2^mul_alpha_inv(a9);
	a10<=b2^mul_alpha(a2)^a3^mul_alpha_inv(a10);
	a11<=b3^mul_alpha(a3)^a4^mul_alpha_inv(a11);
	a12<=b4^mul_alpha(a4)^a5^mul_alpha_inv(a12);
	a13<=b5^mul_alpha(a5)^a6^mul_alpha_inv(a13);
	a14<=b6^mul_alpha(a6)^a7^mul_alpha_inv(a14);
	a15<=b7^mul_alpha(a7)^a8^mul_alpha_inv(a15);
	b0 <=b8; 
	b1 <=b9;
	b2 <=b10;
	b3 <=b11;
	b4 <=b12;
	b5 <=b13;
	b6 <=b14;
	b7 <=b15;
	b8 <=a0^mul_beta(b0)^b3^ mul_beta_inv(b8 );
	b9 <=a1^mul_beta(b1)^b4^ mul_beta_inv(b9 );
	b10<=a2^mul_beta(b2)^b5^ mul_beta_inv(b10);
	b11<=a3^mul_beta(b3)^b6^ mul_beta_inv(b11);
	b12<=a4^mul_beta(b4)^b7^ mul_beta_inv(b12);
	b13<=a5^mul_beta(b5)^b8^ mul_beta_inv(b13);
	b14<=a6^mul_beta(b6)^b9^ mul_beta_inv(b14);
	b15<=a7^mul_beta(b7)^b10^mul_beta_inv(b15);
    end
    else
    begin
	a0 <=a0 ;
	a1 <=a1 ;
	a2 <=a2 ;
	a3 <=a3 ;
	a4 <=a4 ;
	a5 <=a5 ;
	a6 <=a6 ;
	a7 <=a7 ;
	a8 <=a8 ;
	a9 <=a9 ;
	a10<=a10;
	a11<=a11;
	a12<=a12;
	a13<=a13;
	a14<=a14;
	a15<=a15;
	b0 <=b0 ;
	b1 <=b1 ;
	b2 <=b2 ;
	b3 <=b3 ;
	b4 <=b4 ;
	b5 <=b5 ;
	b6 <=b6 ;
	b7 <=b7 ;
	b8 <=b8 ;
	b9 <=b9 ;
        b10<=b10;
        b11<=b11;
        b12<=b12;
        b13<=b13;
        b14<=b14;
	b15<=b15;
    end               //need icg
	
	
//fsm part
assign T2={a7,a6,a5,a4,a3,a2,a1,a0};
assign T1={b15,b14,b13,b12,b11,b10,b9,b8};

assign T2xorR3=T2^R3;
assign R1_before_reorder1=T2xorR3[31 :0 ]+R2[31 :0 ];
assign R1_before_reorder2=T2xorR3[63 :32]+R2[63 :32];
assign R1_before_reorder3=T2xorR3[95 :64]+R2[95 :64];
assign R1_before_reorder4=T2xorR3[127:96]+R2[127:96];

assign R1_add_T1_1=T1[31 :0 ]+R1[31 :0 ];
assign R1_add_T1_2=T1[63 :32]+R1[63 :32];
assign R1_add_T1_3=T1[95 :64]+R1[95 :64];
assign R1_add_T1_4=T1[127:96]+R1[127:96];


assign z={R1_add_T1_4,R1_add_T1_3,R1_add_T1_2,R1_add_T1_1}^R2;

always@(posedge clk)
    if(!rst_n)
	begin
	    R1<=128'b0;
		R2<=128'b0;
		R3<=128'b0;
	end
	else if(initial_enable)
	begin
	    if(length_cnt>64'd13&&length_cnt[0])
		begin
		    R1<={R1_before_reorder4[31:24],R1_before_reorder3[31:24],R1_before_reorder2[31:24],R1_before_reorder1[31:24],
		         R1_before_reorder4[23:16],R1_before_reorder3[23:16],R1_before_reorder2[23:16],R1_before_reorder1[23:16],
			     R1_before_reorder4[15: 8],R1_before_reorder3[15: 8],R1_before_reorder2[15: 8],R1_before_reorder1[15: 8],
			     R1_before_reorder4[ 7: 0],R1_before_reorder3[ 7: 0],R1_before_reorder2[ 7: 0],R1_before_reorder1[ 7: 0]}
				 ^key[255:128];
	        R2<=AES_R1;
	        R3<=AES_R2;
		end
		else if(length_cnt>64'd13)
		begin
		    R1<={R1_before_reorder4[31:24],R1_before_reorder3[31:24],R1_before_reorder2[31:24],R1_before_reorder1[31:24],
		         R1_before_reorder4[23:16],R1_before_reorder3[23:16],R1_before_reorder2[23:16],R1_before_reorder1[23:16],
			     R1_before_reorder4[15: 8],R1_before_reorder3[15: 8],R1_before_reorder2[15: 8],R1_before_reorder1[15: 8],
			     R1_before_reorder4[ 7: 0],R1_before_reorder3[ 7: 0],R1_before_reorder2[ 7: 0],R1_before_reorder1[ 7: 0]}
			     ^key[127:0];
	        R2<=AES_R1;
	        R3<=AES_R2;
		end
		else
		begin
		    R1<={R1_before_reorder4[31:24],R1_before_reorder3[31:24],R1_before_reorder2[31:24],R1_before_reorder1[31:24],
		         R1_before_reorder4[23:16],R1_before_reorder3[23:16],R1_before_reorder2[23:16],R1_before_reorder1[23:16],
			     R1_before_reorder4[15: 8],R1_before_reorder3[15: 8],R1_before_reorder2[15: 8],R1_before_reorder1[15: 8],
			     R1_before_reorder4[ 7: 0],R1_before_reorder3[ 7: 0],R1_before_reorder2[ 7: 0],R1_before_reorder1[ 7: 0]};
	        R2<=AES_R1;
	        R3<=AES_R2;
		end		
	end
	else if(valid)
	begin
	    R1<={R1_before_reorder4[31:24],R1_before_reorder3[31:24],R1_before_reorder2[31:24],R1_before_reorder1[31:24],
		     R1_before_reorder4[23:16],R1_before_reorder3[23:16],R1_before_reorder2[23:16],R1_before_reorder1[23:16],
			 R1_before_reorder4[15: 8],R1_before_reorder3[15: 8],R1_before_reorder2[15: 8],R1_before_reorder1[15: 8],
			 R1_before_reorder4[ 7: 0],R1_before_reorder3[ 7: 0],R1_before_reorder2[ 7: 0],R1_before_reorder1[ 7: 0]};
	    R2<=AES_R1;
	    R3<=AES_R2;
	end
	else
	begin
	    R1<=R1;
		R2<=R2;
		R3<=R3;   
	end             //need ICG
    
AES_round u0
(
.plaintext(R1),
.ciphertext(AES_R1)
);

AES_round u1
(
.plaintext(R2),
.ciphertext(AES_R2)
);
	
	
	
		
		
endmodule
