//
//  ESPaopaoView.h
//  ESTranslate
//
//  Created by EnjoySR on 16/5/20.
//  Copyright © 2016年 EnjoySR. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ESTranslateResult;
@interface ESPaopaoView : NSView
+ (instancetype)sharedPaopaoView;

- (void)setupInfo:(ESTranslateResult *)transInfo;
@end
