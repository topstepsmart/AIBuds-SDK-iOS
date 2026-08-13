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

typedef NS_ENUM(NSInteger, AIChatMessageRole) {
    AIChatMessageRoleUser,
    AIChatMessageRoleAssistant,
};

static UIColor *AIChatColor(NSInteger red, NSInteger green, NSInteger blue) {
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1.0];
}

@interface AIChatBubbleMessage : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) AIChatMessageRole role;
@property (nonatomic, assign, getter=isDefinite) BOOL definite;

@end

@implementation AIChatBubbleMessage
@end

@interface AIChatBubbleCell : UITableViewCell

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UIView *bubbleView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, assign) AIChatMessageRole role;

- (instancetype)initWithRole:(AIChatMessageRole)role reuseIdentifier:(NSString *)reuseIdentifier;
- (void)configureWithMessage:(AIChatBubbleMessage *)message;

@end


@implementation AIChatBubbleCell

- (instancetype)initWithRole:(AIChatMessageRole)role reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }

    self.role = role;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = UIColor.clearColor;

    self.avatarView = [[UIImageView alloc] init];
    self.avatarView.contentMode = UIViewContentModeCenter;
    self.avatarView.layer.cornerRadius = 17.0;
    self.avatarView.clipsToBounds = YES;
    self.avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.avatarView];

    self.bubbleView = [[UIView alloc] init];
    self.bubbleView.layer.cornerRadius = 18.0;
    self.bubbleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.bubbleView];

    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.font = [UIFont systemFontOfSize:16.0];
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bubbleView addSubview:self.messageLabel];

    self.progressLabel = [[UILabel alloc] init];
    self.progressLabel.font = [UIFont systemFontOfSize:11.0 weight:UIFontWeightMedium];
    self.progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bubbleView addSubview:self.progressLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.avatarView.widthAnchor constraintEqualToConstant:34.0],
        [self.avatarView.heightAnchor constraintEqualToConstant:34.0],
        [self.avatarView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:10.0],
        [self.bubbleView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8.0],
        [self.bubbleView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8.0],
        [self.bubbleView.widthAnchor constraintLessThanOrEqualToAnchor:self.contentView.widthAnchor multiplier:0.76],
        [self.messageLabel.topAnchor constraintEqualToAnchor:self.bubbleView.topAnchor constant:11.0],
        [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.bubbleView.leadingAnchor constant:14.0],
        [self.messageLabel.trailingAnchor constraintEqualToAnchor:self.bubbleView.trailingAnchor constant:-14.0],
        [self.progressLabel.topAnchor constraintEqualToAnchor:self.messageLabel.bottomAnchor constant:4.0],
        [self.progressLabel.leadingAnchor constraintEqualToAnchor:self.messageLabel.leadingAnchor],
        [self.progressLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.messageLabel.trailingAnchor],
        [self.progressLabel.bottomAnchor constraintEqualToAnchor:self.bubbleView.bottomAnchor constant:-9.0],
    ]];

    if (role == AIChatMessageRoleUser) {
        [NSLayoutConstraint activateConstraints:@[
            [self.avatarView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-14.0],
            [self.bubbleView.trailingAnchor constraintEqualToAnchor:self.avatarView.leadingAnchor constant:-8.0],
            [self.bubbleView.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.leadingAnchor constant:48.0],
        ]];
    } else {
        [NSLayoutConstraint activateConstraints:@[
            [self.avatarView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:14.0],
            [self.bubbleView.leadingAnchor constraintEqualToAnchor:self.avatarView.trailingAnchor constant:8.0],
            [self.bubbleView.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.trailingAnchor constant:-48.0],
        ]];
    }
    return self;
}

- (void)configureWithMessage:(AIChatBubbleMessage *)message {
    self.messageLabel.text = message.text;
    self.progressLabel.hidden = message.isDefinite;
    self.progressLabel.text = message.isDefinite
        ? nil
        : (message.role == AIChatMessageRoleUser
            ? NSLocalizedString(@"LocKey.AIChatRecognizing", nil)
            : NSLocalizedString(@"LocKey.AIChatResponding", nil));

    if (message.role == AIChatMessageRoleUser) {
        self.avatarView.image = [UIImage systemImageNamed:@"person.fill"];
        self.avatarView.tintColor = UIColor.whiteColor;
        self.avatarView.backgroundColor = AIChatColor(83, 99, 222);
        self.bubbleView.backgroundColor = AIChatColor(83, 99, 222);
        self.messageLabel.textColor = UIColor.whiteColor;
        self.progressLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    } else {
        self.avatarView.image = [UIImage systemImageNamed:@"sparkles"];
        self.avatarView.tintColor = AIChatColor(83, 99, 222);
        self.avatarView.backgroundColor = AIChatColor(235, 238, 255);
        self.bubbleView.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
        self.messageLabel.textColor = UIColor.labelColor;
        self.progressLabel.textColor = UIColor.secondaryLabelColor;
    }
}

@end


@interface AIChatDemoController ()

@property (nonatomic, strong) UIView *statusCard;
@property (nonatomic, strong) UIView *statusDot;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *statusHintLabel;
@property (nonatomic, strong) UIScrollView *conversationScrollView;
@property (nonatomic, strong) UIStackView *messageStackView;
@property (nonatomic, strong) UIView *emptyStateContainer;
@property (nonatomic, strong) UIStackView *emptyStateView;
@property (nonatomic, strong) UIBarButtonItem *settingsButton;
@property (nonatomic, strong) NSMutableArray<AIChatBubbleMessage *> *messages;
@property (nonatomic, assign) BOOL isChatting;

@end


@implementation AIChatDemoController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messages = [NSMutableArray array];
    self.isChatting = [AIChatContext sharedInstance].currentSession != nil;
    [self setupUI];
    [self startObservingNotifications];
    [self restoreChatHistory];
    [self refreshStatus];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // The device can start and finish a turn while this controller is not on
    // screen. Always rebuild from the context instead of relying on a past
    // notification being observed.
    [self reloadConversationFromContext];
}

#pragma mark - UI

- (void)setupUI {
    self.title = NSLocalizedString(@"LocKey.AiChatDemoTitle", nil);
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;

    self.settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"gearshape.fill"]
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(settingsButtonTapped:)];
    self.settingsButton.accessibilityLabel = NSLocalizedString(@"LocKey.Settings", nil);
    self.navigationItem.rightBarButtonItem = self.settingsButton;

    [self.view addSubview:[self makeStatusCard]];

    self.conversationScrollView = [[UIScrollView alloc] init];
    self.conversationScrollView.alwaysBounceVertical = YES;
    self.conversationScrollView.backgroundColor = UIColor.clearColor;
    self.conversationScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.conversationScrollView];

    self.messageStackView = [[UIStackView alloc] init];
    self.messageStackView.axis = UILayoutConstraintAxisVertical;
    self.messageStackView.spacing = 2.0;
    self.messageStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.conversationScrollView addSubview:self.messageStackView];

    self.emptyStateContainer = [self makeEmptyState];
    self.emptyStateContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.emptyStateContainer.userInteractionEnabled = NO;
    [self.conversationScrollView addSubview:self.emptyStateContainer];

    [NSLayoutConstraint activateConstraints:@[
        [self.statusCard.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:12.0],
        [self.statusCard.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16.0],
        [self.statusCard.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16.0],
        [self.conversationScrollView.topAnchor constraintEqualToAnchor:self.statusCard.bottomAnchor constant:8.0],
        [self.conversationScrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.conversationScrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.conversationScrollView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        // The stack itself defines the scroll view's content size. Keeping a
        // separate content view here can leave the stack with a zero/ambiguous
        // presentation frame even though all message views were created.
        [self.messageStackView.topAnchor constraintEqualToAnchor:self.conversationScrollView.contentLayoutGuide.topAnchor constant:4.0],
        [self.messageStackView.leadingAnchor constraintEqualToAnchor:self.conversationScrollView.contentLayoutGuide.leadingAnchor],
        [self.messageStackView.trailingAnchor constraintEqualToAnchor:self.conversationScrollView.contentLayoutGuide.trailingAnchor],
        [self.messageStackView.bottomAnchor constraintEqualToAnchor:self.conversationScrollView.contentLayoutGuide.bottomAnchor constant:-12.0],
        [self.messageStackView.widthAnchor constraintEqualToAnchor:self.conversationScrollView.frameLayoutGuide.widthAnchor],
        // Empty state is an overlay in the visible viewport and does not
        // participate in determining scrollable content dimensions.
        [self.emptyStateContainer.topAnchor constraintEqualToAnchor:self.conversationScrollView.frameLayoutGuide.topAnchor],
        [self.emptyStateContainer.leadingAnchor constraintEqualToAnchor:self.conversationScrollView.frameLayoutGuide.leadingAnchor],
        [self.emptyStateContainer.trailingAnchor constraintEqualToAnchor:self.conversationScrollView.frameLayoutGuide.trailingAnchor],
        [self.emptyStateContainer.bottomAnchor constraintEqualToAnchor:self.conversationScrollView.frameLayoutGuide.bottomAnchor],
    ]];
}

- (UIView *)makeStatusCard {
    self.statusCard = [[UIView alloc] init];
    self.statusCard.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
    self.statusCard.layer.cornerRadius = 16.0;
    self.statusCard.translatesAutoresizingMaskIntoConstraints = NO;

    self.statusDot = [[UIView alloc] init];
    self.statusDot.layer.cornerRadius = 5.0;
    self.statusDot.translatesAutoresizingMaskIntoConstraints = NO;
    [self.statusCard addSubview:self.statusDot];

    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightSemibold];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.statusCard addSubview:self.statusLabel];

    self.statusHintLabel = [[UILabel alloc] init];
    self.statusHintLabel.font = [UIFont systemFontOfSize:12.0];
    self.statusHintLabel.textColor = UIColor.secondaryLabelColor;
    self.statusHintLabel.numberOfLines = 2;
    self.statusHintLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.statusCard addSubview:self.statusHintLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.statusCard.heightAnchor constraintEqualToConstant:80.0],
        [self.statusDot.leadingAnchor constraintEqualToAnchor:self.statusCard.leadingAnchor constant:16.0],
        [self.statusDot.centerYAnchor constraintEqualToAnchor:self.statusLabel.centerYAnchor],
        [self.statusDot.widthAnchor constraintEqualToConstant:10.0],
        [self.statusDot.heightAnchor constraintEqualToConstant:10.0],
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.statusCard.topAnchor constant:13.0],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.statusDot.trailingAnchor constant:9.0],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.statusCard.trailingAnchor constant:-16.0],
        [self.statusHintLabel.topAnchor constraintEqualToAnchor:self.statusLabel.bottomAnchor constant:4.0],
        [self.statusHintLabel.leadingAnchor constraintEqualToAnchor:self.statusLabel.leadingAnchor],
        [self.statusHintLabel.trailingAnchor constraintEqualToAnchor:self.statusCard.trailingAnchor constant:-16.0],
        // Close the card's vertical layout chain. With a <= constraint the
        // card has no determined bottom edge and may expand to consume the
        // whole screen, leaving the conversation scroll view at height 0.
        [self.statusHintLabel.bottomAnchor constraintEqualToAnchor:self.statusCard.bottomAnchor constant:-12.0],
    ]];
    return self.statusCard;
}

- (UIView *)makeEmptyState {
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = UIColor.clearColor;
    container.translatesAutoresizingMaskIntoConstraints = NO;

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"bubble.left.and.bubble.right"]];
    imageView.tintColor = UIColor.tertiaryLabelColor;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView.heightAnchor constraintEqualToConstant:48.0].active = YES;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.AIChatEmptyTitle", nil);
    titleLabel.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold];
    titleLabel.textColor = UIColor.secondaryLabelColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;

    UILabel *detailLabel = [[UILabel alloc] init];
    detailLabel.text = NSLocalizedString(@"LocKey.AIChatEmptyDetail", nil);
    detailLabel.font = [UIFont systemFontOfSize:13.0];
    detailLabel.textColor = UIColor.tertiaryLabelColor;
    detailLabel.numberOfLines = 0;
    detailLabel.textAlignment = NSTextAlignmentCenter;

    self.emptyStateView = [[UIStackView alloc] initWithArrangedSubviews:@[imageView, titleLabel, detailLabel]];
    self.emptyStateView.axis = UILayoutConstraintAxisVertical;
    self.emptyStateView.spacing = 8.0;
    self.emptyStateView.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:self.emptyStateView];

    [NSLayoutConstraint activateConstraints:@[
        [self.emptyStateView.centerXAnchor constraintEqualToAnchor:container.centerXAnchor],
        [self.emptyStateView.centerYAnchor constraintEqualToAnchor:container.centerYAnchor constant:-20.0],
        [self.emptyStateView.leadingAnchor constraintGreaterThanOrEqualToAnchor:container.leadingAnchor constant:36.0],
        [self.emptyStateView.trailingAnchor constraintLessThanOrEqualToAnchor:container.trailingAnchor constant:-36.0],
    ]];
    return container;
}

- (void)refreshStatus {
    self.settingsButton.enabled = !self.isChatting;

    if (self.isChatting && [AIChatContext sharedInstance].isSpeaking) {
        [self updateStatus:NSLocalizedString(@"LocKey.Speaking", nil)
                      hint:NSLocalizedString(@"LocKey.AIChatListeningHint", nil)
                     color:AIChatColor(44, 184, 117)];
    } else if (self.isChatting) {
        [self updateStatus:NSLocalizedString(@"LocKey.AIChatConnected", nil)
                      hint:NSLocalizedString(@"LocKey.AIChatConnectedHint", nil)
                     color:AIChatColor(44, 184, 117)];
    } else {
        [self updateStatus:NSLocalizedString(@"LocKey.AIChatReady", nil)
                      hint:NSLocalizedString(@"LocKey.AIChatReadyHint", nil)
                     color:UIColor.tertiaryLabelColor];
    }
}

- (void)updateStatus:(NSString *)status hint:(NSString *)hint color:(UIColor *)color {
    self.statusLabel.text = status;
    self.statusHintLabel.text = hint;
    self.statusDot.backgroundColor = color;
}

#pragma mark - Notifications

- (void)startObservingNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(handleChatDataNotification:) name:AIChatDataDidUpdateNotification object:nil];
    [center addObserver:self selector:@selector(handleSessionStarted:) name:AIChatSessionDidStartNotification object:nil];
    [center addObserver:self selector:@selector(handleSessionEnded:) name:AIChatSessionDidEndNotification object:nil];
    [center addObserver:self selector:@selector(handleSessionFailed:) name:AIChatSessionDidFailNotification object:nil];
    [center addObserver:self selector:@selector(handleVadStartSpeaking:) name:AIChatVadDidStartSpeakingNotification object:nil];
    [center addObserver:self selector:@selector(handleVadEndSpeaking:) name:AIChatVadDidEndSpeakingNotification object:nil];
}

- (void)handleChatDataNotification:(NSNotification *)notification {
    if (!notification.object) {
        return;
    }
    void (^updateUI)(void) = ^{
        XLOG_INFO(@"%@", APP_LOG_STRING(@"[AIChatUI] Received chat data notification: %@", notification.object));
        [self applyChatData:notification.object];
    };
    if (NSThread.isMainThread) {
        updateUI();
    } else {
        dispatch_async(dispatch_get_main_queue(), updateUI);
    }
}

- (void)handleSessionStarted:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isChatting = YES;
        [self.messages removeAllObjects];
        [self updateConversationUIAnimated:NO];
        [self refreshStatus];
    });
}

- (void)handleSessionEnded:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isChatting = NO;
        [AIChatContext sharedInstance].isSpeaking = NO;
        [self refreshStatus];
    });
}

- (void)handleSessionFailed:(NSNotification *)notification {
    NSError *error = [notification.object isKindOfClass:[NSError class]] ? notification.object : nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isChatting = NO;
        [self refreshStatus];
        NSString *message = error.localizedDescription ?: NSLocalizedString(@"LocKey.AIChatUnknownError", nil);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LocKey.AIChatErrorTitle", nil)
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ConfirmLocKey", nil)
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        if (!self.presentedViewController) {
            [self presentViewController:alert animated:YES completion:nil];
        }
    });
}

- (void)handleVadStartSpeaking:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [AIChatContext sharedInstance].isSpeaking = YES;
        [self refreshStatus];
    });
}

- (void)handleVadEndSpeaking:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [AIChatContext sharedInstance].isSpeaking = NO;
        [self refreshStatus];
    });
}

#pragma mark - Chat data

- (void)restoreChatHistory {
    for (AIBudsAIChatDataModel *chatData in [[AIChatContext sharedInstance] chatDataSnapshot]) {
        [self applyChatData:chatData animated:NO];
    }
}

- (void)reloadConversationFromContext {
    NSArray<AIBudsAIChatDataModel *> *snapshot = [[AIChatContext sharedInstance] chatDataSnapshot];
    XLOG_INFO(@"%@", APP_LOG_STRING(@"[AIChatUI] Reloading conversation snapshot, count = %lu", (unsigned long)snapshot.count));
    [self.messages removeAllObjects];
    for (AIBudsAIChatDataModel *chatData in snapshot) {
        [self upsertChatData:chatData];
    }
    [self updateConversationUIAnimated:NO];
}

- (void)applyChatData:(AIBudsAIChatDataModel *)chatData {
    [self applyChatData:chatData animated:YES];
}

- (void)applyChatData:(AIBudsAIChatDataModel *)chatData animated:(BOOL)animated {
    if (![self upsertChatData:chatData]) {
        return;
    }
    [self updateConversationUIAnimated:animated];
}

- (BOOL)upsertChatData:(AIBudsAIChatDataModel *)chatData {
    NSString *conversationID = chatData.questionId.length > 0
        ? chatData.questionId
        : (chatData.requestId.length > 0
            ? chatData.requestId
            : [NSString stringWithFormat:@"%ld", (long)chatData.sequence]);
    BOOL changed = NO;

    if (chatData.question.length > 0) {
        changed |= [self upsertMessageWithIdentifier:[@"question:" stringByAppendingString:conversationID]
                                                text:chatData.question
                                                role:AIChatMessageRoleUser
                                            definite:chatData.isQuestionDefinite];
    }
    if (chatData.answer.length > 0) {
        changed |= [self upsertMessageWithIdentifier:[@"answer:" stringByAppendingString:conversationID]
                                                text:chatData.answer
                                                role:AIChatMessageRoleAssistant
                                            definite:chatData.isAnswerDefinite];
    }

    return changed;
}

- (void)updateConversationUIAnimated:(BOOL)animated {
    BOOL hasMessages = self.messages.count > 0;
    self.emptyStateContainer.hidden = hasMessages;

    for (UIView *view in [self.messageStackView.arrangedSubviews copy]) {
        [self.messageStackView removeArrangedSubview:view];
        [view removeFromSuperview];
    }
    for (AIChatBubbleMessage *message in self.messages) {
        [self.messageStackView addArrangedSubview:[self makeBubbleViewForMessage:message]];
    }
    [self.conversationScrollView bringSubviewToFront:self.messageStackView];

    XLOG_INFO(@"%@", APP_LOG_STRING(@"[AIChatUI] Rendered stack, message count = %lu, visible = %@",
                                    (unsigned long)self.messages.count,
                                    self.view.window ? @"YES" : @"NO"));
    if (!hasMessages) {
        return;
    }
    [self.view layoutIfNeeded];
    XLOG_INFO(@"%@", APP_LOG_STRING(@"[AIChatUI] Layout frames: scroll=%@, stack=%@, contentSize=%@",
                                    NSStringFromCGRect(self.conversationScrollView.frame),
                                    NSStringFromCGRect(self.messageStackView.frame),
                                    NSStringFromCGSize(self.conversationScrollView.contentSize)));
    CGFloat bottomOffset = MAX(0.0, self.conversationScrollView.contentSize.height - CGRectGetHeight(self.conversationScrollView.bounds));
    [self.conversationScrollView setContentOffset:CGPointMake(0, bottomOffset) animated:animated];
}

- (UIView *)makeBubbleViewForMessage:(AIChatBubbleMessage *)message {
    UIView *row = [[UIView alloc] init];
    row.translatesAutoresizingMaskIntoConstraints = NO;

    UIImageView *avatar = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:message.role == AIChatMessageRoleUser ? @"person.fill" : @"sparkles"]];
    avatar.contentMode = UIViewContentModeCenter;
    avatar.layer.cornerRadius = 17.0;
    avatar.clipsToBounds = YES;
    avatar.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:avatar];

    UIView *bubble = [[UIView alloc] init];
    bubble.layer.cornerRadius = 18.0;
    bubble.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:bubble];

    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = message.text;
    textLabel.font = [UIFont systemFontOfSize:16.0];
    textLabel.numberOfLines = 0;
    textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [bubble addSubview:textLabel];

    UILabel *progressLabel = [[UILabel alloc] init];
    progressLabel.text = message.role == AIChatMessageRoleUser
        ? NSLocalizedString(@"LocKey.AIChatRecognizing", nil)
        : NSLocalizedString(@"LocKey.AIChatResponding", nil);
    progressLabel.font = [UIFont systemFontOfSize:11.0 weight:UIFontWeightMedium];
    progressLabel.hidden = message.isDefinite;
    progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [bubble addSubview:progressLabel];

    BOOL isUser = message.role == AIChatMessageRoleUser;
    avatar.tintColor = isUser ? UIColor.whiteColor : AIChatColor(83, 99, 222);
    avatar.backgroundColor = isUser ? AIChatColor(83, 99, 222) : AIChatColor(235, 238, 255);
    bubble.backgroundColor = isUser ? AIChatColor(83, 99, 222) : UIColor.secondarySystemGroupedBackgroundColor;
    textLabel.textColor = isUser ? UIColor.whiteColor : UIColor.labelColor;
    progressLabel.textColor = isUser ? [UIColor colorWithWhite:1.0 alpha:0.7] : UIColor.secondaryLabelColor;

    [NSLayoutConstraint activateConstraints:@[
        [row.heightAnchor constraintGreaterThanOrEqualToConstant:54.0],
        [avatar.topAnchor constraintEqualToAnchor:row.topAnchor constant:10.0],
        [avatar.widthAnchor constraintEqualToConstant:34.0],
        [avatar.heightAnchor constraintEqualToConstant:34.0],
        [bubble.topAnchor constraintEqualToAnchor:row.topAnchor constant:8.0],
        [bubble.bottomAnchor constraintEqualToAnchor:row.bottomAnchor constant:-8.0],
        [bubble.widthAnchor constraintLessThanOrEqualToAnchor:row.widthAnchor multiplier:0.76],
        [textLabel.topAnchor constraintEqualToAnchor:bubble.topAnchor constant:11.0],
        [textLabel.leadingAnchor constraintEqualToAnchor:bubble.leadingAnchor constant:14.0],
        [textLabel.trailingAnchor constraintEqualToAnchor:bubble.trailingAnchor constant:-14.0],
        [progressLabel.topAnchor constraintEqualToAnchor:textLabel.bottomAnchor constant:4.0],
        [progressLabel.leadingAnchor constraintEqualToAnchor:textLabel.leadingAnchor],
        [progressLabel.trailingAnchor constraintLessThanOrEqualToAnchor:textLabel.trailingAnchor],
        [progressLabel.bottomAnchor constraintEqualToAnchor:bubble.bottomAnchor constant:-9.0],
    ]];
    if (isUser) {
        [NSLayoutConstraint activateConstraints:@[
            [avatar.trailingAnchor constraintEqualToAnchor:row.trailingAnchor constant:-14.0],
            [bubble.trailingAnchor constraintEqualToAnchor:avatar.leadingAnchor constant:-8.0],
            [bubble.leadingAnchor constraintGreaterThanOrEqualToAnchor:row.leadingAnchor constant:48.0],
        ]];
    } else {
        [NSLayoutConstraint activateConstraints:@[
            [avatar.leadingAnchor constraintEqualToAnchor:row.leadingAnchor constant:14.0],
            [bubble.leadingAnchor constraintEqualToAnchor:avatar.trailingAnchor constant:8.0],
            [bubble.trailingAnchor constraintLessThanOrEqualToAnchor:row.trailingAnchor constant:-48.0],
        ]];
    }
    XLOG_INFO(@"%@", APP_LOG_STRING(@"[AIChatUI] Rendering bubble, text = %@", message.text));
    return row;
}

- (BOOL)upsertMessageWithIdentifier:(NSString *)identifier
                               text:(NSString *)text
                               role:(AIChatMessageRole)role
                           definite:(BOOL)definite {
    NSUInteger index = [self.messages indexOfObjectPassingTest:^BOOL(AIChatBubbleMessage *message, NSUInteger idx, BOOL *stop) {
        return [message.identifier isEqualToString:identifier];
    }];
    if (index != NSNotFound) {
        AIChatBubbleMessage *message = self.messages[index];
        if ([message.text isEqualToString:text] && message.isDefinite == definite) {
            return NO;
        }
        message.text = text;
        message.definite = definite;
        return YES;
    }

    AIChatBubbleMessage *message = [[AIChatBubbleMessage alloc] init];
    message.identifier = identifier;
    message.text = text;
    message.role = role;
    message.definite = definite;
    [self.messages addObject:message];
    return YES;
}

#pragma mark - Actions

- (void)settingsButtonTapped:(id)sender {
    if (self.isChatting) {
        return;
    }
    AIChatSettingsController *settingsController = [[AIChatSettingsController alloc] initWithSettings:[AIChatContext sharedInstance].settings];
    [self.navigationController pushViewController:settingsController animated:YES];
}

@end
