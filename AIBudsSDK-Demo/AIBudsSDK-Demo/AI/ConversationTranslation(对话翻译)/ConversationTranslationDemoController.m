//
//  ConversationTranslationDemoController.m
//  AIBudsSDK-Demo
//

#import "ConversationTranslationDemoController.h"
#import "ConversationTranslationContext.h"

typedef NS_ENUM(NSInteger, ConversationSpeakerSide) {
    ConversationSpeakerSideMe,
    ConversationSpeakerSidePartner,
};

static UIColor *ConversationColor(NSInteger red, NSInteger green, NSInteger blue) {
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1.0];
}

@interface ConversationTranslationMessage : NSObject

@property (nonatomic, strong) NSNumber *sequence;
@property (nonatomic, assign) ConversationSpeakerSide side;
@property (nonatomic, copy) NSString *originalText;
@property (nonatomic, copy) NSString *translatedText;

@end


@implementation ConversationTranslationMessage
@end


@interface ConversationTranslationBubbleCell : UITableViewCell

@property (nonatomic, strong) UIView *bubbleView;
@property (nonatomic, strong) UILabel *speakerLabel;
@property (nonatomic, strong) UILabel *originalLabel;
@property (nonatomic, strong) UIView *divider;
@property (nonatomic, strong) UILabel *translationLabel;

- (instancetype)initWithSide:(ConversationSpeakerSide)side reuseIdentifier:(NSString *)reuseIdentifier;
- (void)configureWithMessage:(ConversationTranslationMessage *)message
                speakerName:(NSString *)speakerName;

@end


@implementation ConversationTranslationBubbleCell

- (instancetype)initWithSide:(ConversationSpeakerSide)side reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = UIColor.clearColor;

    self.bubbleView = [[UIView alloc] init];
    self.bubbleView.layer.cornerRadius = 20.0;
    self.bubbleView.layer.cornerCurve = kCACornerCurveContinuous;
    self.bubbleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.bubbleView];

    self.speakerLabel = [[UILabel alloc] init];
    self.speakerLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightSemibold];
    self.speakerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bubbleView addSubview:self.speakerLabel];

    self.originalLabel = [[UILabel alloc] init];
    self.originalLabel.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightMedium];
    self.originalLabel.numberOfLines = 0;
    self.originalLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bubbleView addSubview:self.originalLabel];

    self.divider = [[UIView alloc] init];
    self.divider.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bubbleView addSubview:self.divider];

    self.translationLabel = [[UILabel alloc] init];
    self.translationLabel.font = [UIFont systemFontOfSize:15.0];
    self.translationLabel.numberOfLines = 0;
    self.translationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bubbleView addSubview:self.translationLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.bubbleView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:7.0],
        [self.bubbleView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-7.0],
        [self.bubbleView.widthAnchor constraintLessThanOrEqualToAnchor:self.contentView.widthAnchor multiplier:0.82],
        [self.speakerLabel.topAnchor constraintEqualToAnchor:self.bubbleView.topAnchor constant:13.0],
        [self.speakerLabel.leadingAnchor constraintEqualToAnchor:self.bubbleView.leadingAnchor constant:16.0],
        [self.speakerLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.bubbleView.trailingAnchor constant:-16.0],
        [self.originalLabel.topAnchor constraintEqualToAnchor:self.speakerLabel.bottomAnchor constant:5.0],
        [self.originalLabel.leadingAnchor constraintEqualToAnchor:self.bubbleView.leadingAnchor constant:16.0],
        [self.originalLabel.trailingAnchor constraintEqualToAnchor:self.bubbleView.trailingAnchor constant:-16.0],
        [self.divider.topAnchor constraintEqualToAnchor:self.originalLabel.bottomAnchor constant:10.0],
        [self.divider.leadingAnchor constraintEqualToAnchor:self.originalLabel.leadingAnchor],
        [self.divider.trailingAnchor constraintEqualToAnchor:self.originalLabel.trailingAnchor],
        [self.divider.heightAnchor constraintEqualToConstant:1.0 / UIScreen.mainScreen.scale],
        [self.translationLabel.topAnchor constraintEqualToAnchor:self.divider.bottomAnchor constant:9.0],
        [self.translationLabel.leadingAnchor constraintEqualToAnchor:self.originalLabel.leadingAnchor],
        [self.translationLabel.trailingAnchor constraintEqualToAnchor:self.originalLabel.trailingAnchor],
        [self.translationLabel.bottomAnchor constraintEqualToAnchor:self.bubbleView.bottomAnchor constant:-14.0],
    ]];

    if (side == ConversationSpeakerSideMe) {
        [NSLayoutConstraint activateConstraints:@[
            [self.bubbleView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16.0],
            [self.bubbleView.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.leadingAnchor constant:58.0],
        ]];
    } else {
        [NSLayoutConstraint activateConstraints:@[
            [self.bubbleView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16.0],
            [self.bubbleView.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.trailingAnchor constant:-58.0],
        ]];
    }
    return self;
}

- (void)configureWithMessage:(ConversationTranslationMessage *)message
                speakerName:(NSString *)speakerName {
    BOOL isMe = message.side == ConversationSpeakerSideMe;
    self.speakerLabel.text = speakerName;
    self.originalLabel.text = message.originalText.length > 0
        ? message.originalText
        : NSLocalizedString(@"LocKey.ConversationRecognizing", nil);
    self.translationLabel.text = message.translatedText.length > 0
        ? message.translatedText
        : NSLocalizedString(@"LocKey.ConversationTranslating", nil);

    if (isMe) {
        self.bubbleView.backgroundColor = ConversationColor(69, 91, 221);
        self.speakerLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.72];
        self.originalLabel.textColor = UIColor.whiteColor;
        self.translationLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.88];
        self.divider.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.20];
    } else {
        self.bubbleView.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
        self.speakerLabel.textColor = ConversationColor(80, 98, 194);
        self.originalLabel.textColor = UIColor.labelColor;
        self.translationLabel.textColor = UIColor.secondaryLabelColor;
        self.divider.backgroundColor = UIColor.separatorColor;
    }
}

@end


@interface ConversationTranslationDemoController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *languages;
@property (nonatomic, copy) NSString *myLanguageCode;
@property (nonatomic, copy) NSString *partnerLanguageCode;

@property (nonatomic, strong) UIView *languageCard;
@property (nonatomic, strong) UIButton *myLanguageButton;
@property (nonatomic, strong) UIButton *partnerLanguageButton;
@property (nonatomic, strong) UIButton *swapButton;
@property (nonatomic, strong) UIView *statusDot;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *statusHintLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *emptyStateView;
@property (nonatomic, strong) UILabel *emptyTitleLabel;
@property (nonatomic, strong) UILabel *emptyDetailLabel;
@property (nonatomic, strong) UIButton *meButton;
@property (nonatomic, strong) UIButton *partnerButton;
@property (nonatomic, strong) UILabel *privacyHintLabel;

@property (nonatomic, strong) NSMutableArray<ConversationTranslationMessage *> *messages;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, ConversationTranslationMessage *> *activeTurnMessages;
@property (nonatomic, assign) ConversationSpeakerSide activeSide;
@property (nonatomic, assign) BOOL isSessionActive;
@property (nonatomic, assign) BOOL isStopping;
@property (nonatomic, strong, nullable) id<AIBudsSimultaneousInterpretationSessionConvertible> currentSession;
@property (nonatomic, assign) BOOL isStartingDeviceRecording;
@property (nonatomic, assign) BOOL isDeviceRecordingActive;
@property (nonatomic, assign) BOOL shouldStopAfterDeviceRecordingStarts;

@end


@implementation ConversationTranslationDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"LocKey.ConversationTranslationDemoTitle", nil);
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.messages = [NSMutableArray array];
    self.activeTurnMessages = [NSMutableDictionary dictionary];
    [self setupLanguages];
    [self setupUI];
    [self refreshLanguageUI];
    [self refreshSessionUI];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.isMovingFromParentViewController && self.isSessionActive) {
        [self stopCurrentTurn];
    }
}

- (void)setupLanguages {
    self.languages = @[
        @{@"code": @"zh-CN", @"name": NSLocalizedString(@"LocKey.Chinese", nil), @"short": @"中文"},
        @{@"code": @"en-US", @"name": NSLocalizedString(@"LocKey.English", nil), @"short": @"EN"},
        @{@"code": @"ja-JP", @"name": NSLocalizedString(@"LocKey.Japanese", nil), @"short": @"日本語"},
        @{@"code": @"ko-KR", @"name": NSLocalizedString(@"LocKey.Korean", nil), @"short": @"한국어"},
        @{@"code": @"fr-FR", @"name": NSLocalizedString(@"LocKey.French", nil), @"short": @"FR"},
        @{@"code": @"de-DE", @"name": NSLocalizedString(@"LocKey.German", nil), @"short": @"DE"},
    ];
    NSString *systemLanguage = NSLocale.preferredLanguages.firstObject;
    if ([systemLanguage hasPrefix:@"zh"]) {
        self.myLanguageCode = @"zh-CN";
        self.partnerLanguageCode = @"en-US";
    } else {
        self.myLanguageCode = @"en-US";
        self.partnerLanguageCode = @"zh-CN";
    }
}

- (UIView *)cardView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
    view.layer.cornerRadius = 18.0;
    view.layer.cornerCurve = kCACornerCurveContinuous;
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

- (UIButton *)languageButtonWithTag:(NSInteger)tag {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tag = tag;
    button.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
    button.titleLabel.numberOfLines = 2;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.tintColor = UIColor.labelColor;
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button addTarget:self action:@selector(selectLanguage:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)turnButtonWithImage:(NSString *)imageName action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
    button.layer.cornerRadius = 18.0;
    button.layer.cornerCurve = kCACornerCurveContinuous;
    button.layer.borderWidth = 1.0;
    button.layer.borderColor = UIColor.separatorColor.CGColor;
    button.titleLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightSemibold];
    button.titleLabel.numberOfLines = 2;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.tintColor = ConversationColor(69, 91, 221);
    [button setImage:[UIImage systemImageNamed:imageName] forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -6, 0, 6);
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)setupUI {
    self.languageCard = [self cardView];
    [self.view addSubview:self.languageCard];

    self.myLanguageButton = [self languageButtonWithTag:0];
    self.partnerLanguageButton = [self languageButtonWithTag:1];
    [self.languageCard addSubview:self.myLanguageButton];
    [self.languageCard addSubview:self.partnerLanguageButton];

    self.swapButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.swapButton.backgroundColor = ConversationColor(236, 239, 255);
    self.swapButton.tintColor = ConversationColor(69, 91, 221);
    self.swapButton.layer.cornerRadius = 18.0;
    [self.swapButton setImage:[UIImage systemImageNamed:@"arrow.left.arrow.right"] forState:UIControlStateNormal];
    self.swapButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.swapButton addTarget:self action:@selector(swapLanguages) forControlEvents:UIControlEventTouchUpInside];
    [self.languageCard addSubview:self.swapButton];

    self.statusDot = [[UIView alloc] init];
    self.statusDot.layer.cornerRadius = 5.0;
    self.statusDot.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.statusDot];

    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightSemibold];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.statusLabel];

    self.statusHintLabel = [[UILabel alloc] init];
    self.statusHintLabel.font = [UIFont systemFontOfSize:12.0];
    self.statusHintLabel.textColor = UIColor.secondaryLabelColor;
    self.statusHintLabel.textAlignment = NSTextAlignmentRight;
    self.statusHintLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.statusHintLabel];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.estimatedRowHeight = 120.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.contentInset = UIEdgeInsetsMake(8.0, 0, 8.0, 0);
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];

    self.emptyStateView = [[UIView alloc] init];
    self.emptyStateView.userInteractionEnabled = NO;
    self.emptyStateView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView addSubview:self.emptyStateView];

    UIImageView *emptyImage = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"person.2.wave.2"]];
    emptyImage.tintColor = ConversationColor(118, 130, 206);
    emptyImage.contentMode = UIViewContentModeScaleAspectFit;
    emptyImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self.emptyStateView addSubview:emptyImage];

    self.emptyTitleLabel = [[UILabel alloc] init];
    self.emptyTitleLabel.text = NSLocalizedString(@"LocKey.ConversationEmptyTitle", nil);
    self.emptyTitleLabel.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightSemibold];
    self.emptyTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.emptyStateView addSubview:self.emptyTitleLabel];

    self.emptyDetailLabel = [[UILabel alloc] init];
    self.emptyDetailLabel.text = NSLocalizedString(@"LocKey.ConversationEmptyDetail", nil);
    self.emptyDetailLabel.font = [UIFont systemFontOfSize:14.0];
    self.emptyDetailLabel.textColor = UIColor.secondaryLabelColor;
    self.emptyDetailLabel.numberOfLines = 0;
    self.emptyDetailLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyDetailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.emptyStateView addSubview:self.emptyDetailLabel];

    UIView *controls = [self cardView];
    [self.view addSubview:controls];
    self.meButton = [self turnButtonWithImage:@"mic.fill" action:@selector(didTapMe)];
    self.partnerButton = [self turnButtonWithImage:@"person.wave.2.fill" action:@selector(didTapPartner)];
    [controls addSubview:self.meButton];
    [controls addSubview:self.partnerButton];

    self.privacyHintLabel = [[UILabel alloc] init];
    self.privacyHintLabel.text = NSLocalizedString(@"LocKey.ConversationPrivacyHint", nil);
    self.privacyHintLabel.font = [UIFont systemFontOfSize:11.0];
    self.privacyHintLabel.textColor = UIColor.tertiaryLabelColor;
    self.privacyHintLabel.textAlignment = NSTextAlignmentCenter;
    self.privacyHintLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [controls addSubview:self.privacyHintLabel];

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.languageCard.topAnchor constraintEqualToAnchor:safe.topAnchor constant:12.0],
        [self.languageCard.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16.0],
        [self.languageCard.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16.0],
        [self.languageCard.heightAnchor constraintEqualToConstant:78.0],
        [self.swapButton.centerXAnchor constraintEqualToAnchor:self.languageCard.centerXAnchor],
        [self.swapButton.centerYAnchor constraintEqualToAnchor:self.languageCard.centerYAnchor],
        [self.swapButton.widthAnchor constraintEqualToConstant:36.0],
        [self.swapButton.heightAnchor constraintEqualToConstant:36.0],
        [self.myLanguageButton.leadingAnchor constraintEqualToAnchor:self.languageCard.leadingAnchor constant:10.0],
        [self.myLanguageButton.trailingAnchor constraintEqualToAnchor:self.swapButton.leadingAnchor constant:-8.0],
        [self.myLanguageButton.topAnchor constraintEqualToAnchor:self.languageCard.topAnchor constant:6.0],
        [self.myLanguageButton.bottomAnchor constraintEqualToAnchor:self.languageCard.bottomAnchor constant:-6.0],
        [self.partnerLanguageButton.leadingAnchor constraintEqualToAnchor:self.swapButton.trailingAnchor constant:8.0],
        [self.partnerLanguageButton.trailingAnchor constraintEqualToAnchor:self.languageCard.trailingAnchor constant:-10.0],
        [self.partnerLanguageButton.topAnchor constraintEqualToAnchor:self.myLanguageButton.topAnchor],
        [self.partnerLanguageButton.bottomAnchor constraintEqualToAnchor:self.myLanguageButton.bottomAnchor],
        [self.statusDot.leadingAnchor constraintEqualToAnchor:self.languageCard.leadingAnchor constant:4.0],
        [self.statusDot.topAnchor constraintEqualToAnchor:self.languageCard.bottomAnchor constant:17.0],
        [self.statusDot.widthAnchor constraintEqualToConstant:10.0],
        [self.statusDot.heightAnchor constraintEqualToConstant:10.0],
        [self.statusLabel.centerYAnchor constraintEqualToAnchor:self.statusDot.centerYAnchor],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.statusDot.trailingAnchor constant:8.0],
        [self.statusHintLabel.centerYAnchor constraintEqualToAnchor:self.statusDot.centerYAnchor],
        [self.statusHintLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.statusLabel.trailingAnchor constant:8.0],
        [self.statusHintLabel.trailingAnchor constraintEqualToAnchor:self.languageCard.trailingAnchor constant:-4.0],
        [controls.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:12.0],
        [controls.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-12.0],
        [controls.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-8.0],
        [controls.heightAnchor constraintEqualToConstant:110.0],
        [self.meButton.leadingAnchor constraintEqualToAnchor:controls.leadingAnchor constant:10.0],
        [self.meButton.topAnchor constraintEqualToAnchor:controls.topAnchor constant:10.0],
        [self.meButton.heightAnchor constraintEqualToConstant:68.0],
        [self.partnerButton.leadingAnchor constraintEqualToAnchor:self.meButton.trailingAnchor constant:10.0],
        [self.partnerButton.trailingAnchor constraintEqualToAnchor:controls.trailingAnchor constant:-10.0],
        [self.partnerButton.topAnchor constraintEqualToAnchor:self.meButton.topAnchor],
        [self.partnerButton.heightAnchor constraintEqualToAnchor:self.meButton.heightAnchor],
        [self.partnerButton.widthAnchor constraintEqualToAnchor:self.meButton.widthAnchor],
        [self.privacyHintLabel.topAnchor constraintEqualToAnchor:self.meButton.bottomAnchor constant:8.0],
        [self.privacyHintLabel.leadingAnchor constraintEqualToAnchor:controls.leadingAnchor constant:8.0],
        [self.privacyHintLabel.trailingAnchor constraintEqualToAnchor:controls.trailingAnchor constant:-8.0],
        [self.tableView.topAnchor constraintEqualToAnchor:self.statusDot.bottomAnchor constant:9.0],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:controls.topAnchor constant:-8.0],
        [self.emptyStateView.centerXAnchor constraintEqualToAnchor:self.tableView.frameLayoutGuide.centerXAnchor],
        [self.emptyStateView.centerYAnchor constraintEqualToAnchor:self.tableView.frameLayoutGuide.centerYAnchor],
        [self.emptyStateView.widthAnchor constraintLessThanOrEqualToAnchor:self.tableView.frameLayoutGuide.widthAnchor constant:-64.0],
        [emptyImage.topAnchor constraintEqualToAnchor:self.emptyStateView.topAnchor],
        [emptyImage.centerXAnchor constraintEqualToAnchor:self.emptyStateView.centerXAnchor],
        [emptyImage.widthAnchor constraintEqualToConstant:52.0],
        [emptyImage.heightAnchor constraintEqualToConstant:52.0],
        [self.emptyTitleLabel.topAnchor constraintEqualToAnchor:emptyImage.bottomAnchor constant:14.0],
        [self.emptyTitleLabel.leadingAnchor constraintEqualToAnchor:self.emptyStateView.leadingAnchor],
        [self.emptyTitleLabel.trailingAnchor constraintEqualToAnchor:self.emptyStateView.trailingAnchor],
        [self.emptyDetailLabel.topAnchor constraintEqualToAnchor:self.emptyTitleLabel.bottomAnchor constant:7.0],
        [self.emptyDetailLabel.leadingAnchor constraintEqualToAnchor:self.emptyStateView.leadingAnchor],
        [self.emptyDetailLabel.trailingAnchor constraintEqualToAnchor:self.emptyStateView.trailingAnchor],
        [self.emptyDetailLabel.bottomAnchor constraintEqualToAnchor:self.emptyStateView.bottomAnchor],
    ]];
}

- (NSDictionary<NSString *, NSString *> *)languageForCode:(NSString *)code {
    for (NSDictionary *language in self.languages) {
        if ([language[@"code"] isEqualToString:code]) {
            return language;
        }
    }
    return self.languages.firstObject;
}

- (NSString *)languageNameForCode:(NSString *)code {
    return [self languageForCode:code][@"name"];
}

- (NSString *)languageButtonTitleForRole:(NSString *)role code:(NSString *)code {
    return [NSString stringWithFormat:@"%@\n%@", role, [self languageNameForCode:code]];
}

- (void)refreshLanguageUI {
    [self.myLanguageButton setTitle:[self languageButtonTitleForRole:NSLocalizedString(@"LocKey.ConversationMe", nil)
                                                                  code:self.myLanguageCode]
                                forState:UIControlStateNormal];
    [self.partnerLanguageButton setTitle:[self languageButtonTitleForRole:NSLocalizedString(@"LocKey.ConversationPartner", nil)
                                                                       code:self.partnerLanguageCode]
                                     forState:UIControlStateNormal];
    [self refreshSessionUI];
}

- (NSString *)turnButtonTitleForSide:(ConversationSpeakerSide)side {
    BOOL active = self.isSessionActive && self.activeSide == side;
    if (active) {
        return self.isStopping
            ? NSLocalizedString(@"LocKey.ConversationFinishing", nil)
            : NSLocalizedString(@"LocKey.ConversationEndTurn", nil);
    }
    NSString *speaker = side == ConversationSpeakerSideMe
        ? NSLocalizedString(@"LocKey.ConversationISpeak", nil)
        : NSLocalizedString(@"LocKey.ConversationPartnerSpeaks", nil);
    NSString *code = side == ConversationSpeakerSideMe ? self.myLanguageCode : self.partnerLanguageCode;
    return [NSString stringWithFormat:@"%@\n%@", speaker, [self languageNameForCode:code]];
}

- (void)refreshSessionUI {
    [self.meButton setTitle:[self turnButtonTitleForSide:ConversationSpeakerSideMe] forState:UIControlStateNormal];
    [self.partnerButton setTitle:[self turnButtonTitleForSide:ConversationSpeakerSidePartner] forState:UIControlStateNormal];
    self.swapButton.enabled = !self.isSessionActive;
    self.myLanguageButton.enabled = !self.isSessionActive;
    self.partnerLanguageButton.enabled = !self.isSessionActive;

    if (!self.isSessionActive) {
        self.statusDot.backgroundColor = ConversationColor(78, 184, 118);
        self.statusLabel.text = NSLocalizedString(@"LocKey.ConversationReady", nil);
        self.statusHintLabel.text = NSLocalizedString(@"LocKey.ConversationReadyHint", nil);
        self.meButton.enabled = YES;
        self.partnerButton.enabled = YES;
        self.meButton.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
        self.partnerButton.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
        [self.meButton setTitleColor:UIColor.labelColor forState:UIControlStateNormal];
        [self.partnerButton setTitleColor:UIColor.labelColor forState:UIControlStateNormal];
    } else {
        BOOL isPreparingDeviceMicrophone = self.isStartingDeviceRecording && !self.isStopping;
        self.statusDot.backgroundColor = (self.isStopping || isPreparingDeviceMicrophone)
            ? UIColor.systemOrangeColor
            : UIColor.systemRedColor;
        self.statusLabel.text = self.isStopping
            ? NSLocalizedString(@"LocKey.ConversationFinishing", nil)
            : (isPreparingDeviceMicrophone
                ? NSLocalizedString(@"LocKey.ConversationStartingDeviceMicrophone", nil)
                : NSLocalizedString(@"LocKey.ConversationListening", nil));
        self.statusHintLabel.text = self.activeSide == ConversationSpeakerSideMe
            ? NSLocalizedString(@"LocKey.ConversationListeningToMe", nil)
            : NSLocalizedString(@"LocKey.ConversationListeningToPartner", nil);
        UIButton *activeButton = self.activeSide == ConversationSpeakerSideMe ? self.meButton : self.partnerButton;
        UIButton *inactiveButton = self.activeSide == ConversationSpeakerSideMe ? self.partnerButton : self.meButton;
        activeButton.enabled = !self.isStopping;
        inactiveButton.enabled = NO;
        activeButton.backgroundColor = ConversationColor(69, 91, 221);
        [activeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        activeButton.tintColor = UIColor.whiteColor;
        inactiveButton.alpha = 0.45;
    }
    if (!self.isSessionActive) {
        self.meButton.alpha = 1.0;
        self.partnerButton.alpha = 1.0;
        self.meButton.tintColor = ConversationColor(69, 91, 221);
        self.partnerButton.tintColor = ConversationColor(69, 91, 221);
    }
    self.emptyStateView.hidden = self.messages.count > 0;
}

- (void)selectLanguage:(UIButton *)sender {
    if (self.isSessionActive) {
        return;
    }
    NSString *title = sender.tag == 0
        ? NSLocalizedString(@"LocKey.ConversationChooseMyLanguage", nil)
        : NSLocalizedString(@"LocKey.ConversationChoosePartnerLanguage", nil);
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:title
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    for (NSDictionary *language in self.languages) {
        [sheet addAction:[UIAlertAction actionWithTitle:language[@"name"]
                                                 style:UIAlertActionStyleDefault
                                               handler:^(__unused UIAlertAction *action) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            NSString *selectedCode = language[@"code"];
            if (sender.tag == 0) {
                if ([selectedCode isEqualToString:self.partnerLanguageCode]) {
                    self.partnerLanguageCode = self.myLanguageCode;
                }
                self.myLanguageCode = selectedCode;
            } else {
                if ([selectedCode isEqualToString:self.myLanguageCode]) {
                    self.myLanguageCode = self.partnerLanguageCode;
                }
                self.partnerLanguageCode = selectedCode;
            }
            [self refreshLanguageUI];
        }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"LocKey.Cancel", nil)
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];
    sheet.popoverPresentationController.sourceView = sender;
    sheet.popoverPresentationController.sourceRect = sender.bounds;
    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)swapLanguages {
    if (self.isSessionActive) return;
    NSString *temporary = self.myLanguageCode;
    self.myLanguageCode = self.partnerLanguageCode;
    self.partnerLanguageCode = temporary;
    [UIView transitionWithView:self.languageCard
                      duration:0.24
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ [self refreshLanguageUI]; }
                    completion:nil];
}

- (void)didTapMe {
    [self toggleTurnForSide:ConversationSpeakerSideMe];
}

- (void)didTapPartner {
    [self toggleTurnForSide:ConversationSpeakerSidePartner];
}

- (void)toggleTurnForSide:(ConversationSpeakerSide)side {
    if (self.isSessionActive) {
        if (self.activeSide == side) {
            [self stopCurrentTurn];
        }
        return;
    }
    [self startTurnForSide:side];
}

- (void)startTurnForSide:(ConversationSpeakerSide)side {
    self.activeSide = side;
    self.isSessionActive = YES;
    self.isStopping = NO;
    self.currentSession = nil;
    self.isStartingDeviceRecording = NO;
    self.isDeviceRecordingActive = NO;
    self.shouldStopAfterDeviceRecordingStarts = NO;
    [self.activeTurnMessages removeAllObjects];
    [self refreshSessionUI];

    AIBudsSimultaneousInterpretationConfig *config = [AIBudsSimultaneousInterpretationConfig defaultConfig];
    config.sourceLanguage = side == ConversationSpeakerSideMe ? self.myLanguageCode : self.partnerLanguageCode;
    config.targetLanguage = side == ConversationSpeakerSideMe ? self.partnerLanguageCode : self.myLanguageCode;
    config.usesInternalAudioRecording = YES; // side == ConversationSpeakerSideMe ? NO : YES;
    config.preferSpeakerOutput = YES; // side == ConversationSpeakerSideMe ? YES : NO; 
    config.enableVoicePlayback = YES;

    __weak typeof(self) weakSelf = self;
    [AIBudsAISDK startSimultaneousInterpretationWithConfig:config
        onStartSuccess:^(id<AIBudsSimultaneousInterpretationSessionConvertible> session) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) self = weakSelf;
                if (!self) return;
                [self handleSessionStartSuccess:session];
            });
        }
        onStartFailure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) self = weakSelf;
                if (!self) return;
                [self finishTurnWithError:error];
            });
        }
        onStopByInterruption:^(NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) self = weakSelf;
                if (!self) return;
                [self finishTurnWithError:error];
            });
        }
        onException:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) self = weakSelf;
                if (!self) return;
                self.statusLabel.text = NSLocalizedString(@"LocKey.ConversationAudioError", nil);
                self.statusHintLabel.text = error.localizedDescription;
            });
        }
        streamResultHandler:^(__unused BOOL isFinal,
                              AIBudsSimultaneousInterpretationDataModel * _Nullable response,
                              NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) self = weakSelf;
                if (!self) return;
                if (error) {
                    self.statusLabel.text = NSLocalizedString(@"LocKey.ConversationTranslationError", nil);
                    self.statusHintLabel.text = error.localizedDescription;
                    return;
                }
                if (response) {
                    [self consumeResponse:response];
                }
            });
        }
        onEvent:^(AIBudsSimultaneousInterpretationEventModel *event) {
            if (event.eventType == AIBudsSimultaneousInterpretationEventTypeAppWillTerminate) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(weakSelf) self = weakSelf;
                    if (!self) return;
                    [self stopDeviceRecordingWithCompletion:nil];
                });
            }
        }
        onFinish:^(__unused AIBudsSimultaneousInterpretationReportModel * _Nullable report) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) self = weakSelf;
                if (!self) return;
                [self finishTurnWithError:nil];
            });
        }];
}

- (nullable id<AIBudsDeviceAudioRecordingAPI>)deviceAudioRecordingAPI {
    id<AIBudsDeviceAudioRecordingAPI> audioRecordingAPI = (id<AIBudsDeviceAudioRecordingAPI>)self.device;
    return [audioRecordingAPI conformsToProtocol:@protocol(AIBudsDeviceAudioRecordingAPI)]
        ? audioRecordingAPI
        : nil;
}

- (void)handleSessionStartSuccess:(id<AIBudsSimultaneousInterpretationSessionConvertible>)session {
    if (!self.isSessionActive || self.isStopping) {
        return;
    }

    self.currentSession = session;
    if (session.isRecordingInternally) {
        [self refreshSessionUI];
        return;
    }

    // DeviceHomeViewController forwards device PCM to the session registered here.
    // Register before starting device recording so that the first audio packet is not lost.
    [ConversationTranslationContext sharedInstance].currentSession = session;

    id<AIBudsDeviceAudioRecordingAPI> audioRecordingAPI = [self deviceAudioRecordingAPI];
    if (!audioRecordingAPI) {
        NSError *error = [NSError errorWithDomain:@"com.aibuds.demo.conversation"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey:
                                                        NSLocalizedString(@"LocKey.ConversationDeviceRecordingUnsupported", nil)}];
        [self handleDeviceRecordingStartFailure:error];
        return;
    }
    self.isStartingDeviceRecording = YES;
    [self refreshSessionUI];
    __weak typeof(self) weakSelf = self;
    [audioRecordingAPI startAIAudioRecordingWithScene:AIBudsRecordingSceneOnSite
                                           completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            self.isStartingDeviceRecording = NO;
            if (!success) {
                NSError *resolvedError = error ?: [NSError errorWithDomain:@"com.aibuds.demo.conversation"
                                                                       code:-2
                                                                   userInfo:@{NSLocalizedDescriptionKey:
                                                                                  NSLocalizedString(@"LocKey.ConversationDeviceRecordingStartFailed", nil)}];
                [self handleDeviceRecordingStartFailure:resolvedError];
                return;
            }

            self.isDeviceRecordingActive = YES;
            if (self.shouldStopAfterDeviceRecordingStarts || !self.isSessionActive || self.isStopping) {
                [self stopDeviceRecordingWithCompletion:^{
                    [AIBudsAISDK stopSimultaneousInterpretation];
                }];
                return;
            }
            [self refreshSessionUI];
        });
    }];
}

- (void)handleDeviceRecordingStartFailure:(NSError *)error {
    self.isStartingDeviceRecording = NO;
    self.shouldStopAfterDeviceRecordingStarts = NO;
    [AIBudsAISDK stopSimultaneousInterpretation];
    [self finishTurnWithError:error];
}

- (void)stopDeviceRecordingWithCompletion:(void (^ _Nullable)(void))completion {
    if (!self.isDeviceRecordingActive) {
        if (completion) completion();
        return;
    }

    id<AIBudsDeviceAudioRecordingAPI> audioRecordingAPI = [self deviceAudioRecordingAPI];
    self.isDeviceRecordingActive = NO;
    if (!audioRecordingAPI) {
        if (completion) completion();
        return;
    }

    [audioRecordingAPI stopAIAudioRecordingWithScene:AIBudsRecordingSceneOnSite
                                          completion:^(__unused BOOL success, __unused NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion();
        });
    }];
}

- (void)consumeResponse:(AIBudsSimultaneousInterpretationDataModel *)response {
    NSNumber *sequence = response.sourceTextSequence ?: response.targetTextSequence;
    if (!sequence) return;

    ConversationTranslationMessage *message = self.activeTurnMessages[sequence];
    if (!message) {
        message = [[ConversationTranslationMessage alloc] init];
        message.sequence = sequence;
        message.side = self.activeSide;
        message.originalText = @"";
        message.translatedText = @"";
        self.activeTurnMessages[sequence] = message;
        [self.messages addObject:message];
    }
    if (response.sourceText.length > 0) {
        message.originalText = response.sourceText;
    }
    if (response.targetText.length > 0) {
        message.translatedText = response.targetText;
    }
    [self.tableView reloadData];
    [self refreshSessionUI];
    if (self.messages.count > 0) {
        NSIndexPath *last = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:last atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)stopCurrentTurn {
    if (!self.isSessionActive || self.isStopping) return;
    self.isStopping = YES;
    [self refreshSessionUI];
    if (self.isStartingDeviceRecording) {
        self.shouldStopAfterDeviceRecordingStarts = YES;
        return;
    }
    [self stopDeviceRecordingWithCompletion:^{
        [AIBudsAISDK stopSimultaneousInterpretation];
    }];
}

- (void)finishTurnWithError:(NSError * _Nullable)error {
    if (self.isDeviceRecordingActive) {
        __weak typeof(self) weakSelf = self;
        [self stopDeviceRecordingWithCompletion:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            [self finishTurnWithError:error];
        }];
        return;
    }
    ConversationTranslationContext *conversationContext = [ConversationTranslationContext sharedInstance];
    if (conversationContext.currentSession == self.currentSession) {
        conversationContext.currentSession = nil;
    }
    self.isSessionActive = NO;
    self.isStopping = NO;
    self.currentSession = nil;
    self.isStartingDeviceRecording = NO;
    self.shouldStopAfterDeviceRecordingStarts = NO;
    [self.activeTurnMessages removeAllObjects];
    [self refreshSessionUI];
    if (error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LocKey.ConversationTranslationError", nil)
                                                                       message:error.localizedDescription
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"LocKey.OK", nil)
                                                 style:UIAlertActionStyleDefault
                                               handler:nil]];
        if (!self.presentedViewController) {
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ConversationTranslationMessage *message = self.messages[indexPath.row];
    NSString *identifier = message.side == ConversationSpeakerSideMe ? @"ConversationMeCell" : @"ConversationPartnerCell";
    ConversationTranslationBubbleCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[ConversationTranslationBubbleCell alloc] initWithSide:message.side reuseIdentifier:identifier];
    }
    NSString *speakerName = message.side == ConversationSpeakerSideMe
        ? NSLocalizedString(@"LocKey.ConversationMe", nil)
        : NSLocalizedString(@"LocKey.ConversationPartner", nil);
    [cell configureWithMessage:message speakerName:speakerName];
    return cell;
}

@end
