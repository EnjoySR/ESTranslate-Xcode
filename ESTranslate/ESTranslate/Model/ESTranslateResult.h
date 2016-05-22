//
//  ESTranslateResult.h
//  ESTranslate
//
//  Created by EnjoySR on 16/5/20.
//  Copyright © 2016年 EnjoySR. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TransResult;
@interface ESTranslateResult : NSObject

- (instancetype)initWithDict:(NSDictionary *)dict;

#pragma mark - baidu

@property (nonatomic, copy) NSString *error_code;

@property (nonatomic, copy) NSString *error_msg;

@property (nonatomic, copy) NSString *to;

@property (nonatomic, strong) NSArray<TransResult *> *trans_result;

@property (nonatomic, copy) NSString *from;

@end
@interface TransResult : NSObject

@property (nonatomic, copy) NSString *src;

@property (nonatomic, copy) NSString *dst;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end

