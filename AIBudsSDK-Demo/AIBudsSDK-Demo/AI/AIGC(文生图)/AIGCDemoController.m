//
//  AIGCDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-08-13.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "AIGCDemoController.h"

static UIColor *AIGCColor(NSInteger red, NSInteger green, NSInteger blue) {
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1.0];
}

#pragma mark - Style item

@interface AIGCStyleItemView : UIControl

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, copy, nullable) NSString *styleCode;
@property (nonatomic, copy, nullable) NSString *representedIconURL;

- (void)configureWithName:(NSString *)name styleCode:(nullable NSString *)styleCode iconURL:(nullable NSString *)iconURL;

@end

@implementation AIGCStyleItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.secondarySystemBackgroundColor;
        self.layer.cornerRadius = 16.0;
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = UIColor.separatorColor.CGColor;
        self.clipsToBounds = YES;

        _iconView = [[UIImageView alloc] init];
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.backgroundColor = AIGCColor(239, 236, 255);
        _iconView.layer.cornerRadius = 12.0;
        _iconView.clipsToBounds = YES;
        _iconView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_iconView];

        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
        _nameLabel.textColor = UIColor.labelColor;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.numberOfLines = 2;
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_nameLabel];

        [NSLayoutConstraint activateConstraints:@[
            [_iconView.topAnchor constraintEqualToAnchor:self.topAnchor constant:7],
            [_iconView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:7],
            [_iconView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-7],
            [_iconView.heightAnchor constraintEqualToConstant:62],
            [_nameLabel.topAnchor constraintEqualToAnchor:_iconView.bottomAnchor constant:5],
            [_nameLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:4],
            [_nameLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-4],
            [_nameLabel.bottomAnchor constraintLessThanOrEqualToAnchor:self.bottomAnchor constant:-5],
        ]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.layer.borderWidth = selected ? 2.0 : 1.0;
    self.layer.borderColor = selected ? AIGCColor(111, 78, 246).CGColor : UIColor.separatorColor.CGColor;
    self.backgroundColor = selected ? AIGCColor(246, 243, 255) : UIColor.secondarySystemBackgroundColor;
    self.transform = selected ? CGAffineTransformMakeScale(1.02, 1.02) : CGAffineTransformIdentity;
}

- (void)configureWithName:(NSString *)name styleCode:(NSString *)styleCode iconURL:(NSString *)iconURL {
    self.nameLabel.text = name;
    self.styleCode = styleCode;
    self.representedIconURL = iconURL;
    self.iconView.image = [UIImage systemImageNamed:styleCode ? @"photo.fill" : @"sparkles"];
    self.iconView.tintColor = AIGCColor(111, 78, 246);

    NSURL *URL = iconURL.length > 0 ? [NSURL URLWithString:iconURL] : nil;
    if (!URL) return;

    __weak typeof(self) weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithURL:URL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        UIImage *image = data.length > 0 ? [UIImage imageWithData:data] : nil;
        if (!image) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if ([strongSelf.representedIconURL isEqualToString:iconURL]) {
                strongSelf.iconView.image = image;
            }
        });
    }] resume];
}

@end

#pragma mark - AIGC demo

@interface AIGCDemoController () <UITextViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) CAGradientLayer *heroGradient;
@property (nonatomic, strong) UIView *heroCard;
@property (nonatomic, strong) UITextView *promptTextView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UILabel *characterCountLabel;
@property (nonatomic, strong) UIStackView *styleStackView;
@property (nonatomic, strong) UILabel *styleStatusLabel;
@property (nonatomic, strong) UIStackView *countStackView;
@property (nonatomic, strong) UIButton *generateButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *taskLabel;
@property (nonatomic, strong) UIView *statusCard;
@property (nonatomic, strong) UILabel *resultTitleLabel;
@property (nonatomic, strong) UIStackView *resultStackView;
@property (nonatomic, copy) NSArray<AIBudsAIGCStyleModel *> *availableStyles;
@property (nonatomic, copy, nullable) NSString *selectedStyleCode;
@property (nonatomic, assign) NSInteger selectedImageCount;
@property (nonatomic, assign) NSInteger maxImageCount;
@property (nonatomic, assign) BOOL generating;

@end


@implementation AIGCDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"LocKey.AIGCDemoTitle", nil);
    self.selectedImageCount = 1;
    self.maxImageCount = MAX(1, MIN(4, AIBudsAISDK.aigcMaxGenerateCount));
    [self setupUI];
    [self reloadCountOptions];
    [self loadStyles];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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
    ]];

    UIStackView *pageStack = [[UIStackView alloc] init];
    pageStack.axis = UILayoutConstraintAxisVertical;
    pageStack.spacing = 16.0;
    pageStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:pageStack];
    [NSLayoutConstraint activateConstraints:@[
        [pageStack.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:16],
        [pageStack.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [pageStack.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [pageStack.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-28],
    ]];

    [pageStack addArrangedSubview:[self makeHeroCard]];
    [pageStack addArrangedSubview:[self makePromptCard]];
    [pageStack addArrangedSubview:[self makeStyleCard]];
    [pageStack addArrangedSubview:[self makeCountCard]];
    [pageStack addArrangedSubview:[self makeGenerateButton]];
    [pageStack addArrangedSubview:[self makeStatusCard]];
    [pageStack addArrangedSubview:[self makeResultSection]];

    UITapGestureRecognizer *dismissKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    dismissKeyboard.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:dismissKeyboard];
}

- (UIView *)makeHeroCard {
    self.heroCard = [[UIView alloc] init];
    self.heroCard.layer.cornerRadius = 22.0;
    self.heroCard.clipsToBounds = YES;
    [self.heroCard.heightAnchor constraintEqualToConstant:142].active = YES;

    self.heroGradient = [CAGradientLayer layer];
    self.heroGradient.colors = @[(id)AIGCColor(89, 62, 224).CGColor, (id)AIGCColor(54, 155, 244).CGColor];
    self.heroGradient.startPoint = CGPointMake(0, 0);
    self.heroGradient.endPoint = CGPointMake(1, 1);
    [self.heroCard.layer addSublayer:self.heroGradient];

    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"wand.and.stars"]];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    icon.tintColor = UIColor.whiteColor;
    icon.translatesAutoresizingMaskIntoConstraints = NO;
    [self.heroCard addSubview:icon];

    UILabel *title = [[UILabel alloc] init];
    title.text = NSLocalizedString(@"LocKey.AIGCHeroTitle", nil);
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont systemFontOfSize:25 weight:UIFontWeightBold];

    UILabel *subtitle = [[UILabel alloc] init];
    subtitle.text = NSLocalizedString(@"LocKey.AIGCHeroSubtitle", nil);
    subtitle.textColor = [UIColor colorWithWhite:1 alpha:0.82];
    subtitle.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    subtitle.numberOfLines = 2;

    UIStackView *labels = [[UIStackView alloc] initWithArrangedSubviews:@[title, subtitle]];
    labels.axis = UILayoutConstraintAxisVertical;
    labels.spacing = 7;
    labels.translatesAutoresizingMaskIntoConstraints = NO;
    [self.heroCard addSubview:labels];

    [NSLayoutConstraint activateConstraints:@[
        [icon.leadingAnchor constraintEqualToAnchor:self.heroCard.leadingAnchor constant:20],
        [icon.centerYAnchor constraintEqualToAnchor:self.heroCard.centerYAnchor],
        [icon.widthAnchor constraintEqualToConstant:50],
        [icon.heightAnchor constraintEqualToConstant:50],
        [labels.leadingAnchor constraintEqualToAnchor:icon.trailingAnchor constant:16],
        [labels.trailingAnchor constraintEqualToAnchor:self.heroCard.trailingAnchor constant:-18],
        [labels.centerYAnchor constraintEqualToAnchor:self.heroCard.centerYAnchor],
    ]];
    return self.heroCard;
}

- (UIView *)makePromptCard {
    UIView *card = [self makeCard];
    UILabel *title = [self makeSectionTitle:NSLocalizedString(@"LocKey.AIGCPromptTitle", nil) systemImage:@"text.quote"];

    self.promptTextView = [[UITextView alloc] init];
    self.promptTextView.delegate = self;
    self.promptTextView.font = [UIFont systemFontOfSize:16];
    self.promptTextView.textColor = UIColor.labelColor;
    self.promptTextView.backgroundColor = UIColor.tertiarySystemBackgroundColor;
    self.promptTextView.layer.cornerRadius = 14.0;
    self.promptTextView.textContainerInset = UIEdgeInsetsMake(14, 12, 14, 12);
    self.promptTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.promptTextView.heightAnchor constraintEqualToConstant:126].active = YES;

    self.placeholderLabel = [[UILabel alloc] init];
    self.placeholderLabel.text = NSLocalizedString(@"LocKey.AIGCPromptPlaceholder", nil);
    self.placeholderLabel.font = self.promptTextView.font;
    self.placeholderLabel.textColor = UIColor.placeholderTextColor;
    self.placeholderLabel.numberOfLines = 0;
    self.placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.promptTextView addSubview:self.placeholderLabel];
    [NSLayoutConstraint activateConstraints:@[
        [self.placeholderLabel.topAnchor constraintEqualToAnchor:self.promptTextView.topAnchor constant:15],
        [self.placeholderLabel.leadingAnchor constraintEqualToAnchor:self.promptTextView.leadingAnchor constant:16],
        [self.placeholderLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.promptTextView.trailingAnchor constant:-16],
    ]];

    UIButton *inspirationButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [inspirationButton setTitle:NSLocalizedString(@"LocKey.AIGCInspiration", nil) forState:UIControlStateNormal];
    [inspirationButton setImage:[UIImage systemImageNamed:@"sparkles"] forState:UIControlStateNormal];
    inspirationButton.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    inspirationButton.tintColor = AIGCColor(111, 78, 246);
    inspirationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    inspirationButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 7);
    [inspirationButton addTarget:self action:@selector(fillExamplePrompt) forControlEvents:UIControlEventTouchUpInside];

    self.characterCountLabel = [[UILabel alloc] init];
    self.characterCountLabel.text = @"0 / 500";
    self.characterCountLabel.textColor = UIColor.secondaryLabelColor;
    self.characterCountLabel.textAlignment = NSTextAlignmentRight;
    self.characterCountLabel.font = [UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightRegular];

    UIStackView *footer = [[UIStackView alloc] initWithArrangedSubviews:@[inspirationButton, self.characterCountLabel]];
    footer.distribution = UIStackViewDistributionFillEqually;

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[title, self.promptTextView, footer]];
    stack.axis = UILayoutConstraintAxisVertical;
    [self pinStack:stack toCard:card spacing:12];
    return card;
}

- (UIView *)makeStyleCard {
    UIView *card = [self makeCard];
    UILabel *title = [self makeSectionTitle:NSLocalizedString(@"LocKey.AIGCStyleTitle", nil) systemImage:@"paintpalette.fill"];

    UIScrollView *styleScrollView = [[UIScrollView alloc] init];
    styleScrollView.showsHorizontalScrollIndicator = NO;
    styleScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [styleScrollView.heightAnchor constraintEqualToConstant:104].active = YES;

    self.styleStackView = [[UIStackView alloc] init];
    self.styleStackView.axis = UILayoutConstraintAxisHorizontal;
    self.styleStackView.spacing = 10;
    self.styleStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [styleScrollView addSubview:self.styleStackView];
    [NSLayoutConstraint activateConstraints:@[
        [self.styleStackView.topAnchor constraintEqualToAnchor:styleScrollView.contentLayoutGuide.topAnchor],
        [self.styleStackView.bottomAnchor constraintEqualToAnchor:styleScrollView.contentLayoutGuide.bottomAnchor],
        [self.styleStackView.leadingAnchor constraintEqualToAnchor:styleScrollView.contentLayoutGuide.leadingAnchor],
        [self.styleStackView.trailingAnchor constraintEqualToAnchor:styleScrollView.contentLayoutGuide.trailingAnchor],
        [self.styleStackView.heightAnchor constraintEqualToAnchor:styleScrollView.frameLayoutGuide.heightAnchor],
    ]];

    self.styleStatusLabel = [[UILabel alloc] init];
    self.styleStatusLabel.text = NSLocalizedString(@"LocKey.AIGCLoadingStyles", nil);
    self.styleStatusLabel.font = [UIFont systemFontOfSize:12];
    self.styleStatusLabel.textColor = UIColor.secondaryLabelColor;

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[title, styleScrollView, self.styleStatusLabel]];
    stack.axis = UILayoutConstraintAxisVertical;
    [self pinStack:stack toCard:card spacing:10];
    return card;
}

- (UIView *)makeCountCard {
    UIView *card = [self makeCard];
    UILabel *title = [self makeSectionTitle:NSLocalizedString(@"LocKey.AIGCCountTitle", nil) systemImage:@"square.grid.2x2.fill"];
    self.countStackView = [[UIStackView alloc] init];
    self.countStackView.axis = UILayoutConstraintAxisHorizontal;
    self.countStackView.spacing = 10;
    self.countStackView.distribution = UIStackViewDistributionFillEqually;
    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[title, self.countStackView]];
    stack.axis = UILayoutConstraintAxisVertical;
    [self pinStack:stack toCard:card spacing:12];
    return card;
}

- (UIView *)makeGenerateButton {
    self.generateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.generateButton setTitle:NSLocalizedString(@"LocKey.AIGCGenerate", nil) forState:UIControlStateNormal];
    [self.generateButton setImage:[UIImage systemImageNamed:@"wand.and.stars"] forState:UIControlStateNormal];
    self.generateButton.tintColor = UIColor.whiteColor;
    [self.generateButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.generateButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
    self.generateButton.backgroundColor = AIGCColor(111, 78, 246);
    self.generateButton.layer.cornerRadius = 16;
    self.generateButton.layer.shadowColor = AIGCColor(111, 78, 246).CGColor;
    self.generateButton.layer.shadowOpacity = 0.28;
    self.generateButton.layer.shadowRadius = 12;
    self.generateButton.layer.shadowOffset = CGSizeMake(0, 7);
    self.generateButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 9);
    [self.generateButton.heightAnchor constraintEqualToConstant:56].active = YES;
    [self.generateButton addTarget:self action:@selector(generateImages) forControlEvents:UIControlEventTouchUpInside];
    return self.generateButton;
}

- (UIView *)makeStatusCard {
    self.statusCard = [self makeCard];
    self.statusCard.hidden = YES;

    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.activityIndicator.color = AIGCColor(111, 78, 246);
    [self.activityIndicator.widthAnchor constraintEqualToConstant:32].active = YES;

    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    self.statusLabel.textColor = UIColor.labelColor;

    self.taskLabel = [[UILabel alloc] init];
    self.taskLabel.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    self.taskLabel.textColor = UIColor.secondaryLabelColor;
    self.taskLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;

    UIStackView *labels = [[UIStackView alloc] initWithArrangedSubviews:@[self.statusLabel, self.taskLabel]];
    labels.axis = UILayoutConstraintAxisVertical;
    labels.spacing = 4;
    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[self.activityIndicator, labels]];
    stack.axis = UILayoutConstraintAxisHorizontal;
    stack.alignment = UIStackViewAlignmentCenter;
    [self pinStack:stack toCard:self.statusCard spacing:12];
    return self.statusCard;
}

- (UIView *)makeResultSection {
    UIView *container = [[UIView alloc] init];
    self.resultTitleLabel = [self makeSectionTitle:NSLocalizedString(@"LocKey.AIGCResultTitle", nil) systemImage:@"photo.on.rectangle.angled"];
    self.resultTitleLabel.hidden = YES;
    self.resultStackView = [[UIStackView alloc] init];
    self.resultStackView.axis = UILayoutConstraintAxisVertical;
    self.resultStackView.spacing = 10;

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[self.resultTitleLabel, self.resultStackView]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 12;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:container.topAnchor],
        [stack.leadingAnchor constraintEqualToAnchor:container.leadingAnchor],
        [stack.trailingAnchor constraintEqualToAnchor:container.trailingAnchor],
        [stack.bottomAnchor constraintEqualToAnchor:container.bottomAnchor],
    ]];
    return container;
}

- (UIView *)makeCard {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
    card.layer.cornerRadius = 20.0;
    card.layer.shadowColor = UIColor.blackColor.CGColor;
    card.layer.shadowOpacity = 0.055;
    card.layer.shadowRadius = 12;
    card.layer.shadowOffset = CGSizeMake(0, 4);
    return card;
}

- (UILabel *)makeSectionTitle:(NSString *)text systemImage:(NSString *)systemImage {
    UILabel *label = [[UILabel alloc] init];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    UIImage *image = [[UIImage systemImageNamed:systemImage] imageWithTintColor:AIGCColor(111, 78, 246) renderingMode:UIImageRenderingModeAlwaysOriginal];
    attachment.image = image;
    attachment.bounds = CGRectMake(0, -2, 18, 18);
    NSMutableAttributedString *value = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
    [value appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@", text] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightBold], NSForegroundColorAttributeName: UIColor.labelColor}]];
    label.attributedText = value;
    return label;
}

- (void)pinStack:(UIStackView *)stack toCard:(UIView *)card spacing:(CGFloat)spacing {
    stack.axis = stack.axis == UILayoutConstraintAxisHorizontal ? UILayoutConstraintAxisHorizontal : UILayoutConstraintAxisVertical;
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

#pragma mark - Styles and count

- (void)loadStyles {
    [self renderStyles:AIBudsAISDK.aigcStyles];
    __weak typeof(self) weakSelf = self;
    [AIBudsAISDK fetchAigcStylesWithCompletion:^(NSArray<AIBudsAIGCStyleModel *> *styles, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            if (styles.count > 0) {
                [self renderStyles:styles];
                self.styleStatusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.AIGCStylesAvailableFormat", nil), (unsigned long)styles.count];
            } else if (error) {
                self.styleStatusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.AIGCStylesFallbackFormat", nil), error.localizedDescription ?: @""];
            } else {
                self.styleStatusLabel.text = NSLocalizedString(@"LocKey.AIGCNoStyles", nil);
            }

            NSInteger serviceMax = AIBudsAISDK.aigcMaxGenerateCount;
            if (serviceMax > 0) {
                self.maxImageCount = MIN(4, serviceMax);
                [self reloadCountOptions];
            }
        });
    }];
}

- (void)renderStyles:(NSArray<AIBudsAIGCStyleModel *> *)styles {
    self.availableStyles = styles ?: @[];
    for (UIView *view in self.styleStackView.arrangedSubviews.copy) {
        [self.styleStackView removeArrangedSubview:view];
        [view removeFromSuperview];
    }

    AIGCStyleItemView *autoStyle = [self addStyleNamed:NSLocalizedString(@"LocKey.AIGCAutoStyle", nil) code:nil iconURL:nil];
    autoStyle.selected = self.selectedStyleCode == nil;
    for (AIBudsAIGCStyleModel *style in styles) {
        AIGCStyleItemView *item = [self addStyleNamed:style.name code:style.styleCode iconURL:style.iconUrl];
        item.selected = [style.styleCode isEqualToString:self.selectedStyleCode];
    }
}

- (AIGCStyleItemView *)addStyleNamed:(NSString *)name code:(NSString *)code iconURL:(NSString *)iconURL {
    AIGCStyleItemView *item = [[AIGCStyleItemView alloc] init];
    [item configureWithName:name styleCode:code iconURL:iconURL];
    [item.widthAnchor constraintEqualToConstant:88].active = YES;
    [item addTarget:self action:@selector(selectStyle:) forControlEvents:UIControlEventTouchUpInside];
    [self.styleStackView addArrangedSubview:item];
    return item;
}

- (void)selectStyle:(AIGCStyleItemView *)sender {
    self.selectedStyleCode = sender.styleCode;
    for (AIGCStyleItemView *item in self.styleStackView.arrangedSubviews) {
        item.selected = item == sender;
    }
    UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    [feedback impactOccurred];
}

- (void)reloadCountOptions {
    for (UIView *view in self.countStackView.arrangedSubviews.copy) {
        [self.countStackView removeArrangedSubview:view];
        [view removeFromSuperview];
    }
    self.maxImageCount = MAX(1, self.maxImageCount);
    self.selectedImageCount = MIN(MAX(1, self.selectedImageCount), self.maxImageCount);
    for (NSInteger count = 1; count <= self.maxImageCount; count++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tag = count;
        [button setTitle:[NSString stringWithFormat:@"%ld", (long)count] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
        button.layer.cornerRadius = 11;
        [button.heightAnchor constraintEqualToConstant:42].active = YES;
        [button addTarget:self action:@selector(selectCount:) forControlEvents:UIControlEventTouchUpInside];
        [self.countStackView addArrangedSubview:button];
    }
    [self updateCountButtons];
}

- (void)selectCount:(UIButton *)sender {
    self.selectedImageCount = sender.tag;
    [self updateCountButtons];
}

- (void)updateCountButtons {
    for (UIButton *button in self.countStackView.arrangedSubviews) {
        BOOL selected = button.tag == self.selectedImageCount;
        button.backgroundColor = selected ? AIGCColor(111, 78, 246) : UIColor.tertiarySystemBackgroundColor;
        [button setTitleColor:selected ? UIColor.whiteColor : UIColor.labelColor forState:UIControlStateNormal];
    }
}

#pragma mark - Generate

- (void)generateImages {
    NSString *prompt = [self.promptTextView.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (prompt.length == 0) {
        [self.promptTextView becomeFirstResponder];
        [self.view makeToast:NSLocalizedString(@"LocKey.AIGCEmptyPrompt", nil) duration:2.0 position:CSToastPositionCenter];
        return;
    }
    if (self.generating) return;

    [self endEditing];
    [self clearResults];
    [self setGenerating:YES];
    self.statusCard.hidden = NO;
    self.statusLabel.text = NSLocalizedString(@"LocKey.AIGCCreatingTask", nil);
    self.taskLabel.text = @"";

    AIBudsAIGCTaskConfig *config = [AIBudsAIGCTaskConfig defaultConfig];
    NSString *resolvedStyleCode = self.selectedStyleCode;
    if (resolvedStyleCode.length == 0 && self.availableStyles.count > 0) {
        resolvedStyleCode = self.availableStyles.firstObject.styleCode;
    }
    config.style = resolvedStyleCode;
    config.imageCount = self.selectedImageCount;
    config.language = NSLocale.preferredLanguages.firstObject;

    __weak typeof(self) weakSelf = self;
    [AIBudsAISDK generateAIPhotoWithPrompt:prompt config:config taskCreated:^(NSString *taskId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            self.statusLabel.text = NSLocalizedString(@"LocKey.AIGCGenerating", nil);
            self.taskLabel.text = [NSString stringWithFormat:@"Task ID  ·  %@", taskId];
        });
    } completion:^(NSString *taskId, BOOL success, NSArray<UIImage *> *images, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            [self setGenerating:NO];
            if (success && images.count > 0) {
                self.statusLabel.text = NSLocalizedString(@"LocKey.AIGCGenerated", nil);
                self.taskLabel.text = taskId.length > 0 ? [NSString stringWithFormat:@"Task ID  ·  %@", taskId] : @"";
                [self showResults:images];
            } else {
                self.statusLabel.text = NSLocalizedString(@"LocKey.AIGCGenerateFailed", nil);
                self.taskLabel.text = error.localizedDescription ?: NSLocalizedString(@"LocKey.AIGCUnknownError", nil);
                [self.view makeToast:self.taskLabel.text duration:3.0 position:CSToastPositionCenter];
            }
        });
    }];
}

- (void)setGenerating:(BOOL)generating {
    _generating = generating;
    self.generateButton.enabled = !generating;
    self.generateButton.alpha = generating ? 0.65 : 1.0;
    if (generating) {
        [self.activityIndicator startAnimating];
        [self.generateButton setTitle:NSLocalizedString(@"LocKey.AIGCGenerating", nil) forState:UIControlStateNormal];
    } else {
        [self.activityIndicator stopAnimating];
        [self.generateButton setTitle:NSLocalizedString(@"LocKey.AIGCGenerateAgain", nil) forState:UIControlStateNormal];
    }
}

- (void)clearResults {
    self.resultTitleLabel.hidden = YES;
    for (UIView *view in self.resultStackView.arrangedSubviews.copy) {
        [self.resultStackView removeArrangedSubview:view];
        [view removeFromSuperview];
    }
}

- (void)showResults:(NSArray<UIImage *> *)images {
    self.resultTitleLabel.hidden = NO;
    for (NSInteger index = 0; index < images.count; index += 2) {
        NSMutableArray<UIView *> *tiles = [NSMutableArray array];
        for (NSInteger column = 0; column < 2; column++) {
            NSInteger imageIndex = index + column;
            if (imageIndex < images.count) {
                UIButton *tile = [UIButton buttonWithType:UIButtonTypeCustom];
                tile.tag = imageIndex;
                [tile setImage:images[imageIndex] forState:UIControlStateNormal];
                tile.imageView.contentMode = UIViewContentModeScaleAspectFill;
                tile.layer.cornerRadius = 18;
                tile.clipsToBounds = YES;
                [tile.heightAnchor constraintEqualToAnchor:tile.widthAnchor].active = YES;
                [tile addTarget:self action:@selector(previewImage:) forControlEvents:UIControlEventTouchUpInside];
                [tiles addObject:tile];
            } else {
                UIView *spacer = [[UIView alloc] init];
                [tiles addObject:spacer];
            }
        }
        UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:tiles];
        row.axis = UILayoutConstraintAxisHorizontal;
        row.distribution = UIStackViewDistributionFillEqually;
        row.spacing = 10;
        [self.resultStackView addArrangedSubview:row];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect target = [self.resultTitleLabel convertRect:self.resultTitleLabel.bounds toView:self.scrollView];
        [self.scrollView scrollRectToVisible:CGRectInset(target, 0, -20) animated:YES];
    });
}

- (void)previewImage:(UIButton *)sender {
    UIImage *image = [sender imageForState:UIControlStateNormal];
    if (!image) return;

    UIViewController *preview = [[UIViewController alloc] init];
    preview.view.backgroundColor = UIColor.blackColor;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [preview.view addSubview:imageView];
    [NSLayoutConstraint activateConstraints:@[
        [imageView.topAnchor constraintEqualToAnchor:preview.view.topAnchor],
        [imageView.leadingAnchor constraintEqualToAnchor:preview.view.leadingAnchor],
        [imageView.trailingAnchor constraintEqualToAnchor:preview.view.trailingAnchor],
        [imageView.bottomAnchor constraintEqualToAnchor:preview.view.bottomAnchor],
    ]];

    UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
    [close setImage:[UIImage systemImageNamed:@"xmark.circle.fill"] forState:UIControlStateNormal];
    close.tintColor = [UIColor colorWithWhite:1 alpha:0.9];
    close.imageView.contentMode = UIViewContentModeScaleAspectFit;
    close.translatesAutoresizingMaskIntoConstraints = NO;
    [close addTarget:self action:@selector(closePreview) forControlEvents:UIControlEventTouchUpInside];
    [preview.view addSubview:close];
    [NSLayoutConstraint activateConstraints:@[
        [close.topAnchor constraintEqualToAnchor:preview.view.safeAreaLayoutGuide.topAnchor constant:12],
        [close.trailingAnchor constraintEqualToAnchor:preview.view.trailingAnchor constant:-18],
        [close.widthAnchor constraintEqualToConstant:38],
        [close.heightAnchor constraintEqualToConstant:38],
    ]];
    preview.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:preview animated:YES completion:nil];
}

- (void)closePreview {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Input and keyboard

- (void)fillExamplePrompt {
    NSArray<NSString *> *examples = @[
        NSLocalizedString(@"LocKey.AIGCExamplePrompt1", nil),
        NSLocalizedString(@"LocKey.AIGCExamplePrompt2", nil),
        NSLocalizedString(@"LocKey.AIGCExamplePrompt3", nil),
    ];
    NSString *current = self.promptTextView.text ?: @"";
    NSUInteger currentIndex = [examples indexOfObject:current];
    NSUInteger nextIndex = currentIndex == NSNotFound ? 0 : (currentIndex + 1) % examples.count;
    self.promptTextView.text = examples[nextIndex];
    [self textViewDidChange:self.promptTextView];
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 500) {
        textView.text = [textView.text substringToIndex:500];
    }
    self.placeholderLabel.hidden = textView.text.length > 0;
    self.characterCountLabel.text = [NSString stringWithFormat:@"%lu / 500", (unsigned long)textView.text.length];
}

- (void)endEditing {
    [self.view endEditing:YES];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect frameInView = [self.view convertRect:keyboardFrame fromView:nil];
    CGFloat overlap = MAX(0, CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(frameInView));
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, overlap, 0);
    self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

@end
