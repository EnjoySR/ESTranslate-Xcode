//
//  ESTranslate.h
//  ESTranslate
//
//  Created by EnjoySR on 16/5/20.
//  Copyright © 2016年 EnjoySR. All rights reserved.
//

#import <AppKit/AppKit.h>

@class ESTranslate;

static ESTranslate *sharedPlugin;

@interface ESTranslate : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end