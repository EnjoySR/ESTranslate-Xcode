//
//  ESTranslateDataTool.h
//  ESTranslate
//
//  Created by EnjoySR on 16/5/20.
//  Copyright © 2016年 EnjoySR. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ESTranslateResult;
@interface ESTranslateDataTool : NSObject

+ (instancetype)sharedTool;

- (void)translate:(NSString *)target compeletion:(void(^)(ESTranslateResult *result, NSError *error))compeletion;

@end
