//
//  NSObject_Extension.m
//  ESTranslate
//
//  Created by EnjoySR on 16/5/20.
//  Copyright © 2016年 EnjoySR. All rights reserved.
//


#import "NSObject_Extension.h"
#import "ESTranslate.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            [ESTranslate setPlugin:[[ESTranslate alloc] initWithBundle:plugin]];
        });
    }
}
@end
