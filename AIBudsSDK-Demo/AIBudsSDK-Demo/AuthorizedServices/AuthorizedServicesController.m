//
//  AuthorizedServicesController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-07.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "AuthorizedServicesController.h"

@interface AuthorizedServicesController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *authorizedServices;

@end

@implementation AuthorizedServicesController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupAuthorizedServices];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor systemGray6Color];
    self.title = NSLocalizedString(@"LocKey.AuthorizedServices", comment:@"Authorized Services");
    
    // Table View with InsetGrouped style
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
    
    // Layout Constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
    ]];
}

- (void)setupAuthorizedServices {
    self.authorizedServices = [NSMutableArray new];
    
    if (!self.device) {
        return;
    }
    
    // Get authorized services from device
    AIBudsAuthorizedServices services = [(id<AIBudsDeviceServiceAuthAPI>)self.device authorizedServices];
    
    // Check each service
    if (services & AIBudsAuthorizedServicesStarBurst) {
        [self.authorizedServices addObject:@{@"name": NSLocalizedString(@"LocKey.StarBurstAI", comment:@"StarBurst AI"), @"type": @(AIBudsServiceAuthTypeStarBurst)}];
    }
    
    if (services & AIBudsAuthorizedServicesOnDeviceVoiceAssistant) {
        [self.authorizedServices addObject:@{@"name": NSLocalizedString(@"LocKey.OnDeviceVoiceAssistant", comment:@"On-device Voice Assistant"), @"type": @(AIBudsServiceAuthTypeOnDeviceVoiceAssistant)}];
    }
}

- (NSString *)serviceStatusForType:(AIBudsServiceAuthType)type {
    // In a real implementation, you might want to check the actual status of each service
    // For this demo, we'll just return "Authorized"
    return NSLocalizedString(@"LocKey.Authorized", comment:@"Authorized");
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.authorizedServices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"AuthorizedServiceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *service = self.authorizedServices[indexPath.row];
    cell.textLabel.text = service[@"name"];
    cell.detailTextLabel.text = [self serviceStatusForType:[service[@"type"] integerValue]];
    cell.detailTextLabel.textColor = [UIColor systemGreenColor];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"LocKey.AuthorizedServicesList", comment:@"Authorized Services List");
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (self.authorizedServices.count == 0) {
        return NSLocalizedString(@"LocKey.NoServicesAuthorizedYet", comment:@"No services authorized yet");
    }
    return NSLocalizedString(@"LocKey.TheseServicesHaveBeenAuthorizedForYourDevice", comment:@"These services have been authorized for your device");
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

@end
