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

@implementation ESTranslateDataTool

+ (instancetype)sharedTool{
    static ESTranslateDataTool *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)translate:(NSString *)target compeletion:(void(^)(ESTranslateResult *result, NSError *error))compeletion{
    
    NSString *appid = @"20160520000021491";
    NSString *q = target;
    NSString *from = @"auto";
    NSString *to = @"zh";
    NSString *salt = [NSString stringWithFormat:@"%f",NSTimeIntervalSince1970];
    NSString *sign = [self sign:@[appid,q,salt, @"Bw6gJBkLUWMYiCW2l5B4"]];
    NSString *urlString = [NSString stringWithFormat:@"http://api.fanyi.baidu.com/api/trans/vip/translate?appid=%@&q=%@&from=%@&to=%@&salt=%@&sign=%@",appid,q,from,to,salt,sign];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
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
