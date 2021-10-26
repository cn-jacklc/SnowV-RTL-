# SnowV-RTL-
This is a SnowV algorithm RTL implement,

the sbox of AES is designed by two case because of lack of ROM generate tool

if you 'd love to apply this implement,you 'd better to replace it.

the verification environment and design compiler result will be added when I have another spare time

ports：

clk\n

rst_n

key    //this is the port for the key

iv     //this is the port for the iv

length //how many 128bits you'd love to encrypt

start  //start signal

valid //everytime it is high the output is valid
z     //the outout of SnowV 


随便写的一个SnowV的RTL实现，每个周期递归一次。

SBOX受限于没有ROM生成工具只能用双case实现

如果真的有人要应用，最好替换一下

先留个坑，验证环境以及dc结果后续慢慢补

接口说明
clk

rst_n 

key      //256bit的密钥

iv       //初始向量

length   //需要加密的长度，单位是128bits

start

valid    //高有效

z        //每拍输出128bit数据

如果是中国大陆的人有特殊需求可以联系我，视情况有偿/无偿帮忙改进


