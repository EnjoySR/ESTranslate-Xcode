//
//  ESTranslate.m
//  ESTranslate
//
//  Created by EnjoySR on 16/5/20.
//  Copyright © 2016年 EnjoySR. All rights reserved.
//

#import "ESTranslate.h"
#import "ESPaopaoView.h"
#import "ESTranslateDataTool.h"
#import "ESTranslateResult.h"
#import "ESSetupAppIdVC.h"
#import "ESConfig.h"

@interface ESTranslate()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic) NSTextView *currentTextView;
@property (nonatomic, strong) ESSetupAppIdVC *setupAppIdvc;
@end

@implementation ESTranslate

static ESTranslate *sharedPlugin;
+ (void)setPlugin:(ESTranslate *)plugin{
    sharedPlugin = plugin;
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}
- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChangeSelection:) name:NSTextViewDidChangeSelectionNotification object:nil];
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        
        NSMenu *menu = [[NSMenu alloc] init];
        
        NSMenuItem *translate = [[NSMenuItem alloc] initWithTitle:@"Translate the words" action:@selector(translateMenuItemClick) keyEquivalent:@"T"];
        [translate setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        translate.target = self;
        [menu addItem:translate];
        
        //Setting
        NSMenuItem *settingWindow = [[NSMenuItem alloc] initWithTitle:@"Setup Baidu AppId" action:@selector(showSetupAppidVC) keyEquivalent:@""];
        settingWindow.target = self;
        [menu addItem:settingWindow];
        
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"ESTranslate" action:nil keyEquivalent:@""];
        item.submenu = menu;
        [[menuItem submenu] addItem:item];
        
//        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
//        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"ESTranslate" action:@selector(translateMenuItemClick) keyEquivalent:@"T"];
//        [actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
//        [actionMenuItem setTarget:self];
//        [[menuItem submenu] addItem:actionMenuItem];
    }
}


- (void)translateMenuItemClick{
    if (self.currentTextView == nil) {
        return;
    }
    NSLog(@"%@",sharedPlugin);
    NSRange range = self.currentTextView.selectedRange;
    NSString *src = [self dealSelectedString:[self.currentTextView.string substringWithRange:range]];
    __weak typeof(self) weakSelf = self;
    [[ESTranslateDataTool sharedTool] translate:src compeletion:^(ESTranslateResult *result, NSError *error) {
        // 判断从未设置过Appid
        if ([result.error_code isEqualToString:@"54004"] && [[NSUserDefaults standardUserDefaults] stringForKey:kBaiduAppIdSaveKey] == nil) {
            [weakSelf showSetupAppidVC];
            return;
        }
        NSRect rect = [weakSelf.currentTextView.textContainer.layoutManager boundingRectForGlyphRange:range inTextContainer:weakSelf.currentTextView.textContainer];
        ESPaopaoView *v = [ESPaopaoView sharedPaopaoView];
        [v setupInfo:result];
        NSRect frame = v.frame;
        frame.origin.y = rect.origin.y - frame.size.height;
        frame.origin.x = CGRectGetMidX(NSRectToCGRect(rect)) - frame.size.width / 2;
        v.frame = frame;
        [weakSelf.currentTextView addSubview:v];
    }];
}

- (void)textViewDidChangeSelection:(NSNotification *)notify{
    if ([notify.object isKindOfClass:[NSTextView class]]) {
        NSTextView *text = (NSTextView *)notify.object;
        self.currentTextView = text;
    }
}

#pragma mark - private method

- (NSString *)dealSelectedString:(NSString *)str{
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    NSMutableString *result = [NSMutableString string];
    for(int i=0; i<str.length; i++){
        unichar ch = [str characterAtIndex: i];
        if (isupper(ch)) {
            if (i + 1 < str.length) {
                unichar next = [str characterAtIndex:i + 1];
                if (islower(next)) {
                    [result appendString:@" "];
                }
            }
        }
        [result appendString:[NSString stringWithFormat:@"%c", ch]];
    }
    return [result copy];
}

- (void)showSetupAppidVC{
    self.setupAppIdvc = [[ESSetupAppIdVC alloc] initWithWindowNibName:@"ESSetupAppIdVC"];
    [self.setupAppIdvc showWindow:self.setupAppIdvc];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
