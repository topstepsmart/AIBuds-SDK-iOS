//
//  AIChatDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-03-24.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "AIChatDemoController.h"
#import "AIChatSettingsController.h"
#import "AIChatContext.h"

@interface AIChatDemoController ()

@property (nonatomic, strong) UIButton *startChatButton;
@property (nonatomic, strong) UIButton *endChatButton;
@property (nonatomic, strong) UITextView *chatContentTextView;
@property (nonatomic, strong) UIBarButtonItem *settingsButton;
@property (nonatomic, assign) BOOL isChatting;

@end

@implementation AIChatDemoController

- (void)dealloc {
    [self stopObservingNotifications];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化界面
    [self setupUI];

    [self startObservingNotifications];
}

- (void)setupUI {
    NSString* status = [NSString stringWithFormat:@"(%@)",  AIChatContext.sharedInstance.isSpeaking ? NSLocalizedString(@"LocKey.Speaking", nil) : NSLocalizedString(@"LocKey.NotSpeaking", nil)];
    self.title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"LocKey.AiChatDemoTitle", nil), status];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 设置导航右上角按钮
    self.settingsButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LocKey.Settings", nil) style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonTapped:)];
    self.navigationItem.rightBarButtonItem = self.settingsButton;
    
    // 创建开始聊天按钮
    self.startChatButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.startChatButton setTitle:@"开始聊天" forState:UIControlStateNormal];
    self.startChatButton.frame = CGRectMake(20, 100, 100, 40);
    [self.startChatButton addTarget:self action:@selector(startChatButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startChatButton];
    
    // 创建结束聊天按钮
    self.endChatButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.endChatButton setTitle:@"结束聊天" forState:UIControlStateNormal];
    self.endChatButton.frame = CGRectMake(140, 100, 100, 40);
    self.endChatButton.enabled = NO;
    [self.endChatButton addTarget:self action:@selector(endChatButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.endChatButton];
    
    // 创建聊天内容显示区域
    self.chatContentTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 160, self.view.bounds.size.width - 40, self.view.bounds.size.height - 200)];
    self.chatContentTextView.editable = NO;
    self.chatContentTextView.selectable = NO;
    self.chatContentTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.chatContentTextView.layer.borderWidth = 1.0;
    self.chatContentTextView.layer.cornerRadius = 5.0;
    self.chatContentTextView.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:self.chatContentTextView];
}

-(void) startObservingNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleVadStartSpeaking:) name:@"VadStartSpeakingNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleVadEndSpeaking:) name:@"VadEndSpeakingNotification" object:nil];
}

-(void) stopObservingNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VadStartSpeakingNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VadEndSpeakingNotification" object:nil];
}

- (void)handleVadStartSpeaking:(NSNotification *)notification {
    // 处理开始说话事件
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        NSString* status = [NSString stringWithFormat:@"(%@)", NSLocalizedString(@"LocKey.Speaking", nil)];
        strongSelf.title = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"LocKey.AiChatDemoTitle", nil), status];
    });
}

- (void)handleVadEndSpeaking:(NSNotification *)notification {
    // 处理结束说话事件
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }

        NSString* status = [NSString stringWithFormat:@"(%@)", NSLocalizedString(@"LocKey.NotSpeaking", nil)];
        strongSelf.title = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"LocKey.AiChatDemoTitle", nil), status];
    });
}

- (void)settingsButtonTapped:(id)sender {
    // 聊天过程中不允许设置
    if (self.isChatting) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"聊天过程中不允许设置" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    AIChatSettingsController *settingsController = [[AIChatSettingsController alloc] initWithSettings:[AIChatContext sharedInstance].settings];
    [self.navigationController pushViewController:settingsController animated:YES];
}

- (void)startChatButtonTapped:(id)sender {
    self.isChatting = YES;
    self.startChatButton.enabled = NO;
    self.endChatButton.enabled = YES;
    self.settingsButton.enabled = NO;
    
    // 模拟添加聊天内容
    [self appendChatContent:@"系统：聊天已开始\n"];
}

- (void)endChatButtonTapped:(id)sender {
    self.isChatting = NO;
    self.startChatButton.enabled = YES;
    self.endChatButton.enabled = NO;
    self.settingsButton.enabled = YES;
    
    // 模拟添加聊天内容
    [self appendChatContent:@"系统：聊天已结束\n"];
}

- (void)appendChatContent:(NSString *)content {
    NSString *currentText = self.chatContentTextView.text;
    self.chatContentTextView.text = [currentText stringByAppendingString:content];
    
    // 滚动到底部
    if (self.chatContentTextView.text.length > 0) {
        NSRange bottomRange = NSMakeRange(self.chatContentTextView.text.length - 1, 1);
        [self.chatContentTextView scrollRangeToVisible:bottomRange];
    }
}

@end
