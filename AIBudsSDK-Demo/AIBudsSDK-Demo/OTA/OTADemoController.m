//
//  OTADemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-03-02.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "OTADemoController.h"
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

static UIColor *OtaDemoColor(NSInteger red, NSInteger green, NSInteger blue) {
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1.0];
}

@interface OtaDemoGradientCardView : UIView
@end

@implementation OtaDemoGradientCardView

+ (Class)layerClass {
    return CAGradientLayer.class;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
        gradientLayer.colors = @[(id)OtaDemoColor(47, 91, 234).CGColor,
                                 (id)OtaDemoColor(104, 75, 215).CGColor];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 1);
        gradientLayer.cornerRadius = 22;
        gradientLayer.masksToBounds = YES;
    }
    return self;
}

@end

@interface OTADemoController () <UIDocumentPickerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *mainStackView;

// 升级进度相关 UI
@property (nonatomic, strong) UIProgressView *progressView;        // 进度条
@property (nonatomic, strong) UILabel *percentLabel;               // 百分比文字
@property (nonatomic, strong) UILabel *filePathLabel;              // 升级文件路径
@property (nonatomic, strong) UILabel *statusLabel;                // 状态描述
@property (nonatomic, strong) UIButton *startButton;               // 开始升级按钮
@property (nonatomic, strong) UIButton *selectFileButton;          // 选择文件按钮
@property (nonatomic, strong) UILabel *protocolTitleLabel;         // OTA 协议标题
@property (nonatomic, strong) UISegmentedControl *protocolControl; // OTA 协议选择

// 升级结果相关 UI
@property (nonatomic, strong) UIView *resultContainer;               // 结果展示容器
@property (nonatomic, strong) UILabel *fileSizeLabel;                // 文件大小
@property (nonatomic, strong) UILabel *transferredBytesLabel;      // 本次传输字节数
@property (nonatomic, strong) UILabel *totalTimeLabel;             // 总耗时
@property (nonatomic, strong) UILabel *pausedTimeLabel;            // 暂停时间
@property (nonatomic, strong) UILabel *actualTimeLabel;            // 实际用时
@property (nonatomic, strong) UILabel *avgSpeedLabel;              // 平均速度 kB/s

// 数据记录
@property (nonatomic, assign) NSTimeInterval startTime;              // 开始时间
@property (nonatomic, assign) NSTimeInterval pausedTime;           // 暂停时间
@property (nonatomic, strong) NSURL *selectedFileURL;                // 选中的文件 URL
@property (nonatomic, strong) NSNumber* selectedFileSize;              // 选中的文件大小 (Bytes)
@property (nonatomic, copy) NSArray<NSNumber *> *availableOtaProtocols; // 可选 OTA 协议

@end

@implementation OTADemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"LocKey.OtaDemoTitle", nil);
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    [self setupUI];
    [self configureOtaProtocolControl];
}

#pragma mark - UI 构建

- (void)setupUI {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:self.scrollView];

    self.mainStackView = [[UIStackView alloc] init];
    self.mainStackView.axis = UILayoutConstraintAxisVertical;
    self.mainStackView.spacing = 16;
    self.mainStackView.alignment = UIStackViewAlignmentFill;
    self.mainStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.mainStackView];

    [self createStatusCard];
    [self createFirmwareCard];
    [self createProgressCard];
    [self createResultCard];

    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [self.mainStackView.topAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.topAnchor constant:16],
        [self.mainStackView.leadingAnchor constraintEqualToAnchor:self.scrollView.frameLayoutGuide.leadingAnchor constant:16],
        [self.mainStackView.trailingAnchor constraintEqualToAnchor:self.scrollView.frameLayoutGuide.trailingAnchor constant:-16],
        [self.mainStackView.bottomAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.bottomAnchor constant:-28]
    ]];
}

- (void)createStatusCard {
    OtaDemoGradientCardView *card = [[OtaDemoGradientCardView alloc] init];
    card.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *eyebrowLabel = [[UILabel alloc] init];
    eyebrowLabel.translatesAutoresizingMaskIntoConstraints = NO;
    eyebrowLabel.text = NSLocalizedString(@"LocKey.OtaHeroEyebrow", nil);
    eyebrowLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
    eyebrowLabel.textColor = [UIColor colorWithWhite:1 alpha:0.64];
    [card addSubview:eyebrowLabel];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = NSLocalizedString(@"LocKey.OtaDemoTitle", nil);
    titleLabel.font = [UIFont systemFontOfSize:27 weight:UIFontWeightBold];
    titleLabel.textColor = UIColor.whiteColor;
    [card addSubview:titleLabel];

    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusLabel.text = NSLocalizedString(@"LocKey.OtaStatusWaiting", nil);
    self.statusLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.statusLabel.textColor = [UIColor colorWithWhite:1 alpha:0.78];
    self.statusLabel.numberOfLines = 0;
    [card addSubview:self.statusLabel];

    UIView *iconBackground = [[UIView alloc] init];
    iconBackground.translatesAutoresizingMaskIntoConstraints = NO;
    iconBackground.backgroundColor = [UIColor colorWithWhite:1 alpha:0.13];
    iconBackground.layer.cornerRadius = 24;
    [card addSubview:iconBackground];

    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"arrow.triangle.2.circlepath.circle.fill"]];
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    iconView.tintColor = UIColor.whiteColor;
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    [iconBackground addSubview:iconView];

    [NSLayoutConstraint activateConstraints:@[
        [eyebrowLabel.topAnchor constraintEqualToAnchor:card.topAnchor constant:24],
        [eyebrowLabel.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:22],
        [eyebrowLabel.trailingAnchor constraintLessThanOrEqualToAnchor:iconBackground.leadingAnchor constant:-16],
        [titleLabel.topAnchor constraintEqualToAnchor:eyebrowLabel.bottomAnchor constant:5],
        [titleLabel.leadingAnchor constraintEqualToAnchor:eyebrowLabel.leadingAnchor],
        [titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:iconBackground.leadingAnchor constant:-16],
        [self.statusLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:8],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-22],
        [self.statusLabel.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-24],
        [iconBackground.topAnchor constraintEqualToAnchor:card.topAnchor constant:20],
        [iconBackground.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-20],
        [iconBackground.widthAnchor constraintEqualToConstant:48],
        [iconBackground.heightAnchor constraintEqualToConstant:48],
        [iconView.centerXAnchor constraintEqualToAnchor:iconBackground.centerXAnchor],
        [iconView.centerYAnchor constraintEqualToAnchor:iconBackground.centerYAnchor],
        [iconView.widthAnchor constraintEqualToConstant:25],
        [iconView.heightAnchor constraintEqualToConstant:25]
    ]];

    [self.mainStackView addArrangedSubview:card];
}

- (void)createFirmwareCard {
    UIView *card = [self createCard];

    UILabel *titleLabel = [self sectionTitleLabelWithText:NSLocalizedString(@"LocKey.OtaFirmwareSectionTitle", nil)];
    [card addSubview:titleLabel];

    UIView *fileContainer = [[UIView alloc] init];
    fileContainer.translatesAutoresizingMaskIntoConstraints = NO;
    fileContainer.backgroundColor = UIColor.tertiarySystemGroupedBackgroundColor;
    fileContainer.layer.cornerRadius = 14;
    [card addSubview:fileContainer];

    UIImageView *fileIcon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"doc.badge.gearshape"]];
    fileIcon.translatesAutoresizingMaskIntoConstraints = NO;
    fileIcon.tintColor = OtaDemoColor(72, 86, 220);
    fileIcon.contentMode = UIViewContentModeScaleAspectFit;
    [fileContainer addSubview:fileIcon];

    self.filePathLabel = [[UILabel alloc] init];
    self.filePathLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.filePathLabel.text = NSLocalizedString(@"LocKey.OtaStatusNoFirmwareSelected", nil);
    self.filePathLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.filePathLabel.textColor = UIColor.secondaryLabelColor;
    self.filePathLabel.numberOfLines = 2;
    self.filePathLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [fileContainer addSubview:self.filePathLabel];

    self.selectFileButton = [self createSecondaryButtonWithTitle:NSLocalizedString(@"LocKey.OtaSelectFileButtonTitle", nil)
                                                       imageName:@"folder.badge.plus"];
    [self.selectFileButton addTarget:self action:@selector(selectFirmwareFile) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:self.selectFileButton];

    self.protocolTitleLabel = [[UILabel alloc] init];
    self.protocolTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.protocolTitleLabel.text = NSLocalizedString(@"LocKey.OtaProtocolTitle", nil);
    self.protocolTitleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    self.protocolTitleLabel.textColor = UIColor.secondaryLabelColor;
    [card addSubview:self.protocolTitleLabel];

    self.protocolControl = [[UISegmentedControl alloc] initWithItems:@[]];
    self.protocolControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.protocolControl.selectedSegmentTintColor = OtaDemoColor(72, 86, 220);
    [self.protocolControl setTitleTextAttributes:@{NSForegroundColorAttributeName: UIColor.whiteColor,
                                                   NSFontAttributeName: [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold]}
                                        forState:UIControlStateSelected];
    [self.protocolControl addTarget:self action:@selector(otaProtocolSelectionChanged:) forControlEvents:UIControlEventValueChanged];
    [card addSubview:self.protocolControl];

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:card.topAnchor constant:22],
        [titleLabel.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:22],
        [titleLabel.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-22],
        [fileContainer.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:16],
        [fileContainer.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:20],
        [fileContainer.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-20],
        [fileContainer.heightAnchor constraintGreaterThanOrEqualToConstant:62],
        [fileIcon.leadingAnchor constraintEqualToAnchor:fileContainer.leadingAnchor constant:16],
        [fileIcon.centerYAnchor constraintEqualToAnchor:fileContainer.centerYAnchor],
        [fileIcon.widthAnchor constraintEqualToConstant:24],
        [fileIcon.heightAnchor constraintEqualToConstant:24],
        [self.filePathLabel.topAnchor constraintEqualToAnchor:fileContainer.topAnchor constant:12],
        [self.filePathLabel.bottomAnchor constraintEqualToAnchor:fileContainer.bottomAnchor constant:-12],
        [self.filePathLabel.leadingAnchor constraintEqualToAnchor:fileIcon.trailingAnchor constant:12],
        [self.filePathLabel.trailingAnchor constraintEqualToAnchor:fileContainer.trailingAnchor constant:-14],
        [self.selectFileButton.topAnchor constraintEqualToAnchor:fileContainer.bottomAnchor constant:12],
        [self.selectFileButton.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:20],
        [self.selectFileButton.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-20],
        [self.selectFileButton.heightAnchor constraintEqualToConstant:46],
        [self.protocolTitleLabel.topAnchor constraintEqualToAnchor:self.selectFileButton.bottomAnchor constant:20],
        [self.protocolTitleLabel.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:20],
        [self.protocolTitleLabel.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-20],
        [self.protocolControl.topAnchor constraintEqualToAnchor:self.protocolTitleLabel.bottomAnchor constant:9],
        [self.protocolControl.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:20],
        [self.protocolControl.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-20],
        [self.protocolControl.heightAnchor constraintEqualToConstant:36],
        [self.protocolControl.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-22]
    ]];

    [self.mainStackView addArrangedSubview:card];
}

- (void)createProgressCard {
    UIView *card = [self createCard];
    UILabel *titleLabel = [self sectionTitleLabelWithText:NSLocalizedString(@"LocKey.OtaProgressSectionTitle", nil)];
    [card addSubview:titleLabel];

    self.percentLabel = [[UILabel alloc] init];
    self.percentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.percentLabel.text = @"0%";
    self.percentLabel.font = [UIFont monospacedDigitSystemFontOfSize:18 weight:UIFontWeightBold];
    self.percentLabel.textColor = OtaDemoColor(72, 86, 220);
    self.percentLabel.textAlignment = NSTextAlignmentRight;
    [card addSubview:self.percentLabel];

    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressView.progressTintColor = OtaDemoColor(72, 86, 220);
    self.progressView.trackTintColor = UIColor.tertiarySystemFillColor;
    self.progressView.layer.cornerRadius = 4;
    self.progressView.clipsToBounds = YES;
    [card addSubview:self.progressView];

    self.startButton = [self createButtonWithTitle:NSLocalizedString(@"LocKey.OtaStartButtonTitle", nil)];
    [self.startButton setImage:[UIImage systemImageNamed:@"arrow.up.circle.fill"] forState:UIControlStateNormal];
    self.startButton.tintColor = UIColor.whiteColor;
    [self.startButton addTarget:self action:@selector(startUpgrade) forControlEvents:UIControlEventTouchUpInside];
    self.startButton.enabled = NO;
    [card addSubview:self.startButton];

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:card.topAnchor constant:22],
        [titleLabel.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:22],
        [self.percentLabel.centerYAnchor constraintEqualToAnchor:titleLabel.centerYAnchor],
        [self.percentLabel.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-22],
        [self.percentLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:titleLabel.trailingAnchor constant:12],
        [self.progressView.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:18],
        [self.progressView.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:20],
        [self.progressView.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-20],
        [self.progressView.heightAnchor constraintEqualToConstant:8],
        [self.startButton.topAnchor constraintEqualToAnchor:self.progressView.bottomAnchor constant:22],
        [self.startButton.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:20],
        [self.startButton.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-20],
        [self.startButton.heightAnchor constraintEqualToConstant:50],
        [self.startButton.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-22]
    ]];

    [self.mainStackView addArrangedSubview:card];
}

- (void)createResultCard {
    self.resultContainer = [self createCard];
    self.resultContainer.hidden = YES;
    UILabel *resultTitle = [self sectionTitleLabelWithText:NSLocalizedString(@"LocKey.OtaResultTitle", nil)];
    [self.resultContainer addSubview:resultTitle];

    UILabel *lastLabel = resultTitle;
    NSArray<NSString *> *labelKeys = @[@"fileSizeLabel", @"transferredBytesLabel", @"totalTimeLabel",
                                      @"pausedTimeLabel", @"actualTimeLabel", @"avgSpeedLabel"];
    for (NSString *key in labelKeys) {
        UILabel *valueLabel = [[UILabel alloc] init];
        valueLabel.text = @"—";
        valueLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        valueLabel.textColor = UIColor.secondaryLabelColor;
        valueLabel.numberOfLines = 0;
        [self.resultContainer addSubview:valueLabel];
        valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [valueLabel.topAnchor constraintEqualToAnchor:lastLabel.bottomAnchor constant:12],
            [valueLabel.leadingAnchor constraintEqualToAnchor:self.resultContainer.leadingAnchor constant:20],
            [valueLabel.trailingAnchor constraintEqualToAnchor:self.resultContainer.trailingAnchor constant:-20]
        ]];
        [self setValue:valueLabel forKey:key];
        lastLabel = valueLabel;
    }
    [lastLabel.bottomAnchor constraintEqualToAnchor:self.resultContainer.bottomAnchor constant:-22].active = YES;
    [resultTitle.topAnchor constraintEqualToAnchor:self.resultContainer.topAnchor constant:22].active = YES;
    [resultTitle.leadingAnchor constraintEqualToAnchor:self.resultContainer.leadingAnchor constant:22].active = YES;
    [resultTitle.trailingAnchor constraintEqualToAnchor:self.resultContainer.trailingAnchor constant:-22].active = YES;
    [self.mainStackView addArrangedSubview:self.resultContainer];
}

#pragma mark - UI 辅助方法

- (UIView *)createCard {
    UIView *card = [[UIView alloc] init];
    card.translatesAutoresizingMaskIntoConstraints = NO;
    card.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
    card.layer.cornerRadius = 18;
    card.layer.shadowColor = UIColor.blackColor.CGColor;
    card.layer.shadowOffset = CGSizeMake(0, 2);
    card.layer.shadowOpacity = 0.04;
    card.layer.shadowRadius = 8;
    return card;
}

- (UIButton *)createButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithWhite:1 alpha:0.72] forState:UIControlStateDisabled];
    [button setBackgroundImage:[self imageWithColor:OtaDemoColor(72, 86, 220)] forState:UIControlStateNormal];
    [button setBackgroundImage:[self imageWithColor:OtaDemoColor(58, 69, 190)] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[self imageWithColor:UIColor.systemGray4Color] forState:UIControlStateDisabled];
    button.layer.cornerRadius = 14;
    button.clipsToBounds = YES;
    return button;
}

- (UIButton *)createSecondaryButtonWithTitle:(NSString *)title imageName:(NSString *)imageName {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:[UIImage systemImageNamed:imageName] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    button.tintColor = OtaDemoColor(72, 86, 220);
    button.backgroundColor = [OtaDemoColor(72, 86, 220) colorWithAlphaComponent:0.10];
    button.layer.cornerRadius = 13;
    return button;
}

- (UILabel *)sectionTitleLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = text;
    label.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    label.textColor = UIColor.labelColor;
    return label;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - OTA 协议选择

- (void)configureOtaProtocolControl {
    id<AIBudsDeviceOtaAPI> otaDevice = (id<AIBudsDeviceOtaAPI>)self.device;
    if (![otaDevice conformsToProtocol:@protocol(AIBudsDeviceOtaAPI)]) {
        self.availableOtaProtocols = @[];
        self.protocolControl.enabled = NO;
        self.statusLabel.text = NSLocalizedString(@"LocKey.OtaStatusUnsupported", nil);
        return;
    }

    NSMutableArray<NSNumber *> *protocols = [NSMutableArray array];
    switch (otaDevice.otaProtocolCapability) {
        case AIBudsOtaProtocolCapabilityFitcloudPro:
            if ([AIBudsSDK otaPluginForProtocolKind:AIBudsOtaProtocolKindFitcloudPro] != nil) {
                [protocols addObject:@(AIBudsOtaProtocolKindFitcloudPro)];
            }
            break;
        case AIBudsOtaProtocolCapabilityAbmateAndFitcloudPro:
            [protocols addObject:@(AIBudsOtaProtocolKindAbmate)];
            if ([AIBudsSDK otaPluginForProtocolKind:AIBudsOtaProtocolKindFitcloudPro] != nil) {
                [protocols addObject:@(AIBudsOtaProtocolKindFitcloudPro)];
            }
            break;
        case AIBudsOtaProtocolCapabilityJieli:
            if ([AIBudsSDK otaPluginForProtocolKind:AIBudsOtaProtocolKindJieli] != nil) {
                [protocols addObject:@(AIBudsOtaProtocolKindJieli)];
            }
            break;
        case AIBudsOtaProtocolCapabilityNone:
        case AIBudsOtaProtocolCapabilityAbmate:
        default:
            [protocols addObject:@(AIBudsOtaProtocolKindAbmate)];
            break;
    }

    self.availableOtaProtocols = protocols.copy;
    [self.protocolControl removeAllSegments];
    [self.availableOtaProtocols enumerateObjectsUsingBlock:^(NSNumber * _Nonnull protocolValue, NSUInteger index, BOOL * _Nonnull stop) {
        AIBudsOtaProtocolKind protocolKind = (AIBudsOtaProtocolKind)protocolValue.integerValue;
        [self.protocolControl insertSegmentWithTitle:[self titleForOtaProtocol:protocolKind] atIndex:index animated:NO];
    }];
    self.protocolControl.selectedSegmentIndex = self.availableOtaProtocols.count > 0 ? 0 : UISegmentedControlNoSegment;
    self.protocolControl.enabled = self.availableOtaProtocols.count > 0;
    self.protocolControl.userInteractionEnabled = self.availableOtaProtocols.count > 1;
    if (self.availableOtaProtocols.count == 0) {
        self.statusLabel.text = NSLocalizedString(@"LocKey.OtaStatusPluginUnavailable", nil);
    }
}

- (NSString *)titleForOtaProtocol:(AIBudsOtaProtocolKind)protocolKind {
    switch (protocolKind) {
        case AIBudsOtaProtocolKindFitcloudPro:
            return @"FitCloud Pro";
        case AIBudsOtaProtocolKindJieli:
            return @"Jieli";
        case AIBudsOtaProtocolKindAbmate:
        default:
            return @"ABMate";
    }
}

- (void)otaProtocolSelectionChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == UISegmentedControlNoSegment) {
        return;
    }
    AIBudsOtaProtocolKind protocolKind = (AIBudsOtaProtocolKind)self.availableOtaProtocols[sender.selectedSegmentIndex].integerValue;
    self.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.OtaProtocolSelectedFormat", nil), [self titleForOtaProtocol:protocolKind]];
}

#pragma mark - 文件选择

- (void)selectFirmwareFile {
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[(__bridge NSString *)kUTTypeData] inMode:UIDocumentPickerModeOpen];
    picker.delegate = self;
    picker.allowsMultipleSelection = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count > 0) {
        NSURL *fileURL = urls.firstObject;
        
        // 获取授权
        [fileURL startAccessingSecurityScopedResource];
        
        // 通过文件协调工具来得到新的文件地址，以此得到文件保护功能
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;
        
        [fileCoordinator coordinateReadingItemAtURL:fileURL options:0 error:&error byAccessor:^(NSURL *newURL) {
            // 获取文件大小
            NSError *error;
            NSNumber *fileSizeValue;
            [newURL getResourceValue:&fileSizeValue forKey:NSURLFileSizeKey error:&error];
            
            // 将文件拷贝到缓存目录
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
            NSString *fileName = newURL.lastPathComponent ?: @"firmware.fot";
            NSString *cachePath = [cacheDir stringByAppendingPathComponent:fileName];
            NSURL *cacheURL = [NSURL fileURLWithPath:cachePath];
            
            NSError *copyError;
            [fileManager removeItemAtURL:cacheURL error:nil]; // 先删除旧文件
            if (![fileManager copyItemAtURL:newURL toURL:cacheURL error:&copyError]) {
                self.statusLabel.text = NSLocalizedString(@"LocKey.OtaStatusCopyFailed", nil);
                return;
            }
            
            self.selectedFileURL = cacheURL;
            self.selectedFileSize = fileSizeValue;
            NSString *sizeString = [NSByteCountFormatter stringFromByteCount:fileSizeValue.longLongValue
                                                                    countStyle:NSByteCountFormatterCountStyleFile];
            self.filePathLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.SelectedFileInfoFormat", nil),
                                       fileName,
                                       sizeString];
            self.startButton.enabled = self.availableOtaProtocols.count > 0;
            if (self.availableOtaProtocols.count > 0) {
                self.statusLabel.text = NSLocalizedString(@"LocKey.OtaStatusReady", nil);
            }
        }];
        [fileURL stopAccessingSecurityScopedResource];
        
        
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    // 用户取消选择，无需处理
}

#pragma mark - 升级逻辑

- (void)startUpgrade {
    if (!self.selectedFileURL) {
        self.statusLabel.text = NSLocalizedString(@"LocKey.OtaStatusSelectFile", nil);
        return;
    }

    id<AIBudsDeviceOtaAPI> device = (id<AIBudsDeviceOtaAPI>)self.device;
    if (![device conformsToProtocol:@protocol(AIBudsDeviceOtaAPI)]) {
        self.statusLabel.text = NSLocalizedString(@"LocKey.OtaStatusUnsupported", nil);
        return;
    }
    if (self.availableOtaProtocols.count == 0) {
        self.statusLabel.text = NSLocalizedString(@"LocKey.OtaStatusPluginUnavailable", nil);
        return;
    }
    
    self.startButton.enabled = NO;
    self.selectFileButton.enabled = NO;
    self.protocolControl.enabled = NO;
    self.protocolControl.userInteractionEnabled = NO;
    self.statusLabel.text = NSLocalizedString(@"LocKey.OtaStatusUpgrading", nil);
    self.resultContainer.hidden = YES;
    self.startTime = CACurrentMediaTime();
    self.pausedTime = 0;

    AIBudsOtaStartCompletionHandler startHandler = ^(BOOL success, NSError * _Nullable error) {
        if (!success) {
            [self finishUpgradeWithSuccess:NO avgSpeed:0 error:error];
        }
    };
    AIBudsOtaProgressHandler progressHandler = ^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.percentLabel.text = [NSString stringWithFormat:@"%.0f%%", progress * 100];
            self.progressView.progress = progress;
        });
    };
    AIBudsOtaCompletionHandler completionHandler = ^(BOOL success, CGFloat avgSpeed, NSError * _Nullable error) {
        [self finishUpgradeWithSuccess:success avgSpeed:avgSpeed error:error];
    };

    if (self.availableOtaProtocols.count > 1 && self.protocolControl.selectedSegmentIndex != UISegmentedControlNoSegment) {
        AIBudsOtaConfiguration *configuration = [[AIBudsOtaConfiguration alloc] init];
        configuration.otaProtocol = (AIBudsOtaProtocolKind)self.availableOtaProtocols[self.protocolControl.selectedSegmentIndex].integerValue;
        [device startOtaWithFilePath:self.selectedFileURL.path
                      configuration:configuration
                       startHandler:startHandler
                    progressHandler:progressHandler
                  completionHandler:completionHandler];
    } else {
        [device startOtaWithFilePath:self.selectedFileURL.path
                       startHandler:startHandler
                    progressHandler:progressHandler
                  completionHandler:completionHandler];
    }
}

- (void)finishUpgradeWithSuccess:(BOOL)success avgSpeed:(CGFloat)avgSpeed error:(NSError * _Nullable)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.startButton.enabled = self.selectedFileURL != nil && self.availableOtaProtocols.count > 0;
        self.selectFileButton.enabled = YES;
        self.protocolControl.enabled = self.availableOtaProtocols.count > 0;
        self.protocolControl.userInteractionEnabled = self.availableOtaProtocols.count > 1;
        if (success) {
            self.statusLabel.text = NSLocalizedString(@"LocKey.OtaStatusSuccess", nil);
            [self showResult:avgSpeed];
            return;
        }
        NSString *errorDesc = [error isKindOfClass:[NSError class]] ? error.localizedDescription : NSLocalizedString(@"LocKey.OtaStatusUnknownError", nil);
        self.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.OtaStatusFailedFormat", nil), errorDesc];
    });
}

- (void)showResult:(CGFloat)avgSpeed {
    NSTimeInterval totalTime = CACurrentMediaTime() - self.startTime;
    NSTimeInterval actualTime = totalTime - self.pausedTime;
    NSString *sizeString = [NSByteCountFormatter stringFromByteCount:self.selectedFileSize.longLongValue countStyle:NSByteCountFormatterCountStyleFile];
    self.fileSizeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.FileSizeLabelFormat", nil), sizeString];
    self.transferredBytesLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.TransferredBytesLabelFormat", nil), sizeString];
    self.totalTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.TotalTimeLabelFormat", nil), totalTime];
    self.pausedTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.PausedTimeLabelFormat", nil), self.pausedTime];
    self.actualTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.ActualTimeLabelFormat", nil), actualTime];
    self.avgSpeedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.AvgSpeedLabelFormat", nil), avgSpeed];

    self.resultContainer.hidden = NO;
    [self.view layoutIfNeeded];
    CGRect resultFrame = [self.resultContainer convertRect:self.resultContainer.bounds toView:self.scrollView];
    [self.scrollView scrollRectToVisible:CGRectInset(resultFrame, 0, -12) animated:YES];
}

@end
