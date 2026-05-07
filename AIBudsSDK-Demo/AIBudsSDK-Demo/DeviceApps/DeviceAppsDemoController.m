//
//  DeviceAppsDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-30.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "DeviceAppsDemoController.h"

@interface DeviceAppsDemoController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIView *headerCard;
@property (nonatomic, strong) UILabel *foregroundAppLabel;

@property (nonatomic, strong) UIView *appsListCard;
@property (nonatomic, strong) UITableView *appsTableView;

@property (nonatomic, strong) UIView *controlCard;
@property (nonatomic, strong) UIButton *homeButton;

@property (nonatomic, strong) UIView *statusCard;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *statusLabel;

@property (nonatomic, strong) NSArray *deviceApps;
@property (nonatomic, strong) NSMutableSet *runningApps;
@property (nonatomic, assign) NSInteger currentForegroundApp;
@property (nonatomic, strong) NSDictionary *appInfoMapping;

@end

@implementation DeviceAppsDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.runningApps = [NSMutableSet set];
    self.currentForegroundApp = 0;
    [self setupAppInfoMapping];
    [self setupUI];
    [self fetchDeviceApps];
    [self refreshForegroundApp];
}

- (void)setupAppInfoMapping {
    self.appInfoMapping = @{
        @(AIBudsDeviceAppTeleprompter): @{@"name": NSLocalizedString(@"LocKey.AppTeleprompter", @"Overlay Prompt"), @"icon": @"text.bubble"},
        @(AIBudsDeviceAppAiChat): @{@"name": NSLocalizedString(@"LocKey.AppAIChat", @"AI Chat"), @"icon": @"bubble.left.and.bubble.right"},
        @(AIBudsDeviceAppNavigation): @{@"name": NSLocalizedString(@"LocKey.AppNavigation", @"Navigation"), @"icon": @"location"},
        @(AIBudsDeviceAppClock): @{@"name": NSLocalizedString(@"LocKey.AppClock", @"Clock"), @"icon": @"clock"},
        @(AIBudsDeviceAppTranslation): @{@"name": NSLocalizedString(@"LocKey.AppTranslation", @"Translation"), @"icon": @"globe"}
    };
}

- (void)fetchDeviceApps {
    [self showLoading:YES];
    
    id<AIBudsDeviceAppsAPI> appsAPI = (id<AIBudsDeviceAppsAPI>)self.device;
    
    if (!appsAPI) {
        [self showLoading:NO];
        [self showStatus:NSLocalizedString(@"LocKey.DeviceAppsNotSupported", @"Device Apps API not supported") error:YES];
        return;
    }
    
    NSArray *apps = appsAPI.deviceApps;
    
    if (apps && apps.count > 0) {
        self.deviceApps = apps;
        [self.appsTableView reloadData];
        [self showStatus:[NSString stringWithFormat:NSLocalizedString(@"LocKey.DeviceAppsLoadedFormat", @"Loaded %ld apps"), (long)apps.count] error:NO];
    } else {
        self.deviceApps = @[];
        [self showStatus:NSLocalizedString(@"LocKey.DeviceAppsEmpty", @"No apps found on device") error:NO];
    }
    
    [self showLoading:NO];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    [self createScrollView];
    [self createHeaderCard];
    [self createAppsListCard];
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
        [self.contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor]
    ]];
}

- (void)createHeaderCard {
    self.headerCard = [[UIView alloc] init];
    self.headerCard.backgroundColor = [UIColor systemBackgroundColor];
    self.headerCard.layer.cornerRadius = 16;
    self.headerCard.layer.shadowColor = [UIColor blackColor].CGColor;
    self.headerCard.layer.shadowOpacity = 0.1;
    self.headerCard.layer.shadowOffset = CGSizeMake(0, 4);
    self.headerCard.layer.shadowRadius = 8;
    [self.contentView addSubview:self.headerCard];
    [self.headerCard setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.headerCard.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:20],
        [self.headerCard.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.headerCard.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20]
    ]];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.DeviceAppsTitle", @"Device Apps");
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    [self.headerCard addSubview:titleLabel];
    [titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.headerCard.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.headerCard.leadingAnchor constant:20]
    ]];
    
    UIImageView *refreshIcon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"arrow.clockwise"]];
    refreshIcon.tintColor = [UIColor systemBlueColor];
    refreshIcon.contentMode = UIViewContentModeScaleAspectFit;
    refreshIcon.userInteractionEnabled = YES;
    UITapGestureRecognizer *refreshTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshButtonTapped)];
    [refreshIcon addGestureRecognizer:refreshTap];
    [self.headerCard addSubview:refreshIcon];
    [refreshIcon setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [refreshIcon.centerYAnchor constraintEqualToAnchor:titleLabel.centerYAnchor],
        [refreshIcon.trailingAnchor constraintEqualToAnchor:self.headerCard.trailingAnchor constant:-20],
        [refreshIcon.widthAnchor constraintEqualToConstant:24],
        [refreshIcon.heightAnchor constraintEqualToConstant:24]
    ]];
    
    UILabel *foregroundTitleLabel = [[UILabel alloc] init];
    foregroundTitleLabel.text = NSLocalizedString(@"LocKey.DeviceAppsForeground", @"Current Foreground App");
    foregroundTitleLabel.font = [UIFont systemFontOfSize:14];
    foregroundTitleLabel.textColor = [UIColor secondaryLabelColor];
    [self.headerCard addSubview:foregroundTitleLabel];
    [foregroundTitleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [foregroundTitleLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:16],
        [foregroundTitleLabel.leadingAnchor constraintEqualToAnchor:self.headerCard.leadingAnchor constant:20]
    ]];
    
    UIView *foregroundBadge = [[UIView alloc] init];
    foregroundBadge.backgroundColor = [UIColor systemGray5Color];
    foregroundBadge.layer.cornerRadius = 8;
    [self.headerCard addSubview:foregroundBadge];
    [foregroundBadge setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [foregroundBadge.topAnchor constraintEqualToAnchor:foregroundTitleLabel.bottomAnchor constant:8],
        [foregroundBadge.leadingAnchor constraintEqualToAnchor:self.headerCard.leadingAnchor constant:20],
        [foregroundBadge.trailingAnchor constraintEqualToAnchor:self.headerCard.trailingAnchor constant:-20],
        [foregroundBadge.bottomAnchor constraintEqualToAnchor:self.headerCard.bottomAnchor constant:-20],
        [foregroundBadge.heightAnchor constraintEqualToConstant:44]
    ]];
    
    self.foregroundAppLabel = [[UILabel alloc] init];
    self.foregroundAppLabel.text = NSLocalizedString(@"LocKey.DeviceAppsHomeScreen", @"Home Screen");
    self.foregroundAppLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.foregroundAppLabel.textColor = [UIColor labelColor];
    [foregroundBadge addSubview:self.foregroundAppLabel];
    [self.foregroundAppLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.foregroundAppLabel.centerYAnchor constraintEqualToAnchor:foregroundBadge.centerYAnchor],
        [self.foregroundAppLabel.leadingAnchor constraintEqualToAnchor:foregroundBadge.leadingAnchor constant:12]
    ]];
    
    UIImageView *homeIcon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"house.fill"]];
    homeIcon.tintColor = [UIColor systemBlueColor];
    homeIcon.contentMode = UIViewContentModeScaleAspectFit;
    [foregroundBadge addSubview:homeIcon];
    [homeIcon setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [homeIcon.centerYAnchor constraintEqualToAnchor:foregroundBadge.centerYAnchor],
        [homeIcon.trailingAnchor constraintEqualToAnchor:foregroundBadge.trailingAnchor constant:-12],
        [homeIcon.widthAnchor constraintEqualToConstant:20],
        [homeIcon.heightAnchor constraintEqualToConstant:20]
    ]];
}

- (void)createAppsListCard {
    self.appsListCard = [[UIView alloc] init];
    self.appsListCard.backgroundColor = [UIColor systemBackgroundColor];
    self.appsListCard.layer.cornerRadius = 16;
    self.appsListCard.layer.shadowColor = [UIColor blackColor].CGColor;
    self.appsListCard.layer.shadowOpacity = 0.1;
    self.appsListCard.layer.shadowOffset = CGSizeMake(0, 4);
    self.appsListCard.layer.shadowRadius = 8;
    [self.contentView addSubview:self.appsListCard];
    [self.appsListCard setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.appsListCard.topAnchor constraintEqualToAnchor:self.headerCard.bottomAnchor constant:20],
        [self.appsListCard.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.appsListCard.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20]
    ]];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.DeviceAppsList", @"Installed Apps");
    titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    [self.appsListCard addSubview:titleLabel];
    [titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.appsListCard.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.appsListCard.leadingAnchor constant:20]
    ]];
    
    self.appsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.appsTableView.delegate = self;
    self.appsTableView.dataSource = self;
    self.appsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.appsTableView.scrollEnabled = NO;
    self.appsTableView.layer.cornerRadius = 10;
    [self.appsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"AppCell"];
    [self.appsListCard addSubview:self.appsTableView];
    [self.appsTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.appsTableView.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:12],
        [self.appsTableView.leadingAnchor constraintEqualToAnchor:self.appsListCard.leadingAnchor constant:12],
        [self.appsTableView.trailingAnchor constraintEqualToAnchor:self.appsListCard.trailingAnchor constant:-12],
        [self.appsTableView.bottomAnchor constraintEqualToAnchor:self.appsListCard.bottomAnchor constant:-16],
        [self.appsTableView.heightAnchor constraintEqualToConstant:280]
    ]];
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
        [self.controlCard.topAnchor constraintEqualToAnchor:self.appsListCard.bottomAnchor constant:20],
        [self.controlCard.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.controlCard.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20]
    ]];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.DeviceAppsActions", @"Quick Actions");
    titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    [self.controlCard addSubview:titleLabel];
    [titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.controlCard.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.controlCard.leadingAnchor constant:20]
    ]];
    
    self.homeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.homeButton setTitle:NSLocalizedString(@"LocKey.DeviceAppsReturnHome", @"Return to Home Screen") forState:UIControlStateNormal];
    [self.homeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.homeButton setBackgroundColor:[UIColor systemRedColor]];
    self.homeButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.homeButton.layer.cornerRadius = 10;
    [self.homeButton addTarget:self action:@selector(returnToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
    [self.controlCard addSubview:self.homeButton];
    [self.homeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.homeButton.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:16],
        [self.homeButton.leadingAnchor constraintEqualToAnchor:self.controlCard.leadingAnchor constant:20],
        [self.homeButton.trailingAnchor constraintEqualToAnchor:self.controlCard.trailingAnchor constant:-20],
        [self.homeButton.heightAnchor constraintEqualToConstant:50],
        [self.homeButton.bottomAnchor constraintEqualToAnchor:self.controlCard.bottomAnchor constant:-20]
    ]];
    
    UIImageView *homeIcon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"house.fill"]];
    homeIcon.tintColor = [UIColor whiteColor];
    homeIcon.contentMode = UIViewContentModeScaleAspectFit;
    [self.homeButton addSubview:homeIcon];
    [homeIcon setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [homeIcon.centerYAnchor constraintEqualToAnchor:self.homeButton.centerYAnchor],
        [homeIcon.leadingAnchor constraintEqualToAnchor:self.homeButton.leadingAnchor constant:20],
        [homeIcon.widthAnchor constraintEqualToConstant:20],
        [homeIcon.heightAnchor constraintEqualToConstant:20]
    ]];
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
    titleLabel.text = NSLocalizedString(@"LocKey.DeviceAppsStatus", @"Status");
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
    self.statusLabel.text = NSLocalizedString(@"LocKey.DeviceAppsReady", @"Ready to manage device apps");
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
        [bottomSpacer.heightAnchor constraintEqualToConstant:20]
    ]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceApps ? self.deviceApps.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppCell" forIndexPath:indexPath];
    
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    NSNumber *appType = self.deviceApps[indexPath.row];
    NSDictionary *appInfo = self.appInfoMapping[appType];
    NSString *appName = appInfo[@"name"] ?: NSLocalizedString(@"LocKey.DeviceAppsUnknownApp", @"Unknown App");
    NSString *appIcon = appInfo[@"icon"] ?: @"app";
    BOOL isRunning = [self.runningApps containsObject:appType];
    
    UIView *cardView = [[UIView alloc] init];
    cardView.backgroundColor = [UIColor systemGray6Color];
    cardView.layer.cornerRadius = 10;
    [cell.contentView addSubview:cardView];
    [cardView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [cardView.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:4],
        [cardView.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor],
        [cardView.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor],
        [cardView.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-4]
    ]];
    
    UIView *iconContainer = [[UIView alloc] init];
    iconContainer.backgroundColor = isRunning ? [UIColor systemBlueColor] : [UIColor systemGray4Color];
    iconContainer.layer.cornerRadius = 20;
    [cardView addSubview:iconContainer];
    [iconContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [iconContainer.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:12],
        [iconContainer.centerYAnchor constraintEqualToAnchor:cardView.centerYAnchor],
        [iconContainer.widthAnchor constraintEqualToConstant:40],
        [iconContainer.heightAnchor constraintEqualToConstant:40]
    ]];
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:appIcon]];
    iconView.tintColor = [UIColor whiteColor];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    [iconContainer addSubview:iconView];
    [iconView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [iconView.centerXAnchor constraintEqualToAnchor:iconContainer.centerXAnchor],
        [iconView.centerYAnchor constraintEqualToAnchor:iconContainer.centerYAnchor],
        [iconView.widthAnchor constraintEqualToConstant:20],
        [iconView.heightAnchor constraintEqualToConstant:20]
    ]];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = appName;
    nameLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    nameLabel.textColor = [UIColor labelColor];
    [cardView addSubview:nameLabel];
    [nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [nameLabel.leadingAnchor constraintEqualToAnchor:iconContainer.trailingAnchor constant:12],
        [nameLabel.centerYAnchor constraintEqualToAnchor:cardView.centerYAnchor]
    ]];
    
    UILabel *statusLabel = [[UILabel alloc] init];
    statusLabel.text = isRunning ? NSLocalizedString(@"LocKey.DeviceAppsRunning", @"Running") : NSLocalizedString(@"LocKey.DeviceAppsStopped", @"Stopped");
    statusLabel.font = [UIFont systemFontOfSize:12];
    statusLabel.textColor = isRunning ? [UIColor systemGreenColor] : [UIColor secondaryLabelColor];
    [cardView addSubview:statusLabel];
    [statusLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [statusLabel.leadingAnchor constraintEqualToAnchor:iconContainer.trailingAnchor constant:12],
        [statusLabel.topAnchor constraintEqualToAnchor:nameLabel.bottomAnchor constant:2]
    ]];
    
    UIStackView *buttonStack = [[UIStackView alloc] init];
    buttonStack.axis = UILayoutConstraintAxisHorizontal;
    buttonStack.spacing = 8;
    [cardView addSubview:buttonStack];
    [buttonStack setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [buttonStack.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-12],
        [buttonStack.centerYAnchor constraintEqualToAnchor:cardView.centerYAnchor]
    ]];
    
    if (isRunning) {
        UIButton *stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [stopButton setTitle:NSLocalizedString(@"LocKey.DeviceAppsStop", @"Stop") forState:UIControlStateNormal];
        [stopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [stopButton setBackgroundColor:[UIColor systemRedColor]];
        stopButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        stopButton.layer.cornerRadius = 6;
        stopButton.tag = indexPath.row;
        [stopButton addTarget:self action:@selector(stopAppButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [buttonStack addArrangedSubview:stopButton];
        [NSLayoutConstraint activateConstraints:@[
            [stopButton.widthAnchor constraintEqualToConstant:60],
            [stopButton.heightAnchor constraintEqualToConstant:32]
        ]];
    } else {
        UIButton *startButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [startButton setTitle:NSLocalizedString(@"LocKey.DeviceAppsStart", @"Start") forState:UIControlStateNormal];
        [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [startButton setBackgroundColor:[UIColor systemBlueColor]];
        startButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        startButton.layer.cornerRadius = 6;
        startButton.tag = indexPath.row;
        [startButton addTarget:self action:@selector(startAppButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [buttonStack addArrangedSubview:startButton];
        [NSLayoutConstraint activateConstraints:@[
            [startButton.widthAnchor constraintEqualToConstant:60],
            [startButton.heightAnchor constraintEqualToConstant:32]
        ]];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

#pragma mark - Actions

- (void)refreshButtonTapped {
    [self fetchDeviceApps];
    [self refreshForegroundApp];
}

- (void)startAppButtonTapped:(UIButton *)sender {
    NSInteger index = sender.tag;
    if (index >= self.deviceApps.count) return;
    
    NSNumber *appType = self.deviceApps[index];
    NSDictionary *appInfo = self.appInfoMapping[appType];
    NSString *appName = appInfo[@"name"] ?: NSLocalizedString(@"LocKey.DeviceAppsUnknownApp", @"Unknown App");
    
    [self showLoading:YES];
    
    id<AIBudsDeviceAppsAPI> appsAPI = (id<AIBudsDeviceAppsAPI>)self.device;
    
    if (!appsAPI) {
        [self showLoading:NO];
        [self showStatus:NSLocalizedString(@"LocKey.DeviceAppsNotSupported", @"Device Apps API not supported") error:YES];
        return;
    }
    
    AIBudsDeviceApp app = (AIBudsDeviceApp)[appType integerValue];
    
    __weak typeof(self) weakSelf = self;
    [appsAPI startApp:app completion:^(BOOL success, NSNumber *statusCode, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showLoading:NO];
            if (success) {
                [weakSelf.runningApps addObject:appType];
                weakSelf.currentForegroundApp = [appType integerValue];
                [weakSelf.appsTableView reloadData];
                [weakSelf updateForegroundLabel];
                [weakSelf showStatus:[NSString stringWithFormat:NSLocalizedString(@"LocKey.DeviceAppsStartedSuccessFormat", @"%@ started successfully"), appName] error:NO];
            } else {
                [weakSelf showStatus:[NSString stringWithFormat:NSLocalizedString(@"LocKey.DeviceAppsStartFailedFormat", @"Failed to start app: %@"), error.localizedDescription] error:YES];
            }
        });
    }];
}

- (void)stopAppButtonTapped:(UIButton *)sender {
    NSInteger index = sender.tag;
    if (index >= self.deviceApps.count) return;
    
    NSNumber *appType = self.deviceApps[index];
    NSDictionary *appInfo = self.appInfoMapping[appType];
    NSString *appName = appInfo[@"name"] ?: NSLocalizedString(@"LocKey.DeviceAppsUnknownApp", @"Unknown App");
    
    [self showLoading:YES];
    
    id<AIBudsDeviceAppsAPI> appsAPI = (id<AIBudsDeviceAppsAPI>)self.device;
    
    if (!appsAPI) {
        [self showLoading:NO];
        [self showStatus:NSLocalizedString(@"LocKey.DeviceAppsNotSupported", @"Device Apps API not supported") error:YES];
        return;
    }
    
    AIBudsDeviceApp app = (AIBudsDeviceApp)[appType integerValue];
    
    __weak typeof(self) weakSelf = self;
    [appsAPI stopApp:app completion:^(BOOL success, NSNumber *statusCode, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showLoading:NO];
            if (success) {
                [weakSelf.runningApps removeObject:appType];
                if (weakSelf.currentForegroundApp == [appType integerValue]) {
                    weakSelf.currentForegroundApp = 0;
                }
                [weakSelf.appsTableView reloadData];
                [weakSelf updateForegroundLabel];
                [weakSelf showStatus:[NSString stringWithFormat:NSLocalizedString(@"LocKey.DeviceAppsStoppedSuccessFormat", @"%@ stopped successfully"), appName] error:NO];
            } else {
                [weakSelf showStatus:[NSString stringWithFormat:NSLocalizedString(@"LocKey.DeviceAppsStopFailedFormat", @"Failed to stop app: %@"), error.localizedDescription] error:YES];
            }
        });
    }];
}

- (void)returnToHomeScreen {
    [self showLoading:YES];
    
    id<AIBudsDeviceAppsAPI> appsAPI = (id<AIBudsDeviceAppsAPI>)self.device;
    
    if (!appsAPI) {
        [self showLoading:NO];
        [self showStatus:NSLocalizedString(@"LocKey.DeviceAppsNotSupported", @"Device Apps API not supported") error:YES];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [appsAPI stopAllAppsAndReturnToHomeScreenWithCompletion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showLoading:NO];
            if (success) {
                [weakSelf.runningApps removeAllObjects];
                weakSelf.currentForegroundApp = 0;
                [weakSelf.appsTableView reloadData];
                [weakSelf updateForegroundLabel];
                [weakSelf showStatus:NSLocalizedString(@"LocKey.DeviceAppsHomeSuccess", @"Returned to home screen successfully") error:NO];
            } else {
                [weakSelf showStatus:[NSString stringWithFormat:NSLocalizedString(@"LocKey.DeviceAppsHomeFailedFormat", @"Failed to return to home: %@"), error.localizedDescription] error:YES];
            }
        });
    }];
}

- (void)refreshForegroundApp {
    id<AIBudsDeviceAppsAPI> appsAPI = (id<AIBudsDeviceAppsAPI>)self.device;
    
    if (!appsAPI) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [appsAPI getCurrentForegroundAppWithCompletion:^(BOOL success, NSNumber *app, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                if (app) {
                    weakSelf.currentForegroundApp = [app integerValue];
                    if ([app integerValue] == 0) {
                        [weakSelf.runningApps removeAllObjects];
                    } else {
                        [weakSelf.runningApps addObject:app];
                    }
                    [weakSelf.appsTableView reloadData];
                }
                [weakSelf updateForegroundLabel];
            }
        });
    }];
}

- (void)updateForegroundLabel {
    NSString *foregroundText = NSLocalizedString(@"LocKey.DeviceAppsHomeScreen", @"Home Screen");
    
    if (self.currentForegroundApp > 0) {
        NSDictionary *appInfo = self.appInfoMapping[@(self.currentForegroundApp)];
        if (appInfo) {
            foregroundText = appInfo[@"name"];
        }
    }
    
    self.foregroundAppLabel.text = foregroundText;
}

- (void)showLoading:(BOOL)loading {
    if (loading) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
}

- (void)showStatus:(NSString *)status error:(BOOL)isError {
    self.statusLabel.text = status;
    self.statusLabel.textColor = isError ? [UIColor systemRedColor] : [UIColor secondaryLabelColor];
}

@end
