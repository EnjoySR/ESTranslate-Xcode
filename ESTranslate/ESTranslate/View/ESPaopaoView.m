//
//  ESPaopaoView.m
//  ESTranslate
//
//  Created by EnjoySR on 16/5/20.
//  Copyright © 2016年 EnjoySR. All rights reserved.
//

#import "ESPaopaoView.h"
#import "ESTranslateResult.h"

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
    if (transInfo.trans_result.count <= 0) {
        self.sourceLabel.stringValue = @"Error";
        self.destinationLabel.stringValue = @"The reason is unknown~( •̅_•̅ )";
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

/// 实现点击一次就不再消失paopaoView，再点击一次就消失paopaoView


- (void)mouseDown:(NSEvent *)theEvent{
    if ([_removeTimer isValid]) {
        [_removeTimer invalidate];
        _removeTimer = nil;
    }
    self.startPoint = [NSEvent mouseLocation];
    self.startFrame = self.frame;
    NSTextView *textView = (NSTextView *)self.superview;
    self.contentSize = textView.textContainer.size;
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