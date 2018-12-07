//
//  ViewController.m
//  RsaDemo
//
//  Created by 闫振 on 2018/11/30.
//  Copyright © 2018年 TeeMo. All rights reserved.
//


/*
 
 对称加密算法（不可逆的，传统加密算法）Hash加密算法/散列算法
 
 - DES    (数据加密标准(用的少,因为强度不够)
 - 3DES    (使用3个密钥,对相同的数据执行三次加密,强度增强!
 - AES(高级密码标准,美国国家安全局使用的,iOS系统使用的加密方式(钥匙串))

 AES加密方式分为ECB和CBC两种加密方式:
 
 ECB:电子代码本,就是每一个块都进行一次独立的加密，将一个大的数据块,拆分成若干个小块,一次加密。
 
 CBC加密可以有保证数据完整性,使用一个密钥和一个初始化向量(IV)对数据执行加密，每一块数据都依赖上一块数据进行加密
 
 非对称加密算法 （可逆的，现代加密算法）
 -RSA 加密算法  （算法是公开的）
 -公钥加密 私钥解密
 -私钥加密 公钥解密
 
 */



 /*
 使用RSA加密，需要生成RSA私钥和公钥匙。iOS 开发 最终需要.der 和P12
 
 // 1.生成私钥
 
 openssl  genrsa -out TeeMo.pem 512 终端生成私钥命令 512加密方式  (生成TeeMo.pem 私钥)
 openssl rsa -in TeeMo.pem -out gongyao.pem -pubout 终端生成公钥命令  (生成gongyao.pem 公钥)
 
// 2.创建证书请求
 iOS 开发中，不能直接使用pem格式证书（终端生成默认.pem格式）

 openssl req -new -key TeeMo.Pem -out reqTeeMo.csr (生成过程需要写国家 省份公司的等等 密码) 我写了密码：123456
 
// 3.生成证书并签名
openssl x509 -req -days 3650 -in reqTeeMo.csr -signkey TeeMo.pem -out reqTeeMo.crt(签名后的证书reqTeeMo.crt)

// 4.生成.der证书
openssl x509 -outform der -in reqTeeMo.crt -out reqTeeMo.der
 获得最终需要的.der文件（reqTeeMo.der 包含一公钥和一些信息）
 
// 5.生成P12文件（或者双击der，导出P12）
 
 openssl pkcs12 -export -out TeeMo.p12 -inkey TeeMo.pem -in reqTeeMo.crt
需要输入密码（我写了：234567）


 */
#import "ViewController.h"
#import "RSACryptor.h"
#import "EncryptionTools.h"
@interface ViewController ()

@property (nonatomic,strong)NSData *mEncryptionData;//模拟服务端加密的Key

@property (nonatomic,strong)NSString *mGetKey;//模拟服务端加密的Key

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *key = @"ThisIsKey";//服务端未加密的key
    
    //1.加载公钥
    [[RSACryptor sharedRSACryptor] loadPublicKey:[[NSBundle mainBundle] pathForResource:@"reqTeeMo.der" ofType:nil]];
    
    //2. 加载私钥 - P12的文件  password : 生成P12 的时候设置的密码
    [[RSACryptor sharedRSACryptor] loadPrivateKey:[[NSBundle mainBundle] pathForResource:@"TeeMo.p12" ofType:nil] password:@"234567"];
   
    //模拟服务端加密key
    _mEncryptionData = [[RSACryptor sharedRSACryptor] encryptData:[key dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"模拟服务端加密的key=====%@",_mEncryptionData);
    
    UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [btn setTitle:@"加密数据" forState:(UIControlStateNormal)];
    btn.backgroundColor = [UIColor grayColor];
    btn.frame = CGRectMake(100, 300, 150, 80);
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIButton *btn_key = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [btn_key setTitle:@"解密拿到Key" forState:(UIControlStateNormal)];
    btn_key.frame = CGRectMake(100, 100, 150, 80);
    btn_key.backgroundColor = [UIColor grayColor];
    [self.view addSubview:btn_key];
    [btn_key addTarget:self action:@selector(getKey:) forControlEvents:(UIControlEventTouchUpInside)];

    
}
- (void)btnClick:(UIButton *)btn{
    
     //AES - CBC 加密  下面iv传ivData
    uint8_t iv[8] = {2,3,4,5,6,7,0,0}; //直接影响加密结果!
    NSData * ivData = [NSData dataWithBytes:iv length:sizeof(iv)];
    
    //AES - ECB 加密  iv传nil即可
    NSString * encr_str = [[EncryptionTools sharedEncryptionTools] encryptString:@"这里要加密的数据" keyString:_mGetKey iv:nil];
    NSLog(@"加密后的数据====%@",encr_str);
    NSString * decy_str =[[EncryptionTools sharedEncryptionTools] decryptString:encr_str keyString:_mGetKey iv:nil];
    NSLog(@"解密后的数据==%@",decy_str);
    
}
- (void)getKey:(UIButton *)btn{
   
    //解密
    NSData * jiemi = [[RSACryptor sharedRSACryptor] decryptData:_mEncryptionData];
    //这里输出拿到了ThisIsKey
    _mGetKey = [[NSString alloc]initWithData:jiemi encoding:NSUTF8StringEncoding];
    NSLog(@"%@",_mGetKey);
    
}
@end

