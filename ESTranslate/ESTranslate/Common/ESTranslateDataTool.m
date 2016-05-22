//
//  ESTranslateDataTool.m
//  ESTranslate
//
//  Created by EnjoySR on 16/5/20.
//  Copyright © 2016年 EnjoySR. All rights reserved.
//

#import "ESTranslateDataTool.h"
#import "ESTranslateResult.h"
#import <CommonCrypto/CommonDigest.h>
#import "ESConfig.h"

@interface ESTranslateDataTool()

@property (nonatomic, strong) NSArray *keys;

@end

@implementation ESTranslateDataTool


+ (instancetype)sharedTool{
    static ESTranslateDataTool *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - baidu

- (void)translate:(NSString *)target compeletion:(void(^)(ESTranslateResult *result, NSError *error))compeletion{
    
    // 一堆参数
    NSString *appid = kBaiduAppId;
    NSString *saveId = [[NSUserDefaults standardUserDefaults] stringForKey:kBaiduAppIdSaveKey];
    if (saveId != nil) {
        appid = saveId;
    }
    NSString *appsecret = kBaiduAppSecret;
    NSString *saveSecret = [[NSUserDefaults standardUserDefaults] stringForKey:kBaiduAppSecretSaveKey];
    if (saveSecret != nil) {
        appsecret = saveSecret;
    }
    NSString *q = target;
    NSString *from = @"auto";
    NSString *to = @"zh";
    NSString *salt = [NSString stringWithFormat:@"%f",NSTimeIntervalSince1970];
    NSString *sign = [self sign:@[appid,q,salt, appsecret]];
    NSString *urlString = [NSString stringWithFormat:@"http://api.fanyi.baidu.com/api/trans/vip/translate?appid=%@&q=%@&from=%@&to=%@&salt=%@&sign=%@",appid,q,from,to,salt,sign];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
    // 发起请求
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                compeletion(nil, error);
            });
            return;
        }
        id dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        ESTranslateResult *result = [[ESTranslateResult alloc] initWithDict:dict];
        dispatch_async(dispatch_get_main_queue(), ^{
            compeletion(result, nil);
        });
    }] resume];
}

- (NSString *)sign:(NSArray *)params{
    
    NSMutableString *string = [NSMutableString string];
    
    for (NSString *value in params) {
        [string appendString:value];
    }
    return [ESTranslateDataTool md5HexDigest:string];
}

+ (NSString *)md5HexDigest:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];//
    
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

@end
