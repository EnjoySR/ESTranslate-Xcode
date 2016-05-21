//
//  ESTranslateResult.m
//  ESTranslate
//
//  Created by EnjoySR on 16/5/20.
//  Copyright © 2016年 EnjoySR. All rights reserved.
//

#import "ESTranslateResult.h"

@implementation ESTranslateResult


- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:@"trans_result"]) {
        
        NSMutableArray *tempArray = [NSMutableArray array];
        NSArray *array = value;
        for (NSDictionary *dict in array) {
            [tempArray addObject:[[TransResult alloc] initWithDict:dict]];
        }
        self.trans_result = [tempArray copy];
    }else{
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{}

@end


@implementation TransResult

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{}

@end


