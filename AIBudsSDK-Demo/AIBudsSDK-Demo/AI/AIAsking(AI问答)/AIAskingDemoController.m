//
//  AIAskingDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-08-13.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "AIAskingDemoController.h"

static UIColor *AIAskingColor(NSInteger red, NSInteger green, NSInteger blue) {
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1.0];
}

@interface AIAskingDemoController () <UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *heroCard;
@property (nonatomic, strong) CAGradientLayer *heroGradient;
@property (nonatomic, strong) UITextView *questionTextView;
@property (nonatomic, strong) UILabel *questionPlaceholderLabel;
@property (nonatomic, strong) UITextField *agentTextField;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *questionIDLabel;
@property (nonatomic, strong) UITextView *answerTextView;
@property (nonatomic, copy, nullable) NSString *currentQuestionID;
@property (nonatomic, assign) BOOL asking;

@end


@implementation AIAskingDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"LocKey.AIAskingDemoTitle", nil);
    [self setupUI];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.heroGradient.frame = self.heroCard.bounds;
}

#pragma mark - UI

- (void)setupUI {
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;

    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];

    self.contentView = [[UIView alloc] init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.contentView];

    UIStackView *pageStack = [[UIStackView alloc] init];
    pageStack.axis = UILayoutConstraintAxisVertical;
    pageStack.spacing = 16.0;
    pageStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:pageStack];

    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.topAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.trailingAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.bottomAnchor],
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.frameLayoutGuide.widthAnchor],
        [pageStack.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:16],
        [pageStack.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [pageStack.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [pageStack.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-28],
    ]];

    [pageStack addArrangedSubview:[self makeHeroCard]];
    [pageStack addArrangedSubview:[self makeQuestionCard]];
    [pageStack addArrangedSubview:[self makeAgentCard]];
    [pageStack addArrangedSubview:[self makeSendButton]];
    [pageStack addArrangedSubview:[self makeStatusCard]];
    [pageStack addArrangedSubview:[self makeAnswerCard]];

    UITapGestureRecognizer *dismissKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    dismissKeyboard.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:dismissKeyboard];
}

- (UIView *)makeHeroCard {
    self.heroCard = [[UIView alloc] init];
    self.heroCard.layer.cornerRadius = 22.0;
    self.heroCard.clipsToBounds = YES;
    [self.heroCard.heightAnchor constraintEqualToConstant:132.0].active = YES;

    self.heroGradient = [CAGradientLayer layer];
    self.heroGradient.colors = @[(id)AIAskingColor(47, 91, 234).CGColor,
                                 (id)AIAskingColor(104, 75, 215).CGColor];
    self.heroGradient.startPoint = CGPointMake(0, 0);
    self.heroGradient.endPoint = CGPointMake(1, 1);
    [self.heroCard.layer addSublayer:self.heroGradient];

    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"bubble.left.and.bubble.right.fill"]];
    iconView.tintColor = UIColor.whiteColor;
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.heroCard addSubview:iconView];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.AIAskingHeroTitle", nil);
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = NSLocalizedString(@"LocKey.AIAskingHeroSubtitle", nil);
    subtitleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.82];
    subtitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    subtitleLabel.numberOfLines = 2;

    UIStackView *labels = [[UIStackView alloc] initWithArrangedSubviews:@[titleLabel, subtitleLabel]];
    labels.axis = UILayoutConstraintAxisVertical;
    labels.spacing = 7.0;
    labels.translatesAutoresizingMaskIntoConstraints = NO;
    [self.heroCard addSubview:labels];

    [NSLayoutConstraint activateConstraints:@[
        [iconView.leadingAnchor constraintEqualToAnchor:self.heroCard.leadingAnchor constant:20],
        [iconView.centerYAnchor constraintEqualToAnchor:self.heroCard.centerYAnchor],
        [iconView.widthAnchor constraintEqualToConstant:46],
        [iconView.heightAnchor constraintEqualToConstant:46],
        [labels.leadingAnchor constraintEqualToAnchor:iconView.trailingAnchor constant:16],
        [labels.trailingAnchor constraintEqualToAnchor:self.heroCard.trailingAnchor constant:-18],
        [labels.centerYAnchor constraintEqualToAnchor:self.heroCard.centerYAnchor],
    ]];
    return self.heroCard;
}

- (UIView *)makeQuestionCard {
    UIView *card = [self makeCard];
    UILabel *title = [self makeSectionTitle:NSLocalizedString(@"LocKey.AIAskingQuestionTitle", nil)
                                systemImage:@"questionmark.bubble.fill"];

    self.questionTextView = [[UITextView alloc] init];
    self.questionTextView.delegate = self;
    self.questionTextView.font = [UIFont systemFontOfSize:16];
    self.questionTextView.textColor = UIColor.labelColor;
    self.questionTextView.backgroundColor = UIColor.tertiarySystemBackgroundColor;
    self.questionTextView.layer.cornerRadius = 14.0;
    self.questionTextView.textContainerInset = UIEdgeInsetsMake(14, 12, 14, 12);
    [self.questionTextView.heightAnchor constraintEqualToConstant:132].active = YES;

    self.questionPlaceholderLabel = [[UILabel alloc] init];
    self.questionPlaceholderLabel.text = NSLocalizedString(@"LocKey.AIAskingQuestionPlaceholder", nil);
    self.questionPlaceholderLabel.font = self.questionTextView.font;
    self.questionPlaceholderLabel.textColor = UIColor.placeholderTextColor;
    self.questionPlaceholderLabel.numberOfLines = 0;
    self.questionPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.questionTextView addSubview:self.questionPlaceholderLabel];
    [NSLayoutConstraint activateConstraints:@[
        [self.questionPlaceholderLabel.topAnchor constraintEqualToAnchor:self.questionTextView.topAnchor constant:15],
        [self.questionPlaceholderLabel.leadingAnchor constraintEqualToAnchor:self.questionTextView.leadingAnchor constant:16],
        [self.questionPlaceholderLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.questionTextView.trailingAnchor constant:-16],
    ]];

    UIButton *exampleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [exampleButton setTitle:NSLocalizedString(@"LocKey.AIAskingExample", nil) forState:UIControlStateNormal];
    [exampleButton setImage:[UIImage systemImageNamed:@"sparkles"] forState:UIControlStateNormal];
    exampleButton.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    exampleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    exampleButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 7);
    [exampleButton addTarget:self action:@selector(fillExampleQuestion) forControlEvents:UIControlEventTouchUpInside];

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[title, self.questionTextView, exampleButton]];
    stack.axis = UILayoutConstraintAxisVertical;
    [self pinStack:stack toCard:card spacing:12.0];
    return card;
}

- (UIView *)makeAgentCard {
    UIView *card = [self makeCard];
    UILabel *title = [self makeSectionTitle:NSLocalizedString(@"LocKey.AIAskingAgentTitle", nil)
                                systemImage:@"cpu.fill"];

    self.agentTextField = [[UITextField alloc] init];
    self.agentTextField.delegate = self;
    self.agentTextField.placeholder = NSLocalizedString(@"LocKey.AIAskingAgentPlaceholder", nil);
    self.agentTextField.font = [UIFont systemFontOfSize:15];
    self.agentTextField.backgroundColor = UIColor.tertiarySystemBackgroundColor;
    self.agentTextField.layer.cornerRadius = 12.0;
    self.agentTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.agentTextField.returnKeyType = UIReturnKeyDone;
    UIView *padding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 1)];
    self.agentTextField.leftView = padding;
    self.agentTextField.leftViewMode = UITextFieldViewModeAlways;
    [self.agentTextField.heightAnchor constraintEqualToConstant:46].active = YES;

    UILabel *tip = [[UILabel alloc] init];
    tip.text = NSLocalizedString(@"LocKey.AIAskingAgentTip", nil);
    tip.font = [UIFont systemFontOfSize:12];
    tip.textColor = UIColor.secondaryLabelColor;
    tip.numberOfLines = 0;

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[title, self.agentTextField, tip]];
    stack.axis = UILayoutConstraintAxisVertical;
    [self pinStack:stack toCard:card spacing:10.0];
    return card;
}

- (UIButton *)makeSendButton {
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.sendButton.backgroundColor = AIAskingColor(72, 86, 220);
    self.sendButton.layer.cornerRadius = 15.0;
    self.sendButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    [self.sendButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.sendButton setTitle:NSLocalizedString(@"LocKey.AIAskingSend", nil) forState:UIControlStateNormal];
    [self.sendButton setImage:[UIImage systemImageNamed:@"paperplane.fill"] forState:UIControlStateNormal];
    self.sendButton.tintColor = UIColor.whiteColor;
    self.sendButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 8);
    [self.sendButton.heightAnchor constraintEqualToConstant:54].active = YES;
    [self.sendButton addTarget:self action:@selector(sendQuestion) forControlEvents:UIControlEventTouchUpInside];
    return self.sendButton;
}

- (UIView *)makeStatusCard {
    UIView *card = [self makeCard];

    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.activityIndicator.color = AIAskingColor(72, 86, 220);

    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = NSLocalizedString(@"LocKey.AIAskingReady", nil);
    self.statusLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    self.statusLabel.textColor = UIColor.secondaryLabelColor;
    self.statusLabel.numberOfLines = 0;

    UIStackView *statusRow = [[UIStackView alloc] initWithArrangedSubviews:@[self.activityIndicator, self.statusLabel]];
    statusRow.axis = UILayoutConstraintAxisHorizontal;
    statusRow.spacing = 10.0;
    statusRow.alignment = UIStackViewAlignmentCenter;

    self.questionIDLabel = [[UILabel alloc] init];
    self.questionIDLabel.text = NSLocalizedString(@"LocKey.AIAskingNoQuestionID", nil);
    self.questionIDLabel.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    self.questionIDLabel.textColor = UIColor.tertiaryLabelColor;
    self.questionIDLabel.numberOfLines = 2;

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[statusRow, self.questionIDLabel]];
    stack.axis = UILayoutConstraintAxisVertical;
    [self pinStack:stack toCard:card spacing:8.0];
    return card;
}

- (UIView *)makeAnswerCard {
    UIView *card = [self makeCard];
    UILabel *title = [self makeSectionTitle:NSLocalizedString(@"LocKey.AIAskingAnswerTitle", nil)
                                systemImage:@"text.bubble.fill"];

    self.answerTextView = [[UITextView alloc] init];
    self.answerTextView.editable = NO;
    self.answerTextView.selectable = YES;
    self.answerTextView.font = [UIFont systemFontOfSize:16];
    self.answerTextView.textColor = UIColor.labelColor;
    self.answerTextView.backgroundColor = UIColor.tertiarySystemBackgroundColor;
    self.answerTextView.layer.cornerRadius = 14.0;
    self.answerTextView.textContainerInset = UIEdgeInsetsMake(14, 12, 14, 12);
    self.answerTextView.text = NSLocalizedString(@"LocKey.AIAskingAnswerPlaceholder", nil);
    [self.answerTextView.heightAnchor constraintGreaterThanOrEqualToConstant:210].active = YES;

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[title, self.answerTextView]];
    stack.axis = UILayoutConstraintAxisVertical;
    [self pinStack:stack toCard:card spacing:12.0];
    return card;
}

- (UIView *)makeCard {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
    card.layer.cornerRadius = 18.0;
    card.layer.shadowColor = UIColor.blackColor.CGColor;
    card.layer.shadowOpacity = 0.04;
    card.layer.shadowRadius = 8.0;
    card.layer.shadowOffset = CGSizeMake(0, 3);
    return card;
}

- (UILabel *)makeSectionTitle:(NSString *)text systemImage:(NSString *)systemImage {
    UILabel *label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"  %@", text];
    label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    label.textColor = UIColor.labelColor;
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [[UIImage systemImageNamed:systemImage] imageWithTintColor:AIAskingColor(72, 86, 220)];
    attachment.bounds = CGRectMake(0, -2, 17, 17);
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    [attributed appendAttributedString:[[NSAttributedString alloc] initWithString:label.text]];
    label.attributedText = attributed;
    return label;
}

- (void)pinStack:(UIStackView *)stack toCard:(UIView *)card spacing:(CGFloat)spacing {
    stack.spacing = spacing;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:card.topAnchor constant:16],
        [stack.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16],
        [stack.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-16],
        [stack.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-16],
    ]];
}

#pragma mark - Actions

- (void)fillExampleQuestion {
    NSArray<NSString *> *examples = @[
        NSLocalizedString(@"LocKey.AIAskingExampleQuestion1", nil),
        NSLocalizedString(@"LocKey.AIAskingExampleQuestion2", nil),
        NSLocalizedString(@"LocKey.AIAskingExampleQuestion3", nil),
    ];
    NSString *current = self.questionTextView.text ?: @"";
    NSUInteger index = [examples indexOfObject:current];
    self.questionTextView.text = examples[index == NSNotFound ? 0 : (index + 1) % examples.count];
    self.questionPlaceholderLabel.hidden = YES;
}

- (void)sendQuestion {
    NSString *question = [self.questionTextView.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (question.length == 0) {
        [self updateStatus:NSLocalizedString(@"LocKey.AIAskingEmptyQuestion", nil) error:YES];
        return;
    }

    [self endEditing];
    [self updateAskingState:YES];
    self.answerTextView.text = @"";
    self.currentQuestionID = nil;
    self.questionIDLabel.text = NSLocalizedString(@"LocKey.AIAskingCreatingRequest", nil);
    [self updateStatus:NSLocalizedString(@"LocKey.AIAskingSending", nil) error:NO];

    AIBudsAIAskingConfig *config = [[AIBudsAIAskingConfig alloc] init];
    NSString *agent = [self.agentTextField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    config.specifiedAgent = agent.length > 0 ? agent : nil;

    __weak typeof(self) weakSelf = self;
    NSString *questionID = [AIBudsAISDK sendQuestion:question
                                              config:config
                                  onStartAnswering:^(NSString * _Nullable startedQuestionID) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf applyQuestionID:startedQuestionID];
            [strongSelf updateStatus:NSLocalizedString(@"LocKey.AIAskingAnswering", nil) error:NO];
        });
    }
                                           onAnswer:^(NSString *answerQuestionID, NSString * _Nullable deltaText, NSString * _Nullable fullText, BOOL isFinal) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf applyQuestionID:answerQuestionID];
            if (fullText != nil) {
                strongSelf.answerTextView.text = fullText;
            } else if (deltaText.length > 0) {
                NSString *existing = strongSelf.answerTextView.text ?: @"";
                strongSelf.answerTextView.text = [existing stringByAppendingString:deltaText];
            }
            if (isFinal) {
                [strongSelf updateStatus:NSLocalizedString(@"LocKey.AIAskingCompleting", nil) error:NO];
            }
        });
    }
                                  onFinishAnswering:^(NSString *finishedQuestionID) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf applyQuestionID:finishedQuestionID];
            [strongSelf updateAskingState:NO];
            [strongSelf updateStatus:NSLocalizedString(@"LocKey.AIAskingCompleted", nil) error:NO];
        });
    }
                                              onError:^(NSString *errorQuestionID, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            [strongSelf applyQuestionID:errorQuestionID];
            [strongSelf updateAskingState:NO];
            [strongSelf updateStatus:error.localizedDescription ?: NSLocalizedString(@"LocKey.AIAskingUnknownError", nil) error:YES];
            if (strongSelf.answerTextView.text.length == 0) {
                strongSelf.answerTextView.text = NSLocalizedString(@"LocKey.AIAskingFailed", nil);
            }
        });
    }];

    if (questionID.length > 0) {
        [self applyQuestionID:questionID];
    } else {
        // Synchronous validation errors are delivered through onError.
        [self updateAskingState:NO];
    }
}

- (void)applyQuestionID:(nullable NSString *)questionID {
    if (questionID.length == 0) return;
    self.currentQuestionID = questionID;
    self.questionIDLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.AIAskingQuestionIDFormat", nil), questionID];
}

- (void)updateAskingState:(BOOL)asking {
    _asking = asking;
    self.sendButton.enabled = !asking;
    self.sendButton.alpha = asking ? 0.65 : 1.0;
    self.questionTextView.editable = !asking;
    self.agentTextField.enabled = !asking;
    if (asking) {
        [self.activityIndicator startAnimating];
        [self.sendButton setTitle:NSLocalizedString(@"LocKey.AIAskingSendingButton", nil) forState:UIControlStateNormal];
    } else {
        [self.activityIndicator stopAnimating];
        [self.sendButton setTitle:NSLocalizedString(@"LocKey.AIAskingSend", nil) forState:UIControlStateNormal];
    }
}

- (void)updateStatus:(NSString *)status error:(BOOL)isError {
    self.statusLabel.text = status;
    self.statusLabel.textColor = isError ? UIColor.systemRedColor : UIColor.secondaryLabelColor;
}

- (void)endEditing {
    [self.view endEditing:YES];
}

#pragma mark - Text input

- (void)textViewDidChange:(UITextView *)textView {
    if (textView == self.questionTextView) {
        self.questionPlaceholderLabel.hidden = textView.text.length > 0;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Keyboard

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect convertedFrame = [self.view convertRect:keyboardFrame fromView:nil];
    CGFloat overlap = MAX(0, CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(convertedFrame));
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, overlap, 0);
    self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

@end
