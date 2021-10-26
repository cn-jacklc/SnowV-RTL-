#include "stdio.h"

typedef unsigned int uint;


/*接口说明
uint SNOWV(unsigned short key[16],unsigned short iv[8],unsigned long long int length,uint* output)
key为256bit密钥，iv为128bit初试向量
length为输出长度,根据论文内容其长度不应大于2^64 故采用longlongint
output为输出结果地址

本设计中AES部分采用了自己的方法实现，在实际使用过程中考虑到现代处理器有AES_NI 故而AES部分可使用相关指令替代，注意使用时密钥设为0

我个人是硬件IC设计出身 所以实现中使用了大量的位操作 可能在可读性方面有一些问题 还请海涵
*/
unsigned char aes_gf8_mul2(unsigned char in) {
	if (in > 127)return ((in << 1) ^ 27);
	else return (in<<1);
}

unsigned char aes_gf8_mul3(unsigned char in) {
	if (in > 127)return (in << 1) ^ 27 ^in;
	else return (in << 1)^in;
}


//AES s盒查找表
static unsigned char sbox[16][16]={{0x63, 0x7C, 0x77, 0x7B, 0xF2, 0x6B, 0x6F, 0xC5, 0x30, 0x01, 0x67, 0x2B, 0xFE, 0xD7, 0xAB, 0x76},
                                   {0xCA, 0x82, 0xC9, 0x7D, 0xFA, 0x59, 0x47, 0xF0, 0xAD, 0xD4, 0xA2, 0xAF, 0x9C, 0xA4, 0x72, 0xC0},
                                   {0xB7, 0xFD, 0x93, 0x26, 0x36, 0x3F, 0xF7, 0xCC, 0x34, 0xA5, 0xE5, 0xF1, 0x71, 0xD8, 0x31, 0x15},
                                   {0x04, 0xC7, 0x23, 0xC3, 0x18, 0x96, 0x05, 0x9A, 0x07, 0x12, 0x80, 0xE2, 0xEB, 0x27, 0xB2, 0x75},
                                   {0x09, 0x83, 0x2C, 0x1A, 0x1B, 0x6E, 0x5A, 0xA0, 0x52, 0x3B, 0xD6, 0xB3, 0x29, 0xE3, 0x2F, 0x84},
                                   {0x53, 0xD1, 0x00, 0xED, 0x20, 0xFC, 0xB1, 0x5B, 0x6A, 0xCB, 0xBE, 0x39, 0x4A, 0x4C, 0x58, 0xCF},
                                   {0xD0, 0xEF, 0xAA, 0xFB, 0x43, 0x4D, 0x33, 0x85, 0x45, 0xF9, 0x02, 0x7F, 0x50, 0x3C, 0x9F, 0xA8},
                                   {0x51, 0xA3, 0x40, 0x8F, 0x92, 0x9D, 0x38, 0xF5, 0xBC, 0xB6, 0xDA, 0x21, 0x10, 0xFF, 0xF3, 0xD2},
                                   {0xCD, 0x0C, 0x13, 0xEC, 0x5F, 0x97, 0x44, 0x17, 0xC4, 0xA7, 0x7E, 0x3D, 0x64, 0x5D, 0x19, 0x73},
                                   {0x60, 0x81, 0x4F, 0xDC, 0x22, 0x2A, 0x90, 0x88, 0x46, 0xEE, 0xB8, 0x14, 0xDE, 0x5E, 0x0B, 0xDB},
                                   {0xE0, 0x32, 0x3A, 0x0A, 0x49, 0x06, 0x24, 0x5C, 0xC2, 0xD3, 0xAC, 0x62, 0x91, 0x95, 0xE4, 0x79},
                                   {0xE7, 0xC8, 0x37, 0x6D, 0x8D, 0xD5, 0x4E, 0xA9, 0x6C, 0x56, 0xF4, 0xEA, 0x65, 0x7A, 0xAE, 0x08},
                                   {0xBA, 0x78, 0x25, 0x2E, 0x1C, 0xA6, 0xB4, 0xC6, 0xE8, 0xDD, 0x74, 0x1F, 0x4B, 0xBD, 0x8B, 0x8A},
                                   {0x70, 0x3E, 0xB5, 0x66, 0x48, 0x03, 0xF6, 0x0E, 0x61, 0x35, 0x57, 0xB9, 0x86, 0xC1, 0x1D, 0x9E},
                                   {0xE1, 0xF8, 0x98, 0x11, 0x69, 0xD9, 0x8E, 0x94, 0x9B, 0x1E, 0x87, 0xE9, 0xCE, 0x55, 0x28, 0xDF},
						           {0x8C, 0xA1, 0x89, 0x0D, 0xBF, 0xE6, 0x42, 0x68, 0x41, 0x99, 0x2D, 0x0F, 0xB0, 0x54, 0xBB, 0x16} };

									
									
uint AES_cycle(uint input[4],uint output[4]){
	unsigned char in[16],out[16];
	int i;
	unsigned char temp;
	for(i=0;i<4;i++)
	{
		in[4*i]=(input[i]&0x000000ff);
		in[4*i+1]=(input[i]&0x0000ff00)>>8;
		in[4*i+2]=(input[i]&0x00ff0000)>>16;
		in[4*i+3]=(input[i]&0xff000000)>>24;
	}

//	for (i = 0; i < 16; i++)printf("%x\n",in[i]);
	
	//sbox
	for(i=0;i<16;i++)
		in[i]=sbox[(in[i]>>4)][in[i]&15];

//	for (i = 0; i < 16; i++)
//		printf("in[%d]=%x\n", i, in[i]);


	//row shift
    temp=in[1];
	in[1]=in[5];
	in[5]=in[9];
	in[9]=in[13];
	in[13]=temp;
	temp=in[2];
	in[2]=in[10];
	in[10]=temp;
	temp=in[6];
	in[6]=in[14];
	in[14]=temp;
	temp=in[3];
	in[3]=in[15];
	in[15]=in[11];
	in[11]=in[7];
	in[7]=temp;



	//col shift

	out[0]=aes_gf8_mul2(in[0])^aes_gf8_mul3(in[1])^in[2]^in[3];
	out[4]=aes_gf8_mul2(in[4])^aes_gf8_mul3(in[5])^in[6]^in[7];
	out[8]=aes_gf8_mul2(in[8])^aes_gf8_mul3(in[9])^in[10]^in[11];
	out[12]=aes_gf8_mul2(in[12])^aes_gf8_mul3(in[13])^in[14]^in[15];
	out[1]=in[0]^aes_gf8_mul2(in[1])^aes_gf8_mul3(in[2])^in[3];
	out[5]=in[4]^aes_gf8_mul2(in[5])^aes_gf8_mul3(in[6])^in[7];
	out[9]=in[8]^aes_gf8_mul2(in[9])^aes_gf8_mul3(in[10])^in[11];
	out[13]=in[12]^aes_gf8_mul2(in[13])^aes_gf8_mul3(in[14])^in[15];
	out[2]=in[0]^in[1]^aes_gf8_mul2(in[2])^aes_gf8_mul3(in[3]);
	out[6]=in[4]^in[5]^aes_gf8_mul2(in[6])^aes_gf8_mul3(in[7]);
	out[10]=in[8]^in[9]^aes_gf8_mul2(in[10])^aes_gf8_mul3(in[11]);
	out[14]=in[12]^in[13]^aes_gf8_mul2(in[14])^aes_gf8_mul3(in[15]);
	out[3]=aes_gf8_mul3(in[0])^in[1]^in[2]^aes_gf8_mul2(in[3]);
	out[7]=aes_gf8_mul3(in[4])^in[5]^in[6]^aes_gf8_mul2(in[7]);
	out[11]=aes_gf8_mul3(in[8])^in[9]^in[10]^aes_gf8_mul2(in[11]);
	out[15]=aes_gf8_mul3(in[12])^in[13]^in[14]^aes_gf8_mul2(in[15]);
//	for (i = 0; i < 16; i++)printf("out[%d]=%x\n", i, out[i]);


	output[0]=(out[3]<<24)|(out[2]<<16)|(out[1]<<8)|out[0];
	output[1]=(out[7]<<24)|(out[6]<<16)|(out[5]<<8)|out[4];
	output[2]=(out[11]<<24)|(out[10]<<16)|(out[9]<<8)|out[8];
	output[3]=(out[15]<<24)|(out[14]<<16)|(out[13]<<8)|out[12];
	return 0;
	
}								





unsigned short mul_alpha(unsigned short in) {
	if (in > 32767) return ((in<<1)^39183);
	else return (in << 1);
}

unsigned short mul_beta(unsigned short in) {
	if (in > 32767) return ((in << 1) ^ 117091);
	else return (in << 1);
}
unsigned short mul_alpha_inv(unsigned short in) {
	if (in % 2)return ((in >> 1) ^ 52359);
	else return (in >> 1);
}

unsigned short mul_beta_inv(unsigned short in) {
	if (in % 2)return ((in >> 1) ^ 58545);
	else return (in >> 1);
}







uint LFSR(unsigned short a[32]){
	unsigned short tempa,tempb;
	
	unsigned short i,j;
	
	
	for(i=0;i<8;i++){
	    tempa=a[16]^mul_alpha(a[0])^a[1]^mul_alpha_inv(a[8]);
	    tempb=a[0]^mul_beta(a[16])^a[19]^mul_beta_inv(a[24]);
	    for(j=0;j<15;j++)
		{
			a[j]=a[j+1];
			a[j+16]=a[j+17];
		}
	    a[15]=tempa;
		a[31]=tempb;
	}
	
	return 0;
	
}

//此部分中的AES_cycle在AES_NI机器中可以替换为相关指令 速度会更快
uint* FSM(uint T2[4],uint R1[4],uint R2[4],uint R3[4]){
	uint i;
	uint temp[4];


	for(i=0;i<4;i++)temp[i]=R2[i]+(R3[i]^T2[i]);
//	for (i = 0; i < 4; i++)printf("%x ",temp[i]);
	AES_cycle(R2,R3);
	AES_cycle(R1,R2);
	R1[0]=((temp[3]&0x000000ff)<<24)|((temp[2]&0x000000ff)<<16)|((temp[1]&0x000000ff)<<8)|(temp[0]&0x000000ff);
	R1[1]=((temp[3]&0x0000ff00)<<16)|((temp[2]&0x0000ff00)<<8)|(temp[1]&0x0000ff00)|((temp[0]&0x0000ff00)>>8);
	R1[2]=((temp[3]&0x00ff0000)<<8)|(temp[2]&0x00ff0000)|((temp[1]&0x00ff0000)>>8)|((temp[0]&0x00ff0000)>>16);
	R1[3]=(temp[3]&0xff000000)|((temp[2]&0xff000000)>>8)|((temp[1]&0xff000000)>>16)|((temp[0]&0xff000000)>>24);
	return 0;
	
}




uint SNOWV(unsigned short key[16],unsigned short iv[8],unsigned long long int length,uint* output){
	unsigned long long int i;
	uint j,temp;
	unsigned short lsfr[32];//这个数组同时保存了两个lfsr 低16个给a 高16个是b
    uint T1[4],T2[4],R1[4],R2[4],R3[4];
	
	//initialize
	for(i=0;i<8;i++)
		lsfr[i]=iv[i];
	for(i=0;i<8;i++)
		lsfr[i+8]=key[i];
	for(;i<16;i++)
		lsfr[i+16]=key[i];
	for(i=16;i<24;i++)
		lsfr[i]=0;
	
	for(i=0;i<4;i++)
	{
		R1[i]=0;
		R2[i]=0;
		R3[i]=0;
	}
	for(i=0;i<16;i++)
	{

		for(j=0;j<4;j++)T1[j]=lsfr[24+2*j]|(lsfr[25+2*j]<<16);
		for(j=0;j<4;j++)T2[j]=lsfr[2*j]|(lsfr[1+2*j]<<16);
		


    	for(j=0;j<4;j++)*(output+j)=(R1[j]+T1[j])^R2[j];

		FSM(T2, R1, R2, R3);
		LFSR(lsfr);


		for(j=0;j<4;j++){
			lsfr[8+j*2]=(*(output+j)&0x0000ffff)^lsfr[8+j*2];
			lsfr[9+j*2]=((*(output+j)&0xffff0000)>>16)^lsfr[9+j*2];
		}
		if (i == 14)
		{
			
			for (j = 0; j < 4; j++) {
				temp = key[2 * j + 1];
				R1[j] = R1[j] ^ (temp << 16);
				temp = key[2 * j ] ;
				R1[j] = R1[j] ^ temp;
			}

		}
		if (i == 15) {

			for (j = 0; j < 4; j++) {
				temp = key[2 * j + 9] & 0x0000ffff;
				R1[j] = R1[j] ^ (temp << 16);
				temp = key[2 * j + 8] & 0x0000ffff;
				R1[j] = R1[j] ^ temp;
			}

		}




		
	}
    //output
    for(i=0;i<length;i++)
    {
    	for(j=0;j<4;j++)T1[j]=lsfr[24+2*j]|(lsfr[25+2*j]<<16);
        for(j=0;j<4;j++)T2[j]=lsfr[2*j]|(lsfr[1+2*j]<<16);
    	for(j=0;j<4;j++)*(output+j+4*i)=(R1[j]+T1[j])^R2[j];
    	FSM(T2,R1,R2,R3);
        LFSR(lsfr);
    }	
	return 0;
	
	
}




