//
//  ESSetupAppIdVC.m
//  ESTranslate
//
//  Created by EnjoySR on 16/5/22.
//  Copyright © 2016年 EnjoySR. All rights reserved.
//

#import "ESSetupAppIdVC.h"
#import "ESConfig.h"
#import <QuartzCore/CAAnimation.h>

@interface ESSetupAppIdVC ()
@property (weak) IBOutlet NSTextField *appidField;
@property (weak) IBOutlet NSTextField *appsecretField;
@end

@implementation ESSetupAppIdVC

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (IBAction)saveButtonClick:(NSButtonCell *)sender {
    
    if (self.appidField.stringValue == nil || [self.appidField.stringValue isEqualToString:@""]) {
        [self doAnim:self.appidField];
        return;
    }
    
    if (self.appsecretField.stringValue == nil || [self.appsecretField.stringValue isEqualToString:@""]) {
        [self doAnim:self.appsecretField];
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:self.appidField.stringValue forKey:kBaiduAppIdSaveKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.appsecretField.stringValue forKey:kBaiduAppSecretSaveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self close];
}

- (IBAction)seeTheStepsButtonClick:(id)sender {
    NSString *urlString = @"https://github.com/EnjoySR/ESTranslate-Xcode#%e8%ae%be%e7%bd%ae%e7%99%be%e5%ba%a6%e7%bf%bb%e8%af%91appid%e6%b2%a1%e5%9b%be%e8%87%aa%e8%a1%8c%e8%84%91%e8%a1%a5";
    NSURL *url = [NSURL URLWithString:urlString];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)doAnim:(NSView *)view{
    // 动画
    CAKeyframeAnimation *kANi = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    // 设置
    CGFloat scaleNum = 0.05;
    NSNumber *v1 = [NSNumber numberWithFloat:M_PI_4 * scaleNum];
    NSNumber *v2 = [NSNumber numberWithFloat:-M_PI_4 * scaleNum];
    kANi.values = @[v1,v2,v1];
    kANi.repeatCount = 2;
    // 添加
    [view setWantsLayer:true];
    [view.layer addAnimation:kANi forKey:nil];
}

@end
