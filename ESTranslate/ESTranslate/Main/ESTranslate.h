//
//  ESTranslate.h
//  ESTranslate
//
//  Created by EnjoySR on 16/5/20.
//  Copyright © 2016年 EnjoySR. All rights reserved.
//

#import <AppKit/AppKit.h>

@class ESTranslate,ESTranslateResult;


@interface ESTranslate : NSObject
+ (void)setPlugin:(ESTranslate *)plugin;
+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;

- (void)showSetupAppidVC;

@end