//
//  TurnByTurnNavigationDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-30.
//  Copyright © 2026 Zero Zero Status. All rights reserved.
//

#import "TurnByTurnNavigationDemoController.h"
#import <AIBuds/AIBuds.h>

@interface TurnByTurnNavigationDemoController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIView *navDisplayCard;
@property (nonatomic, strong) UIImageView *maneuverIconView;
@property (nonatomic, strong) UILabel *distanceLabel;
@property (nonatomic, strong) UILabel *instructionLabel;
@property (nonatomic, strong) UILabel *roadNameLabel;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UILabel *remainingTimeLabel;
@property (nonatomic, strong) UILabel *remainingDistanceLabel;
@property (nonatomic, strong) UIView *alertBadge;
@property (nonatomic, strong) UILabel *alertLabel;

@property (nonatomic, strong) UIView *controlCard;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *randomButton;

@property (nonatomic, strong) UIView *statusCard;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *statusLabel;

@property (nonatomic, strong) NSArray *maneuverTypes;
@property (nonatomic, strong) NSArray *instructions;
@property (nonatomic, strong) NSArray *roadNames;
@property (nonatomic, strong) NSArray *mapProviders;
@property (nonatomic, strong) NSArray *transportModes;
@property (nonatomic, strong) NSArray *alertTypes;

@end

@implementation TurnByTurnNavigationDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupData];
    [self setupUI];
    [self updateNavDisplayWithInfo:[self generateRandomNavigationInfo]];
}

- (void)setupData {
    self.maneuverTypes = @[@(0x01), @(0x02), @(0x03), @(0x04), @(0x05), @(0x06), @(0x07), @(0x08), @(0x0B), @(0x16), @(0x19), @(0x1B), @(0x1C)];
    self.instructions = @[
        NSLocalizedString(@"LocKey.NavigationStart", @"Start navigation"),
        NSLocalizedString(@"LocKey.NavigationStraight", @"Go straight"),
        NSLocalizedString(@"LocKey.NavigationSlightRight", @"Slight right"),
        NSLocalizedString(@"LocKey.NavigationTurnRight", @"Turn right"),
        NSLocalizedString(@"LocKey.NavigationSharpRight", @"Sharp right"),
        NSLocalizedString(@"LocKey.NavigationSlightLeft", @"Slight left"),
        NSLocalizedString(@"LocKey.NavigationTurnLeft", @"Turn left"),
        NSLocalizedString(@"LocKey.NavigationSharpLeft", @"Sharp left"),
        NSLocalizedString(@"LocKey.NavigationUturn", @"Make a U-turn"),
        NSLocalizedString(@"LocKey.NavigationEnterHighway", @"Enter highway"),
        NSLocalizedString(@"LocKey.NavigationExitHighway", @"Exit highway"),
        NSLocalizedString(@"LocKey.NavigationEnterTunnel", @"Enter tunnel"),
        NSLocalizedString(@"LocKey.NavigationExitTunnel", @"Exit tunnel")
    ];
    self.roadNames = @[
        @"厚载门街", @"开源大道", @"科技六路", @"丈八东路", @"唐延路",
        @"长安南路", @"二环南路", @"朱雀大街", @"含光路", @"太白南路",
        @"High Street", @"Main Road", @"Central Avenue", @"Park Lane", @"Oak Street"
    ];
    self.mapProviders = @[@(0x00), @(0x01), @(0x02), @(0x03), @(0x04)];
    self.transportModes = @[@(0x00), @(0x01), @(0x02), @(0x03), @(0x04)];
    self.alertTypes = @[
        NSLocalizedString(@"LocKey.AlertSpeedLimit", @"Speed limit"),
        NSLocalizedString(@"LocKey.AlertCamera", @"Violation camera"),
        NSLocalizedString(@"LocKey.AlertConstruction", @"Road construction"),
        NSLocalizedString(@"LocKey.AlertAccident", @"Accident prone area"),
        NSLocalizedString(@"LocKey.AlertWeakGPS", @"Weak GPS signal"),
        NSLocalizedString(@"LocKey.AlertIcyRoad", @"Icy road"),
        NSLocalizedString(@"LocKey.AlertRoadClosed", @"Road closed")
    ];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    [self createScrollView];
    [self createNavDisplayCard];
    [self createControlCard];
    [self createStatusCard];
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
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor]
    ]];
}

- (void)createNavDisplayCard {
    self.navDisplayCard = [[UIView alloc] init];
    self.navDisplayCard.backgroundColor = [UIColor systemBackgroundColor];
    self.navDisplayCard.layer.cornerRadius = 20;
    self.navDisplayCard.layer.shadowColor = [UIColor blackColor].CGColor;
    self.navDisplayCard.layer.shadowOpacity = 0.15;
    self.navDisplayCard.layer.shadowOffset = CGSizeMake(0, 6);
    self.navDisplayCard.layer.shadowRadius = 12;
    [self.contentView addSubview:self.navDisplayCard];
    [self.navDisplayCard setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.navDisplayCard.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:20],
        [self.navDisplayCard.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.navDisplayCard.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20]
    ]];
    
    UIView *maneuverContainer = [[UIView alloc] init];
    maneuverContainer.backgroundColor = [UIColor systemBlueColor];
    maneuverContainer.layer.cornerRadius = 50;
    [self.navDisplayCard addSubview:maneuverContainer];
    [maneuverContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [maneuverContainer.topAnchor constraintEqualToAnchor:self.navDisplayCard.topAnchor constant:24],
        [maneuverContainer.centerXAnchor constraintEqualToAnchor:self.navDisplayCard.centerXAnchor],
        [maneuverContainer.widthAnchor constraintEqualToConstant:100],
        [maneuverContainer.heightAnchor constraintEqualToConstant:100]
    ]];
    
    self.maneuverIconView = [[UIImageView alloc] init];
    self.maneuverIconView.tintColor = [UIColor whiteColor];
    self.maneuverIconView.contentMode = UIViewContentModeScaleAspectFit;
    self.maneuverIconView.image = [UIImage systemImageNamed:@"arrow.turn.up.right"];
    [maneuverContainer addSubview:self.maneuverIconView];
    [self.maneuverIconView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.maneuverIconView.centerXAnchor constraintEqualToAnchor:maneuverContainer.centerXAnchor],
        [self.maneuverIconView.centerYAnchor constraintEqualToAnchor:maneuverContainer.centerYAnchor],
        [self.maneuverIconView.widthAnchor constraintEqualToConstant:50],
        [self.maneuverIconView.heightAnchor constraintEqualToConstant:50]
    ]];
    
    self.distanceLabel = [[UILabel alloc] init];
    self.distanceLabel.text = @"300m";
    self.distanceLabel.font = [UIFont systemFontOfSize:48 weight:UIFontWeightBold];
    self.distanceLabel.textColor = [UIColor labelColor];
    self.distanceLabel.textAlignment = NSTextAlignmentCenter;
    [self.navDisplayCard addSubview:self.distanceLabel];
    [self.distanceLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.distanceLabel.topAnchor constraintEqualToAnchor:maneuverContainer.bottomAnchor constant:16],
        [self.distanceLabel.centerXAnchor constraintEqualToAnchor:self.navDisplayCard.centerXAnchor]
    ]];
    
    self.instructionLabel = [[UILabel alloc] init];
    self.instructionLabel.text = NSLocalizedString(@"LocKey.NavigationTurnRight", @"Turn right");
    self.instructionLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
    self.instructionLabel.textColor = [UIColor labelColor];
    self.instructionLabel.textAlignment = NSTextAlignmentCenter;
    [self.navDisplayCard addSubview:self.instructionLabel];
    [self.instructionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.instructionLabel.topAnchor constraintEqualToAnchor:self.distanceLabel.bottomAnchor constant:8],
        [self.instructionLabel.centerXAnchor constraintEqualToAnchor:self.navDisplayCard.centerXAnchor]
    ]];
    
    self.roadNameLabel = [[UILabel alloc] init];
    self.roadNameLabel.text = @"开源大道";
    self.roadNameLabel.font = [UIFont systemFontOfSize:16];
    self.roadNameLabel.textColor = [UIColor secondaryLabelColor];
    self.roadNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.navDisplayCard addSubview:self.roadNameLabel];
    [self.roadNameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.roadNameLabel.topAnchor constraintEqualToAnchor:self.instructionLabel.bottomAnchor constant:12],
        [self.roadNameLabel.centerXAnchor constraintEqualToAnchor:self.navDisplayCard.centerXAnchor]
    ]];
    
    self.alertBadge = [[UIView alloc] init];
    self.alertBadge.backgroundColor = [UIColor systemOrangeColor];
    self.alertBadge.layer.cornerRadius = 12;
    self.alertBadge.hidden = YES;
    [self.navDisplayCard addSubview:self.alertBadge];
    [self.alertBadge setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.alertBadge.topAnchor constraintEqualToAnchor:self.roadNameLabel.bottomAnchor constant:16],
        [self.alertBadge.centerXAnchor constraintEqualToAnchor:self.navDisplayCard.centerXAnchor],
        [self.alertBadge.heightAnchor constraintEqualToConstant:24]
    ]];
    
    self.alertLabel = [[UILabel alloc] init];
    self.alertLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    self.alertLabel.textColor = [UIColor whiteColor];
    [self.alertBadge addSubview:self.alertLabel];
    [self.alertLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.alertLabel.topAnchor constraintEqualToAnchor:self.alertBadge.topAnchor],
        [self.alertLabel.bottomAnchor constraintEqualToAnchor:self.alertBadge.bottomAnchor],
        [self.alertLabel.leadingAnchor constraintEqualToAnchor:self.alertBadge.leadingAnchor constant:10],
        [self.alertLabel.trailingAnchor constraintEqualToAnchor:self.alertBadge.trailingAnchor constant:-10]
    ]];
    
    UIView *divider = [[UIView alloc] init];
    divider.backgroundColor = [UIColor separatorColor];
    [self.navDisplayCard addSubview:divider];
    [divider setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [divider.topAnchor constraintEqualToAnchor:self.alertBadge.bottomAnchor constant:20],
        [divider.leadingAnchor constraintEqualToAnchor:self.navDisplayCard.leadingAnchor constant:20],
        [divider.trailingAnchor constraintEqualToAnchor:self.navDisplayCard.trailingAnchor constant:-20],
        [divider.heightAnchor constraintEqualToConstant:1]
    ]];
    
    UIStackView *infoStack = [[UIStackView alloc] init];
    infoStack.axis = UILayoutConstraintAxisHorizontal;
    infoStack.distribution = UIStackViewDistributionEqualSpacing;
    [self.navDisplayCard addSubview:infoStack];
    [infoStack setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [infoStack.topAnchor constraintEqualToAnchor:divider.bottomAnchor constant:16],
        [infoStack.leadingAnchor constraintEqualToAnchor:self.navDisplayCard.leadingAnchor constant:30],
        [infoStack.trailingAnchor constraintEqualToAnchor:self.navDisplayCard.trailingAnchor constant:-30],
        [infoStack.bottomAnchor constraintEqualToAnchor:self.navDisplayCard.bottomAnchor constant:-20]
    ]];
    
    UIView *timeContainer = [self createInfoContainerWithIcon:@"clock" titleKey:@"LocKey.NavigationRemainingTime"];
    self.remainingTimeLabel = timeContainer.subviews.lastObject;
    [infoStack addArrangedSubview:timeContainer];
    
    UIView *distanceContainer = [self createInfoContainerWithIcon:@"road.lanes" titleKey:@"LocKey.NavigationRemainingDistance"];
    self.remainingDistanceLabel = distanceContainer.subviews.lastObject;
    [infoStack addArrangedSubview:distanceContainer];
}

- (UIView *)createInfoContainerWithIcon:(NSString *)iconName titleKey:(NSString *)titleKey {
    UIView *container = [[UIView alloc] init];
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:iconName]];
    icon.tintColor = [UIColor systemBlueColor];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    [container addSubview:icon];
    [icon setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [icon.topAnchor constraintEqualToAnchor:container.topAnchor],
        [icon.centerXAnchor constraintEqualToAnchor:container.centerXAnchor],
        [icon.widthAnchor constraintEqualToConstant:24],
        [icon.heightAnchor constraintEqualToConstant:24]
    ]];
    
    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.text = @"--";
    valueLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    valueLabel.textColor = [UIColor labelColor];
    valueLabel.textAlignment = NSTextAlignmentCenter;
    [container addSubview:valueLabel];
    [valueLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [valueLabel.topAnchor constraintEqualToAnchor:icon.bottomAnchor constant:4],
        [valueLabel.centerXAnchor constraintEqualToAnchor:container.centerXAnchor],
        [valueLabel.bottomAnchor constraintEqualToAnchor:container.bottomAnchor]
    ]];
    
    return container;
}

- (void)createControlCard {
    self.controlCard = [[UIView alloc] init];
    self.controlCard.backgroundColor = [UIColor systemBackgroundColor];
    self.controlCard.layer.cornerRadius = 16;
    self.controlCard.layer.shadowColor = [UIColor blackColor].CGColor;
    self.controlCard.layer.shadowOpacity = 0.1;
    self.controlCard.layer.shadowOffset = CGSizeMake(0, 4);
    self.controlCard.layer.shadowRadius = 8;
    [self.contentView addSubview:self.controlCard];
    [self.controlCard setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.controlCard.topAnchor constraintEqualToAnchor:self.navDisplayCard.bottomAnchor constant:20],
        [self.controlCard.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.controlCard.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20]
    ]];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.NavigationSimulation", @"Navigation Simulation");
    titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    [self.controlCard addSubview:titleLabel];
    [titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.controlCard.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.controlCard.leadingAnchor constant:20]
    ]];
    
    UIStackView *buttonStack = [[UIStackView alloc] init];
    buttonStack.axis = UILayoutConstraintAxisHorizontal;
    buttonStack.spacing = 12;
    buttonStack.distribution = UIStackViewDistributionFillEqually;
    [self.controlCard addSubview:buttonStack];
    [buttonStack setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [buttonStack.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:16],
        [buttonStack.leadingAnchor constraintEqualToAnchor:self.controlCard.leadingAnchor constant:20],
        [buttonStack.trailingAnchor constraintEqualToAnchor:self.controlCard.trailingAnchor constant:-20],
        [buttonStack.bottomAnchor constraintEqualToAnchor:self.controlCard.bottomAnchor constant:-20]
    ]];
    
    self.randomButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.randomButton setTitle:NSLocalizedString(@"LocKey.NavigationNextStep", @"Next Step") forState:UIControlStateNormal];
    [self.randomButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    self.randomButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.randomButton.layer.borderWidth = 1.5;
    self.randomButton.layer.borderColor = [UIColor systemBlueColor].CGColor;
    self.randomButton.layer.cornerRadius = 10;
    [self.randomButton addTarget:self action:@selector(randomButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [buttonStack addArrangedSubview:self.randomButton];
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.sendButton setTitle:NSLocalizedString(@"LocKey.NavigationSend", @"Send to Device") forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton setBackgroundColor:[UIColor systemBlueColor]];
    self.sendButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.sendButton.layer.cornerRadius = 10;
    [self.sendButton addTarget:self action:@selector(sendButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [buttonStack addArrangedSubview:self.sendButton];
}

- (void)createStatusCard {
    self.statusCard = [[UIView alloc] init];
    self.statusCard.backgroundColor = [UIColor systemBackgroundColor];
    self.statusCard.layer.cornerRadius = 16;
    self.statusCard.layer.shadowColor = [UIColor blackColor].CGColor;
    self.statusCard.layer.shadowOpacity = 0.1;
    self.statusCard.layer.shadowOffset = CGSizeMake(0, 4);
    self.statusCard.layer.shadowRadius = 8;
    [self.contentView addSubview:self.statusCard];
    [self.statusCard setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.statusCard.topAnchor constraintEqualToAnchor:self.controlCard.bottomAnchor constant:20],
        [self.statusCard.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.statusCard.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20]
    ]];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.NavigationStatus", @"Status");
    titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    [self.statusCard addSubview:titleLabel];
    [titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.statusCard.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.statusCard.leadingAnchor constant:20]
    ]];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.statusCard addSubview:self.activityIndicator];
    [self.activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.activityIndicator.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:16],
        [self.activityIndicator.leadingAnchor constraintEqualToAnchor:self.statusCard.leadingAnchor constant:20]
    ]];
    
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = NSLocalizedString(@"LocKey.NavigationReady", @"Ready to simulate navigation");
    self.statusLabel.font = [UIFont systemFontOfSize:14];
    self.statusLabel.textColor = [UIColor secondaryLabelColor];
    self.statusLabel.numberOfLines = 0;
    [self.statusCard addSubview:self.statusLabel];
    [self.statusLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.statusLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:16],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.activityIndicator.trailingAnchor constant:12],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.statusCard.trailingAnchor constant:-20],
        [self.statusLabel.bottomAnchor constraintEqualToAnchor:self.statusCard.bottomAnchor constant:-20]
    ]];
    
    UIView *bottomSpacer = [[UIView alloc] init];
    [self.contentView addSubview:bottomSpacer];
    [bottomSpacer setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [bottomSpacer.topAnchor constraintEqualToAnchor:self.statusCard.bottomAnchor constant:20],
        [bottomSpacer.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [bottomSpacer.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [bottomSpacer.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
        [bottomSpacer.heightAnchor constraintEqualToConstant:100]
    ]];
}

- (AIBudsNavigationInfoModel *)generateRandomNavigationInfo {
    AIBudsNavigationInfoModel *info = [[AIBudsNavigationInfoModel alloc] init];
    
    NSInteger maneuverIndex = arc4random() % self.maneuverTypes.count;
    info.maneuver = self.maneuverTypes[maneuverIndex];
    info.instruction = self.instructions[maneuverIndex];
    
    info.roadName = self.roadNames[arc4random() % self.roadNames.count];
    
    NSInteger distance = 50 + arc4random() % 2000;
    NSString *distanceText;
    if (distance < 1000) {
        distanceText = [NSString stringWithFormat:@"%ldm", (long)distance];
    } else {
        distanceText = [NSString stringWithFormat:@"%.1fkm", distance / 1000.0];
    }
    info.nextStepDistanceText = distanceText;
    
    info.mapProvider = self.mapProviders[arc4random() % self.mapProviders.count];
    info.transportMode = self.transportModes[arc4random() % self.transportModes.count];
    
    NSInteger remainingTime = 60 + arc4random() % 3600;
    info.remainingTime = @(remainingTime);
    
    NSInteger remainingDistance = 1000 + arc4random() % 10000;
    info.remainingDistance = @(remainingDistance);
    
    if (arc4random() % 3 == 0) {
        NSInteger alertType = 0x01 + arc4random() % 7;
        AIBudsNavigationAlertInfoModel *alertInfo = [[AIBudsNavigationAlertInfoModel alloc] initWithAlertType:@(alertType) paramsValue:nil];
        if (alertType == 0x01 || alertType == 0x04) {
            alertInfo.paramsValue = @(30 + arc4random() % 80);
        } else if (alertType == 0x0D) {
            alertInfo.paramsValue = @(arc4random() % 99);
        }
        info.alertInfo = alertInfo;
    }
    
    return info;
}

- (void)updateNavDisplayWithInfo:(AIBudsNavigationInfoModel *)info {
    NSInteger maneuverValue = [info.maneuver integerValue];
    NSString *iconName = [self iconNameForManeuver:maneuverValue];
    self.maneuverIconView.image = [UIImage systemImageNamed:iconName];
    
    self.distanceLabel.text = info.nextStepDistanceText ?: @"--";
    self.instructionLabel.text = info.instruction ?: @"--";
    self.roadNameLabel.text = info.roadName ?: @"--";
    
    if (info.remainingTime) {
        NSInteger seconds = [info.remainingTime integerValue];
        if (seconds >= 3600) {
            self.remainingTimeLabel.text = [NSString stringWithFormat:@"%ldh %ldm", (long)(seconds / 3600), (long)((seconds % 3600) / 60)];
        } else {
            self.remainingTimeLabel.text = [NSString stringWithFormat:@"%ldmin", (long)(seconds / 60)];
        }
    } else {
        self.remainingTimeLabel.text = @"--";
    }
    
    if (info.remainingDistance) {
        NSInteger meters = [info.remainingDistance integerValue];
        if (meters >= 1000) {
            self.remainingDistanceLabel.text = [NSString stringWithFormat:@"%.1fkm", meters / 1000.0];
        } else {
            self.remainingDistanceLabel.text = [NSString stringWithFormat:@"%ldm", (long)meters];
        }
    } else {
        self.remainingDistanceLabel.text = @"--";
    }
    
    if (info.alertInfo) {
        NSInteger alertType = [info.alertInfo.alertType integerValue];
        self.alertLabel.text = [self alertTextForType:alertType paramsValue:info.alertInfo.paramsValue];
        self.alertBadge.hidden = NO;
        
        if (alertType == 0x01 || alertType == 0x04 || alertType == 0x06) {
            self.alertBadge.backgroundColor = [UIColor systemRedColor];
        } else if (alertType == 0x02 || alertType == 0x03) {
            self.alertBadge.backgroundColor = [UIColor systemOrangeColor];
        } else {
            self.alertBadge.backgroundColor = [UIColor systemYellowColor];
        }
    } else {
        self.alertBadge.hidden = YES;
    }
}

- (NSString *)iconNameForManeuver:(NSInteger)maneuver {
    switch (maneuver) {
        case 0x01: return @"figure.walk";
        case 0x02: return @"arrow.up";
        case 0x03: return @"arrow.turn.up.right";
        case 0x04: return @"arrow.turn.right";
        case 0x05: return @"arrow.turn.up.right";
        case 0x06: return @"arrow.turn.up.left";
        case 0x07: return @"arrow.turn.left";
        case 0x08: return @"arrow.turn.up.left";
        case 0x09: return @"arrow.uturn.down";
        case 0x0B: return @"flag.checkered";
        case 0x16: return @"arrow.up.right.circle";
        case 0x19: return @"arrow.down.left.circle";
        case 0x1B: return @"building.2";
        case 0x1C: return @"building.2";
        default: return @"arrow.up";
    }
}

- (NSString *)alertTextForType:(NSInteger)alertType paramsValue:(NSNumber *)paramsValue {
    switch (alertType) {
        case 0x01:
            return paramsValue ? [NSString stringWithFormat:@"%@ km/h", paramsValue] : NSLocalizedString(@"LocKey.AlertSpeedLimit", @"Speed limit");
        case 0x02:
            return NSLocalizedString(@"LocKey.AlertCamera", @"Violation camera");
        case 0x03:
            return NSLocalizedString(@"LocKey.AlertConstruction", @"Road construction");
        case 0x04:
            return paramsValue ? [NSString stringWithFormat:@"%@ km/h", paramsValue] : NSLocalizedString(@"LocKey.AlertAverageSpeed", @"Average speed zone");
        case 0x05:
            return NSLocalizedString(@"LocKey.AlertAccident", @"Accident prone area");
        case 0x06:
            return NSLocalizedString(@"LocKey.AlertRearVehicle", @"Rear vehicle warning");
        case 0x07:
            return NSLocalizedString(@"LocKey.AlertWeakGPS", @"Weak GPS signal");
        case 0x08:
            return NSLocalizedString(@"LocKey.AlertIcyRoad", @"Icy road");
        case 0x09:
            return NSLocalizedString(@"LocKey.AlertRoadClosed", @"Road closed");
        default:
            return NSLocalizedString(@"LocKey.AlertDefault", @"Alert");
    }
}

- (void)randomButtonTapped:(UIButton *)sender {
    AIBudsNavigationInfoModel *info = [self generateRandomNavigationInfo];
    [self updateNavDisplayWithInfo:info];
    [self showStatus:NSLocalizedString(@"LocKey.NavigationGenerated", @"Generated new navigation step") error:NO];
}

- (void)sendButtonTapped:(UIButton *)sender {
    [self showLoading:YES];
    
    id<AIBudsTurnByTurnNavigationAPI> navAPI = (id<AIBudsTurnByTurnNavigationAPI>)self.device;
    
    if (!navAPI) {
        [self showLoading:NO];
        [self showStatus:NSLocalizedString(@"LocKey.NavigationNotSupported", @"Navigation not supported on this device") error:YES];
        return;
    }
    
    AIBudsNavigationInfoModel *info = [self generateRandomNavigationInfo];
    [self updateNavDisplayWithInfo:info];
    
    __weak typeof(self) weakSelf = self;
    [navAPI sendNavigationInfo:info completion:^(BOOL success, NSNumber *statusCode, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showLoading:NO];
            if (success) {
                [weakSelf showStatus:[NSString stringWithFormat:NSLocalizedString(@"LocKey.NavigationSendSuccessFormat", @"Navigation sent successfully (status: %@)"), statusCode ?: @"--"] error:NO];
            } else {
                [weakSelf showStatus:[NSString stringWithFormat:NSLocalizedString(@"LocKey.NavigationSendFailedFormat", @"Send failed: %@"), error.localizedDescription] error:YES];
            }
        });
    }];
}

- (void)showLoading:(BOOL)loading {
    if (loading) {
        [self.activityIndicator startAnimating];
        self.sendButton.enabled = NO;
        self.randomButton.enabled = NO;
    } else {
        [self.activityIndicator stopAnimating];
        self.sendButton.enabled = YES;
        self.randomButton.enabled = YES;
    }
}

- (void)showStatus:(NSString *)status error:(BOOL)isError {
    self.statusLabel.text = status;
    self.statusLabel.textColor = isError ? [UIColor systemRedColor] : [UIColor secondaryLabelColor];
}

@end