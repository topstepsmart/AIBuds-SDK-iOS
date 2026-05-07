//
//  TeleprompterDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-29.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "TeleprompterDemoController.h"
#import <objc/runtime.h>

@interface UITextView (Placeholder)
@property (nonatomic, copy) NSString *placeholder;
@end

@implementation UITextView (Placeholder)

- (void)setPlaceholder:(NSString *)placeholder {
    objc_setAssociatedObject(self, @selector(placeholder), placeholder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!self.text.length) {
        self.text = placeholder;
        self.textColor = [UIColor systemGrayColor];
    }
}

- (NSString *)placeholder {
    return objc_getAssociatedObject(self, @selector(placeholder));
}


@end

@interface TeleprompterDemoController () <UITextViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIView *displayCard;
@property (nonatomic, strong) UILabel *promptDisplayLabel;
@property (nonatomic, strong) UIView *infoCard;
@property (nonatomic, strong) UILabel *slotInfoLabel;
@property (nonatomic, strong) UILabel *spaceInfoLabel;
@property (nonatomic, strong) UILabel *scrollSpeedLabel;

@property (nonatomic, strong) UIView *controlCard;
@property (nonatomic, strong) UITextView *promptInputView;
@property (nonatomic, strong) UILabel *speedLabel;
@property (nonatomic, strong) UISlider *speedSlider;
@property (nonatomic, strong) UILabel *speedValueLabel;
@property (nonatomic, strong) UIButton *applySpeedButton;

@property (nonatomic, strong) UIView *actionCard;
@property (nonatomic, strong) UIButton *sendPromptButton;
@property (nonatomic, strong) UIButton *clearSlotButton;
@property (nonatomic, strong) UIButton *toggleSlotButton;


@property (nonatomic, strong) NSTimer *scrollTimer;
@property (nonatomic, assign) CGFloat scrollOffset;

@end

@implementation TeleprompterDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    [self setupUI];
    [self fetchDeviceInfo];
    
    // Set delegate and start scroll animation
    self.promptInputView.delegate = self;
    [self startScrollAnimationWithText:self.promptInputView.text];
    
    [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopScrollAnimation];
    [self deregisterForKeyboardNotifications];
}

- (void)dealloc {
    [self deregisterForKeyboardNotifications];
}

#pragma mark - Keyboard Handling

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)deregisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGFloat keyboardHeight = keyboardFrame.size.height;
    
    UIEdgeInsets contentInset = self.scrollView.contentInset;
    contentInset.bottom = keyboardHeight;
    
    [UIView animateWithDuration:duration animations:^{
        self.scrollView.contentInset = contentInset;
        self.scrollView.scrollIndicatorInsets = contentInset;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    UIEdgeInsets contentInset = UIEdgeInsetsZero;
    
    [UIView animateWithDuration:duration animations:^{
        self.scrollView.contentInset = contentInset;
        self.scrollView.scrollIndicatorInsets = contentInset;
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)createScrollView {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.contentView];
    [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor constant:-20]
    ]];
}

- (void)setupUI {
    // Create scroll view and content view
    [self createScrollView];
    
    // 显示卡片 - 模拟眼镜设备上的提示词展示
    [self createDisplayCard];
    
    // 信息卡片 - 显示设备状态信息
    [self createInfoCard];
    
    // 控制卡片 - 输入提示词和调整滚动速度
    [self createControlCard];
    
    // 操作卡片 - 发送、清除、切换 slot
    [self createActionCard];
    

}

- (void)createDisplayCard {
    self.displayCard = [[UIView alloc] init];
    self.displayCard.backgroundColor = [UIColor blackColor];
    self.displayCard.layer.cornerRadius = 16;
    self.displayCard.layer.shadowColor = [UIColor blackColor].CGColor;
    self.displayCard.layer.shadowOpacity = 0.3;
    self.displayCard.layer.shadowOffset = CGSizeMake(0, 4);
    self.displayCard.layer.shadowRadius = 8;
    self.displayCard.clipsToBounds = YES;  // 确保子视图不会超出卡片边界
    [self.contentView addSubview:self.displayCard];
    [self.displayCard setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.displayCard.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:20],
        [self.displayCard.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.displayCard.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
        [self.displayCard.heightAnchor constraintEqualToConstant:120]
    ]];
    
    // 提示词显示标签 - 使用更大的字体并确保完整显示
    self.promptDisplayLabel = [[UILabel alloc] init];
    self.promptDisplayLabel.text = NSLocalizedString(@"LocKey.OverlayPromptDefaultDisplayHint", @"Enter prompt text to preview");
    self.promptDisplayLabel.font = [UIFont systemFontOfSize:32 weight:UIFontWeightBold];  // 增大字体以模拟眼镜显示效果
    self.promptDisplayLabel.textColor = [UIColor whiteColor];
    self.promptDisplayLabel.numberOfLines = 1;
    self.promptDisplayLabel.clipsToBounds = YES;
    self.promptDisplayLabel.adjustsFontSizeToFitWidth = NO;  // 不自动缩小字体，保持固定大小
    self.promptDisplayLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    [self.displayCard addSubview:self.promptDisplayLabel];
    [self.promptDisplayLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.promptDisplayLabel.centerYAnchor constraintEqualToAnchor:self.displayCard.centerYAnchor],
        [self.promptDisplayLabel.leadingAnchor constraintEqualToAnchor:self.displayCard.leadingAnchor constant:20],
        [self.promptDisplayLabel.heightAnchor constraintEqualToConstant:40]  // 固定高度确保垂直居中显示
    ]];
}

- (void)createInfoCard {
    self.infoCard = [[UIView alloc] init];
    self.infoCard.backgroundColor = [UIColor systemBackgroundColor];
    self.infoCard.layer.cornerRadius = 12;
    self.infoCard.layer.shadowColor = [UIColor blackColor].CGColor;
    self.infoCard.layer.shadowOpacity = 0.1;
    self.infoCard.layer.shadowOffset = CGSizeMake(0, 2);
    self.infoCard.layer.shadowRadius = 4;
    [self.contentView addSubview:self.infoCard];
    [self.infoCard setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.infoCard.topAnchor constraintEqualToAnchor:self.displayCard.bottomAnchor constant:20],
        [self.infoCard.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.infoCard.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20]
    ]];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.TeleprompterInfo", @"Teleprompter Info");
    titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    [self.infoCard addSubview:titleLabel];
    [titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.infoCard.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.infoCard.leadingAnchor constant:20]
    ]];
    
    // Slot Info (current slot / total slots)
    self.slotInfoLabel = [[UILabel alloc] init];
    self.slotInfoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.OverlayPromptSlotInfoFormat", @"Slot: %@ / %@"), @"--", @"--"];
    self.slotInfoLabel.font = [UIFont systemFontOfSize:14];
    self.slotInfoLabel.textColor = [UIColor secondaryLabelColor];
    [self.infoCard addSubview:self.slotInfoLabel];
    [self.slotInfoLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.slotInfoLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:16],
        [self.slotInfoLabel.leadingAnchor constraintEqualToAnchor:self.infoCard.leadingAnchor constant:20]
    ]];
    
    // Space Info (used / capacity)
    self.spaceInfoLabel = [[UILabel alloc] init];
    self.spaceInfoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.OverlayPromptSpaceInfoFormat", @"Space: %@ / %@"), @"--", @"--"];
    self.spaceInfoLabel.font = [UIFont systemFontOfSize:14];
    self.spaceInfoLabel.textColor = [UIColor secondaryLabelColor];
    [self.infoCard addSubview:self.spaceInfoLabel];
    [self.spaceInfoLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.spaceInfoLabel.topAnchor constraintEqualToAnchor:self.slotInfoLabel.bottomAnchor constant:8],
        [self.spaceInfoLabel.leadingAnchor constraintEqualToAnchor:self.infoCard.leadingAnchor constant:20]
    ]];
    
    // Scroll Speed
    self.scrollSpeedLabel = [[UILabel alloc] init];
    self.scrollSpeedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.OverlayPromptScrollSpeedFormat", @"Scroll Speed: %@"), @"--x"];
    self.scrollSpeedLabel.font = [UIFont systemFontOfSize:14];
    self.scrollSpeedLabel.textColor = [UIColor secondaryLabelColor];
    [self.infoCard addSubview:self.scrollSpeedLabel];
    [self.scrollSpeedLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollSpeedLabel.topAnchor constraintEqualToAnchor:self.spaceInfoLabel.bottomAnchor constant:8],
        [self.scrollSpeedLabel.leadingAnchor constraintEqualToAnchor:self.infoCard.leadingAnchor constant:20],
        [self.scrollSpeedLabel.bottomAnchor constraintEqualToAnchor:self.infoCard.bottomAnchor constant:-20]
    ]];
}

- (void)createControlCard {
    self.controlCard = [[UIView alloc] init];
    self.controlCard.backgroundColor = [UIColor systemBackgroundColor];
    self.controlCard.layer.cornerRadius = 12;
    self.controlCard.layer.shadowColor = [UIColor blackColor].CGColor;
    self.controlCard.layer.shadowOpacity = 0.1;
    self.controlCard.layer.shadowOffset = CGSizeMake(0, 2);
    self.controlCard.layer.shadowRadius = 4;
    [self.contentView addSubview:self.controlCard];
    [self.controlCard setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.controlCard.topAnchor constraintEqualToAnchor:self.infoCard.bottomAnchor constant:20],
        [self.controlCard.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.controlCard.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20]
    ]];
    
    // Prompt Input Label
    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.text = NSLocalizedString(@"LocKey.OverlayPromptText", @"Prompt Text");
    promptLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    promptLabel.textColor = [UIColor labelColor];
    [self.controlCard addSubview:promptLabel];
    [promptLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [promptLabel.topAnchor constraintEqualToAnchor:self.controlCard.topAnchor constant:20],
        [promptLabel.leadingAnchor constraintEqualToAnchor:self.controlCard.leadingAnchor constant:20]
    ]];
    
    // Prompt Input TextView
    self.promptInputView = [[UITextView alloc] init];
    self.promptInputView.font = [UIFont systemFontOfSize:14];
    self.promptInputView.textColor = [UIColor labelColor];
    self.promptInputView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.promptInputView.layer.cornerRadius = 8;
    self.promptInputView.layer.borderWidth = 1;
    self.promptInputView.layer.borderColor = [UIColor systemGray3Color].CGColor;
    self.promptInputView.placeholder = NSLocalizedString(@"LocKey.OverlayPromptEnterPromptPlaceholder", @"Enter prompt text...");
    self.promptInputView.text = NSLocalizedString(@"LocKey.OverlayPromptDefaultPrompt", @"Default Prompt");
    self.promptDisplayLabel.text = NSLocalizedString(@"LocKey.OverlayPromptDefaultPrompt", @"Default Prompt");
    [self.controlCard addSubview:self.promptInputView];
    [self.promptInputView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.promptInputView.topAnchor constraintEqualToAnchor:promptLabel.bottomAnchor constant:12],
        [self.promptInputView.leadingAnchor constraintEqualToAnchor:self.controlCard.leadingAnchor constant:20],
        [self.promptInputView.trailingAnchor constraintEqualToAnchor:self.controlCard.trailingAnchor constant:-20],
        [self.promptInputView.heightAnchor constraintEqualToConstant:80]
    ]];
    
    // Speed Label
    self.speedLabel = [[UILabel alloc] init];
    self.speedLabel.text = NSLocalizedString(@"LocKey.AdjustOverlayPromptSpeed", @"Adjust Scroll Speed");
    self.speedLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    self.speedLabel.textColor = [UIColor labelColor];
    [self.controlCard addSubview:self.speedLabel];
    [self.speedLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.speedLabel.topAnchor constraintEqualToAnchor:self.promptInputView.bottomAnchor constant:20],
        [self.speedLabel.leadingAnchor constraintEqualToAnchor:self.controlCard.leadingAnchor constant:20]
    ]];
    
    // Speed Slider
    self.speedSlider = [[UISlider alloc] init];
    self.speedSlider.minimumValue = 10;
    self.speedSlider.maximumValue = 1000;
    self.speedSlider.value = 100;
    [self.speedSlider addTarget:self action:@selector(speedSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.controlCard addSubview:self.speedSlider];
    [self.speedSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.speedSlider.topAnchor constraintEqualToAnchor:self.speedLabel.bottomAnchor constant:12],
        [self.speedSlider.leadingAnchor constraintEqualToAnchor:self.controlCard.leadingAnchor constant:20],
        [self.speedSlider.trailingAnchor constraintEqualToAnchor:self.controlCard.trailingAnchor constant:-80]
    ]];
    
    // Speed Value Label
    self.speedValueLabel = [[UILabel alloc] init];
    self.speedValueLabel.text = @"1.0x";
    self.speedValueLabel.font = [UIFont systemFontOfSize:14];
    self.speedValueLabel.textColor = [UIColor systemBlueColor];
    self.speedValueLabel.textAlignment = NSTextAlignmentRight;
    [self.controlCard addSubview:self.speedValueLabel];
    [self.speedValueLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.speedValueLabel.topAnchor constraintEqualToAnchor:self.speedLabel.bottomAnchor constant:12],
        [self.speedValueLabel.leadingAnchor constraintEqualToAnchor:self.speedSlider.trailingAnchor constant:10],
        [self.speedValueLabel.trailingAnchor constraintEqualToAnchor:self.controlCard.trailingAnchor constant:-20]
    ]];
    
    // Apply Speed Button
    self.applySpeedButton = [[UIButton alloc] init];
    [self.applySpeedButton setTitle:NSLocalizedString(@"LocKey.ApplyOverlayPromptSpeed", @"Apply") forState:UIControlStateNormal];
    [self.applySpeedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.applySpeedButton.backgroundColor = [UIColor systemBlueColor];
    self.applySpeedButton.layer.cornerRadius = 8;
    [self.applySpeedButton addTarget:self action:@selector(applySpeedButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlCard addSubview:self.applySpeedButton];
    [self.applySpeedButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.applySpeedButton.topAnchor constraintEqualToAnchor:self.speedSlider.bottomAnchor constant:16],
        [self.applySpeedButton.leadingAnchor constraintEqualToAnchor:self.controlCard.leadingAnchor constant:20],
        [self.applySpeedButton.trailingAnchor constraintEqualToAnchor:self.controlCard.trailingAnchor constant:-20],
        [self.applySpeedButton.heightAnchor constraintEqualToConstant:44],
        [self.applySpeedButton.bottomAnchor constraintEqualToAnchor:self.controlCard.bottomAnchor constant:-16.0f]
    ]];
}

- (void)createActionCard {
    self.actionCard = [[UIView alloc] init];
    self.actionCard.backgroundColor = [UIColor systemBackgroundColor];
    self.actionCard.layer.cornerRadius = 12;
    self.actionCard.layer.shadowColor = [UIColor blackColor].CGColor;
    self.actionCard.layer.shadowOpacity = 0.1;
    self.actionCard.layer.shadowOffset = CGSizeMake(0, 2);
    self.actionCard.layer.shadowRadius = 4;
    [self.contentView addSubview:self.actionCard];
    [self.actionCard setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.actionCard.topAnchor constraintEqualToAnchor:self.controlCard.bottomAnchor constant:20],
        [self.actionCard.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.actionCard.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
        [self.actionCard.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-16]
    ]];
    
    // Send Prompt Button
    self.sendPromptButton = [[UIButton alloc] init];
    [self.sendPromptButton setTitle:NSLocalizedString(@"LocKey.SendOverlayPrompt", @"Send Prompt") forState:UIControlStateNormal];
    [self.sendPromptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sendPromptButton.backgroundColor = [UIColor systemGreenColor];
    self.sendPromptButton.layer.cornerRadius = 8;
    [self.sendPromptButton addTarget:self action:@selector(sendPromptButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.actionCard addSubview:self.sendPromptButton];
    [self.sendPromptButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.sendPromptButton.topAnchor constraintEqualToAnchor:self.actionCard.topAnchor constant:20],
        [self.sendPromptButton.leadingAnchor constraintEqualToAnchor:self.actionCard.leadingAnchor constant:20],
        [self.sendPromptButton.trailingAnchor constraintEqualToAnchor:self.actionCard.trailingAnchor constant:-20],
        [self.sendPromptButton.heightAnchor constraintEqualToConstant:44]
    ]];
    
    // Toggle Slot Button
    self.toggleSlotButton = [[UIButton alloc] init];
    [self.toggleSlotButton setTitle:NSLocalizedString(@"LocKey.ToggleOverlayPromptSlot", @"Toggle Slot") forState:UIControlStateNormal];
    [self.toggleSlotButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.toggleSlotButton.backgroundColor = [UIColor systemOrangeColor];
    self.toggleSlotButton.layer.cornerRadius = 8;
    [self.toggleSlotButton addTarget:self action:@selector(toggleSlotButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.actionCard addSubview:self.toggleSlotButton];
    [self.toggleSlotButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.toggleSlotButton.topAnchor constraintEqualToAnchor:self.sendPromptButton.bottomAnchor constant:12],
        [self.toggleSlotButton.leadingAnchor constraintEqualToAnchor:self.actionCard.leadingAnchor constant:20],
        [self.toggleSlotButton.widthAnchor constraintEqualToConstant:150],
        [self.toggleSlotButton.heightAnchor constraintEqualToConstant:44]
    ]];
    
    // Clear Slot Button
    self.clearSlotButton = [[UIButton alloc] init];
    [self.clearSlotButton setTitle:NSLocalizedString(@"LocKey.ClearOverlayPromptSlot", @"Clear Slot") forState:UIControlStateNormal];
    [self.clearSlotButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.clearSlotButton.backgroundColor = [UIColor systemRedColor];
    self.clearSlotButton.layer.cornerRadius = 8;
    [self.clearSlotButton addTarget:self action:@selector(clearSlotButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.actionCard addSubview:self.clearSlotButton];
    [self.clearSlotButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.clearSlotButton.topAnchor constraintEqualToAnchor:self.sendPromptButton.bottomAnchor constant:12],
        [self.clearSlotButton.trailingAnchor constraintEqualToAnchor:self.actionCard.trailingAnchor constant:-20],
        [self.clearSlotButton.widthAnchor constraintEqualToConstant:150],
        [self.clearSlotButton.heightAnchor constraintEqualToConstant:44],
        [self.clearSlotButton.bottomAnchor constraintEqualToAnchor:self.actionCard.bottomAnchor constant:-20]
    ]];
}

#pragma mark - API Methods

- (void)fetchDeviceInfo {
    [self showLoading:YES];
    
    id<AIBudsTeleprompterAPI> teleprompterAPI = (id<AIBudsTeleprompterAPI>)self.device;
    
    if (!teleprompterAPI) {
        [self showStatus:NSLocalizedString(@"LocKey.OverlayPromptNotSupported", @"Overlay Prompt not supported") error:NO];
        [self showLoading:NO];
        return;
    }
    
    // Fetch all info
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSNumber *slotIndex = teleprompterAPI.overlayPromptSlotIndex;
        NSNumber *totalSlots = teleprompterAPI.overlayPromptTotalSlots;
        NSNumber *usedBytes = teleprompterAPI.usedBytesOfCurrentOverlayPromptSlot;
        NSNumber *capacityBytes = teleprompterAPI.capacityBytesOfCurrentOverlayPromptSlot;
        NSNumber *scrollSpeed = teleprompterAPI.overlayPromptScrollSpeed;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.slotInfoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.OverlayPromptSlotInfoFormat", @"Slot: %@ / %@"), slotIndex ?: @"--", totalSlots ?: @"--"];
            self.spaceInfoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.OverlayPromptSpaceInfoFormat", @"Space: %@ / %@"), usedBytes ?: @"--", capacityBytes ?: @"--"];
            self.scrollSpeedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.OverlayPromptScrollSpeedFormat", @"Scroll Speed: %@ x"), @"--"];
            
            // Update slider value
            if (scrollSpeed) {
                self.speedSlider.value = [scrollSpeed floatValue];
                NSString* speedString = [NSString stringWithFormat:@"%.1fx", [scrollSpeed floatValue] / 100.0];
                self.scrollSpeedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.OverlayPromptScrollSpeedFormat", @"Scroll Speed: %@ x"), speedString];
                
            }
            
            [self showLoading:NO];
        });
    });
}

- (void)sendPromptButtonTapped:(UIButton *)sender {
    NSString *promptText = self.promptInputView.text;
    
    if (!promptText || promptText.length == 0) {
        [self showStatus:NSLocalizedString(@"LocKey.OverlayPromptEmptyTips", @"Please enter prompt text") error:YES];
        return;
    }
    
    [self showLoading:YES];
    
    id<AIBudsTeleprompterAPI> teleprompterAPI = (id<AIBudsTeleprompterAPI>)self.device;
    
    if (!teleprompterAPI) {
        [self showStatus:NSLocalizedString(@"LocKey.OverlayPromptNotSupported", @"Overlay Prompt not supported") error:NO];
        [self showLoading:NO];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [teleprompterAPI sendOverlayPrompt:promptText 
                          progressHandler:^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showStatus:[NSString stringWithFormat:NSLocalizedString(@"LocKey.OverlayPromptSendingProgressFormat", @"Sending prompt text to device %.0f%%"), progress * 100] error:NO];
        });
    } completionHandler:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showLoading:NO];
            if (success) {
                [weakSelf showStatus:NSLocalizedString(@"LocKey.OverlayPromptSendSuccess", @"Prompt sent successfully") error:NO];
                // Start scroll animation
                [weakSelf startScrollAnimationWithText:promptText];
                [weakSelf fetchDeviceInfo];
            } else {
                [weakSelf showStatus:[NSString stringWithFormat:NSLocalizedString(@"LocKey.OverlayPromptSendFailedFormat", @"Send failed: %@"), error.localizedDescription] error:YES];
            }
        });
    }];
}

- (void)clearSlotButtonTapped:(UIButton *)sender {
    [self showLoading:YES];
    
    id<AIBudsTeleprompterAPI> teleprompterAPI = (id<AIBudsTeleprompterAPI>)self.device;
    
    if (!teleprompterAPI) {
        [self showStatus:NSLocalizedString(@"LocKey.OverlayPromptNotSupported", @"Overlay Prompt not supported") error:NO];
        [self showLoading:NO];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [teleprompterAPI clearCurrentOverlayPromptSlotContentWithCompletion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showLoading:NO];
            if (success) {
                [weakSelf showStatus:NSLocalizedString(@"LocKey.OverlayPromptClearSuccess", @"Slot cleared successfully") error:NO];
                [weakSelf stopScrollAnimation];
                weakSelf.promptDisplayLabel.text = NSLocalizedString(@"LocKey.OverlayPromptDisplayHint", @"Enter prompt text to preview");
                [weakSelf fetchDeviceInfo];
            } else {
                [weakSelf showStatus:[NSString stringWithFormat:NSLocalizedString(@"LocKey.OverlayPromptClearFailedFormat", @"Slot clear failed: %@"), error.localizedDescription] error:YES];
            }
        });
    }];
}

- (void)toggleSlotButtonTapped:(UIButton *)sender {
    [self showLoading:YES];
    
    id<AIBudsTeleprompterAPI> teleprompterAPI = (id<AIBudsTeleprompterAPI>)self.device;
    
    if (!teleprompterAPI) {
        [self showStatus:NSLocalizedString(@"LocKey.OverlayPromptNotSupported", @"Overlay Prompt not supported") error:NO];
        [self showLoading:NO];
        return;
    }
    
    NSNumber *currentIndex = teleprompterAPI.overlayPromptSlotIndex;
    NSNumber *totalSlots = teleprompterAPI.overlayPromptTotalSlots;
    
    NSInteger current = [currentIndex integerValue];
    NSInteger total = [totalSlots integerValue];
    NSInteger nextIndex = (current + 1) % total;
    
    __weak typeof(self) weakSelf = self;
    [teleprompterAPI toggleOverlayPromptSlotIndexTo:nextIndex completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showLoading:NO];
            if (success) {
                [weakSelf showStatus:[NSString stringWithFormat:NSLocalizedString(@"LocKey.OverlayPromptSlotToggleSuccess", @"Toggled to slot %ld"), (long)nextIndex] error:NO];
                [weakSelf fetchDeviceInfo];
            } else {
                [weakSelf showStatus:[NSString stringWithFormat:NSLocalizedString(@"LocKey.OverlayPromptSlotToggleFailedFormat", @"Toggle failed: %@"), error.localizedDescription] error:YES];
            }
        });
    }];
}

- (void)applySpeedButtonTapped:(UIButton *)sender {
    NSInteger speed = (NSInteger)self.speedSlider.value;
    
    [self showLoading:YES];
    
    id<AIBudsTeleprompterAPI> teleprompterAPI = (id<AIBudsTeleprompterAPI>)self.device;
    
    if (!teleprompterAPI) {
        [self showStatus:NSLocalizedString(@"LocKey.OverlayPromptNotSupported", @"Overlay Prompt not supported") error:NO];
        [self showLoading:NO];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [teleprompterAPI setOverlayPromptScrollSpeed:speed completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showLoading:NO];
            if (success) {
                [weakSelf showStatus:[NSString stringWithFormat:NSLocalizedString(@"LocKey.OverlayPromptSpeedApplied", @"Speed %.1fx applied successfully"), (float)speed / 100.0] error:NO];
                [weakSelf fetchDeviceInfo];
            } else {
                [weakSelf showStatus:[NSString stringWithFormat:NSLocalizedString(@"LocKey.OverlayPromptSpeedFailedFormat", @"Apply speed failed: %@"), error.localizedDescription] error:YES];
            }
        });
    }];
}

#pragma mark - Scroll Animation

- (void)speedSliderValueChanged:(UISlider *)sender {
    NSInteger speed = (NSInteger)sender.value;
    self.speedValueLabel.text = [NSString stringWithFormat:@"%.1fx", (float)speed / 100.0];
    
    // Update scroll animation speed
    if (self.scrollTimer) {
        [self updateScrollAnimationSpeed:speed];
    }
    
    // Update display label text if input has content
    if (self.promptInputView.text.length > 0 && !self.scrollTimer) {
        [self startScrollAnimationWithText:self.promptInputView.text];
    }
}

- (void)startScrollAnimationWithText:(NSString *)text {
    [self stopScrollAnimation];
    
    if (!text || text.length == 0) {
        self.promptDisplayLabel.text = NSLocalizedString(@"LocKey.OverlayPromptDefaultDisplayHint", @"Enter prompt text to preview");
        return;
    }
    
    self.promptDisplayLabel.text = text;
    self.scrollOffset = 0;
    
    // Calculate scroll speed based on slider value
    NSInteger speed = (NSInteger)self.speedSlider.value;
    NSTimeInterval interval = 0.05 / (speed / 100.0);
    
    self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                       target:self
                                                     selector:@selector(updateScrollOffset)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)updateScrollAnimationSpeed:(NSInteger)speed {
    if (self.scrollTimer) {
        [self.scrollTimer invalidate];
        self.scrollTimer = nil;
        
        NSTimeInterval interval = 0.05 / (speed / 100.0);
        self.scrollTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                           target:self
                                                         selector:@selector(updateScrollOffset)
                                                         userInfo:nil
                                                          repeats:YES];
    }
}

- (void)updateScrollOffset {
    self.scrollOffset += 1.0;
    
    // Reset when offset exceeds text width
    CGFloat textWidth = [self.promptDisplayLabel.text sizeWithAttributes:@{NSFontAttributeName: self.promptDisplayLabel.font}].width;
    CGFloat displayWidth = self.displayCard.bounds.size.width - 40; // subtract padding
    
    if (textWidth <= displayWidth) {
        // Text fits, no scrolling needed
        self.promptDisplayLabel.transform = CGAffineTransformIdentity;
        return;
    }
    
    if (self.scrollOffset >= textWidth - displayWidth + 20) {
        self.scrollOffset = 0;
    }
    
    self.promptDisplayLabel.transform = CGAffineTransformMakeTranslation(-self.scrollOffset, 0);
}

- (void)stopScrollAnimation {
    if (self.scrollTimer) {
        [self.scrollTimer invalidate];
        self.scrollTimer = nil;
    }
    self.promptDisplayLabel.transform = CGAffineTransformIdentity;
}

#pragma mark - UI Helpers

- (void)showLoading:(BOOL)loading {
    
    // Disable all buttons during loading
    self.sendPromptButton.enabled = !loading;
    self.clearSlotButton.enabled = !loading;
    self.toggleSlotButton.enabled = !loading;
    self.applySpeedButton.enabled = !loading;
    self.speedSlider.enabled = !loading;
    self.promptInputView.editable = !loading;
}

- (void)showStatus:(NSString *)status error:(BOOL)isError {
    
    [self.view makeToast:status duration:3.0 position:CSToastPositionTop];
}


#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self startScrollAnimationWithText:textView.text];
}

@end


