//
//  ESPaopaoView.m
//  ESTranslate
//
//  Created by EnjoySR on 16/5/20.
//  Copyright © 2016年 EnjoySR. All rights reserved.
//

#import "ESPaopaoView.h"
#import "ESTranslateResult.h"
#import "ESTranslate.h"

@interface ESPaopaoView()

@property (weak) IBOutlet NSTextField *sourceLabel;
@property (weak) IBOutlet NSTextField *destinationLabel;
@property (nonatomic, assign) BOOL restart;

@property (nonatomic, strong) NSMutableArray *tagArray;
@property (nonatomic, strong) NSTimer *removeTimer;


// 处理鼠标拖动
@property (nonatomic, assign) NSPoint startPoint;
@property (nonatomic, assign) NSRect startFrame;
@property (nonatomic, assign) NSSize contentSize;

@property (nonatomic, strong) ESTranslateResult *translateResult;

@end

@implementation ESPaopaoView

+ (instancetype)sharedPaopaoView{
    
    static ESPaopaoView *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *a = nil;
        [[[NSNib alloc] initWithNibNamed:@"ESPaopaoView" bundle:[NSBundle bundleWithIdentifier:@"EnjoySR.ESTranslate"]] instantiateWithOwner:nil topLevelObjects:&a];
        for (id view in a) {
            if ([view isKindOfClass:[ESPaopaoView class]]) {
                instance = view;
            }
        }
        [instance addGesture];
    });
    
    return instance;
}

- (NSMutableArray *)tagArray {
    if (_tagArray == nil) {
        _tagArray = [NSMutableArray array];
    }
    return _tagArray;
}

- (NSTimer *)removeTimer{
    if (_removeTimer == nil) {
        _removeTimer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(timerTrigger) userInfo:nil repeats:true];
    }
    return _removeTimer;
}

- (void)timerTrigger{
    [self removeFromSuperview];
    [_removeTimer invalidate];
    _removeTimer = nil;
}

/// 双击移除当前paopaoView
- (void)addGesture{
    NSClickGestureRecognizer *ges = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick)];
    ges.numberOfClicksRequired = 2;
    [self addGestureRecognizer:ges];
}

- (void)doubleClick{
    [self timerTrigger];
}
/// 设置显示内容
///
/// @param transInfo <#transInfo description#>
- (void)setupInfo:(ESTranslateResult *)transInfo{
    self.translateResult = transInfo;
    if (transInfo.error_code != nil && ![transInfo.error_code isEqualToString:@"52000"]) {
        if ([transInfo.error_code isEqualToString:@"54004"]) {
            self.sourceLabel.stringValue = @"账户余额不足";
            self.destinationLabel.stringValue = @"当月翻译字符超过免费字符数(200万)，建议点击此弹框更换appid";
        }else if ([transInfo.error_code isEqualToString:@"52003"]){
            self.sourceLabel.stringValue = @"未授权用户";
            self.destinationLabel.stringValue = @"您的appid或者密钥不正确，点击此弹框更换appid";
        }else{
            self.sourceLabel.stringValue = [NSString stringWithFormat:@"错误码: %@", transInfo.error_code];
            self.destinationLabel.stringValue = @"( •̅_•̅ )具体原因请点击此弹框前往百度翻译开放平台查看对应错误信息~";
        }
    }else{
        self.sourceLabel.stringValue = transInfo.trans_result.firstObject.src;
        NSArray *dstArray = [transInfo.trans_result valueForKey:@"dst"];
        NSMutableString *dstString = [[NSMutableString alloc] init];
        for (NSString *dst in dstArray) {
            [dstString appendFormat:@"%@\n", dst];
        }
        if ([dstString hasSuffix:@"\n"]) {
            dstString = [NSMutableString stringWithString:[dstString substringToIndex:dstString.length - 1]];
        }
        self.destinationLabel.stringValue = dstString;
    }
    [self sizeToFit];
    // 重置timer
    [_removeTimer invalidate];
    _removeTimer = nil;
}

- (void)viewDidMoveToSuperview{
    [super viewDidMoveToSuperview];
    if (_removeTimer == nil) {
        // 执行timer，指定秒数之后消失
        [[NSRunLoop currentRunLoop] addTimer:self.removeTimer forMode:NSRunLoopCommonModes];
    }
}

/// 调整内容大小
- (void)sizeToFit{
    NSSize srcSize = [self.sourceLabel.stringValue boundingRectWithSize:NSMakeSize(self.sourceLabel.preferredMaxLayoutWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.sourceLabel.font}].size;
    NSSize dstSize = [self.destinationLabel.stringValue boundingRectWithSize:NSMakeSize(self.destinationLabel.preferredMaxLayoutWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.destinationLabel.font}].size;
    NSRect frame = self.frame;
    frame.size.width = fmax(srcSize.width, dstSize.width) + 20;
    frame.size.height = srcSize.height + dstSize.height + 8 + 8 + 20;
    self.frame = frame;
}

// 点击一次，移除timer
- (void)mouseDown:(NSEvent *)theEvent{
    if ([_removeTimer isValid]) {
        [_removeTimer invalidate];
        _removeTimer = nil;
    }
    self.startPoint = [NSEvent mouseLocation];
    self.startFrame = self.frame;
    NSTextView *textView = (NSTextView *)self.superview;
    self.contentSize = textView.textContainer.size;
    
    // 处理翻译错误点击paopaoView
    if (self.translateResult.error_code != nil && ![self.translateResult.error_code isEqualToString:@"52000"]) {
        if ([self.translateResult.error_code isEqualToString:@"54004"] || [self.translateResult.error_code isEqualToString:@"52003"]) {
            ESTranslate *translate = [ESTranslate sharedPlugin];
            [translate showSetupAppidVC];
            [self removeFromSuperview];
        }else{
            NSURL* url = [[ NSURL alloc ] initWithString :@"http://api.fanyi.baidu.com/api/trans/product/apidoc"];
            [[NSWorkspace sharedWorkspace] openURL:url];
            [self removeFromSuperview];
        }
    }else{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            system([[NSString stringWithFormat:@"say %@", self.sourceLabel.stringValue] cStringUsingEncoding:NSUTF8StringEncoding]);
        });
    }
}

- (void)mouseDragged:(NSEvent *)theEvent{
    NSPoint endPoint = [NSEvent mouseLocation];
    NSRect frame = self.startFrame;
    frame.origin.x += endPoint.x - self.startPoint.x;
    frame.origin.y -= endPoint.y - self.startPoint.y;
    // 超出左边界处理
    frame.origin.x < 0 ? frame.origin.x = 0 : frame.origin.x;
    // 超出上边界处理
    frame.origin.y < 0 ? frame.origin.y = 0 : frame.origin.y;
    // 超出右边界处理
    CGFloat maxX = self.contentSize.width - frame.size.width;
    frame.origin.x > maxX ? frame.origin.x = maxX : frame.origin.x;
    [self setFrame:frame];
}

@end