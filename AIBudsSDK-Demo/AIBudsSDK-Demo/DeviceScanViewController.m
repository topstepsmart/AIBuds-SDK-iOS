//
//  DeviceScanViewController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-02-13.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "DeviceScanViewController.h"
@import CoreBluetooth;
@import UIKit;


@interface ScanDeviceItem : NSObject
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *mac;
@property (nonatomic, assign) NSInteger rssi;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, weak) CBCentralManager *central;
@property (nonatomic, strong) NSDictionary<NSString *,id> *advertisementData;
@end

@implementation ScanDeviceItem
@end

@interface ScanDeviceCell : UITableViewCell
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *detailLabel; // MAC + RSSI
@property (nonatomic, strong) UIButton *addButton;
- (void)configureWithItem:(ScanDeviceItem *)item target:(id)target action:(SEL)action;
@end

@implementation ScanDeviceCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        UIView *card = [[UIView alloc] initWithFrame:CGRectZero];
        card.translatesAutoresizingMaskIntoConstraints = NO;
        card.backgroundColor = [UIColor secondarySystemBackgroundColor];
        card.layer.cornerRadius = 12.0;
        card.layer.masksToBounds = YES;
        [self.contentView addSubview:card];

        _iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconView.translatesAutoresizingMaskIntoConstraints = NO;
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        _iconView.tintColor = [UIColor labelColor];

        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _nameLabel.textColor = [UIColor labelColor];

        _detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _detailLabel.textColor = [UIColor secondaryLabelColor];

        _addButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _addButton.translatesAutoresizingMaskIntoConstraints = NO;
     
        UIImage *plusImage = [UIImage systemImageNamed:@"plus" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightSemibold]];
        [_addButton setImage:plusImage forState:UIControlStateNormal];
        _addButton.backgroundColor = [UIColor systemBlueColor];
        _addButton.tintColor = [UIColor whiteColor];
        _addButton.layer.cornerRadius = 18.0;
        _addButton.frame = CGRectMake(0, 0, 36, 36);

        [card addSubview:_iconView];
        [card addSubview:_nameLabel];
        [card addSubview:_detailLabel];
        [card addSubview:_addButton];

        [NSLayoutConstraint activateConstraints:@[
            [card.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:8.0],
            [card.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16.0],
            [card.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16.0],
            [card.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8.0],

            [_iconView.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:12.0],
            [_iconView.centerYAnchor constraintEqualToAnchor:card.centerYAnchor],
            [_iconView.widthAnchor constraintEqualToConstant:36.0],
            [_iconView.heightAnchor constraintEqualToConstant:36.0],

            [_addButton.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-12.0],
            [_addButton.centerYAnchor constraintEqualToAnchor:card.centerYAnchor],
            [_addButton.widthAnchor constraintEqualToConstant:36.0f],
            [_addButton.heightAnchor constraintEqualToAnchor:_addButton.widthAnchor multiplier:1.0f],

            [_nameLabel.leadingAnchor constraintEqualToAnchor:_iconView.trailingAnchor constant:12.0],
            [_nameLabel.trailingAnchor constraintLessThanOrEqualToAnchor:_addButton.leadingAnchor constant:-12.0],
            [_nameLabel.topAnchor constraintEqualToAnchor:card.topAnchor constant:12.0],

            [_detailLabel.leadingAnchor constraintEqualToAnchor:_nameLabel.leadingAnchor],
            [_detailLabel.trailingAnchor constraintLessThanOrEqualToAnchor:_addButton.leadingAnchor constant:-12.0],
            [_detailLabel.topAnchor constraintEqualToAnchor:_nameLabel.bottomAnchor constant:4.0],
            [_detailLabel.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-12.0]
        ]];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.iconView.image = nil;
    self.nameLabel.text = nil;
    self.detailLabel.text = nil;
    [self.addButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureWithItem:(ScanDeviceItem *)item target:(id)target action:(SEL)action {
    self.iconView.image = item.icon;
    self.nameLabel.text = item.name;
    NSString *rssiTitle = NSLocalizedString(@"RSSILocKey", nil);
    self.detailLabel.text = [NSString stringWithFormat:@"%@   %@: %ld", item.mac ?: @"-", rssiTitle, (long)item.rssi];
    [self.addButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}
@end

@interface DeviceScanViewController () <UITableViewDataSource, UITableViewDelegate, CBCentralManagerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<ScanDeviceItem *> *devices;
@property (nonatomic, strong) CBCentralManager *central;
@property (nonatomic, strong) UIView *scanHeaderView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UILabel *scanLabel;
@property (nonatomic, strong) NSTimer *scanTimeoutTimer;
@property (nonatomic, strong) UIButton *refreshButton; // 新增刷新按钮
@end

@implementation DeviceScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.navigationItem.title = NSLocalizedString(@"AddDeviceLocKey", nil);

    self.devices = [NSMutableArray array];

    [self setupScanHeader];
    [self setupTableView];

    self.central = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:@{ CBCentralManagerOptionShowPowerAlertKey : @YES }];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopScanning];
}

- (void)setupScanHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectZero];
    header.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:header];

    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.spinner.translatesAutoresizingMaskIntoConstraints = NO;
    self.spinner.color = [UIColor systemBlueColor];
    [header addSubview:self.spinner];

    self.scanLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.scanLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.scanLabel.text = NSLocalizedString(@"ScanningLocKey", nil);
    self.scanLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.scanLabel.textColor = [UIColor labelColor];
    [header addSubview:self.scanLabel];

    // 创建刷新按钮
    self.refreshButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.refreshButton.translatesAutoresizingMaskIntoConstraints = NO;
    UIImage *refreshImage = [UIImage systemImageNamed:@"arrow.clockwise" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20]];
    [self.refreshButton setImage:refreshImage forState:UIControlStateNormal];
    self.refreshButton.tintColor = [UIColor systemBlueColor];
    [self.refreshButton addTarget:self action:@selector(onRefreshTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.refreshButton.hidden = YES; // 初始隐藏，扫描停止后显示
    [header addSubview:self.refreshButton];

    [NSLayoutConstraint activateConstraints:@[
        [header.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [header.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [header.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [header.heightAnchor constraintEqualToConstant:80.0],

        [self.spinner.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [self.spinner.leadingAnchor constraintEqualToAnchor:header.leadingAnchor constant:16.0],
        [self.scanLabel.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [self.scanLabel.leadingAnchor constraintEqualToAnchor:self.spinner.trailingAnchor constant:12.0],

        // 刷新按钮放在右侧
        [self.refreshButton.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [self.refreshButton.trailingAnchor constraintEqualToAnchor:header.trailingAnchor constant:-16.0]
    ]];

    self.scanHeaderView = header;
}

- (void)setupTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundColor = [UIColor systemBackgroundColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:ScanDeviceCell.class forCellReuseIdentifier:@"ScanDeviceCell"];
    [self.view addSubview:tableView];

    [NSLayoutConstraint activateConstraints:@[
        [tableView.topAnchor constraintEqualToAnchor:self.scanHeaderView.bottomAnchor],
        [tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];

    self.tableView = tableView;
}

- (void)startScanningIfPossible {
    if (self.central.state == CBManagerStatePoweredOn) {
        [self.spinner startAnimating];
        self.refreshButton.hidden = YES; // 开始扫描时隐藏刷新按钮
        self.scanLabel.text = NSLocalizedString(@"ScanningLocKey", nil);
        [self.devices removeAllObjects];
        [self.tableView reloadData];
        /*NSDictionary *options = @{ CBCentralManagerScanOptionAllowDuplicatesKey : @NO };
        [self.central scanForPeripheralsWithServices:nil options:options];
        [self scheduleScanTimeout:10.0];*/
        __weak typeof(self) weakSelf = self;
        [AIBudsSDK startScanningWithTimeout:nil deviceFoundHandler:^(id<AIBudsFoundDeviceConvertible>  _Nonnull device, BOOL isExistingDevice) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf centralManager:device.central didDiscoverPeripheral:device.peripheral advertisementData:device.advertisementData RSSI:device.RSSI];
            });
        } completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf stopScanning];
                weakSelf.scanLabel.text = NSLocalizedString(@"ScanStoppedLocKey", nil);
            });
        }];
    }
}

- (void)stopScanning {
    if ([AIBudsSDK isScanning]) {
        [AIBudsSDK stopScanning];
    }
    [self.spinner stopAnimating];
    [self invalidateScanTimeout];
    // 扫描停止后显示刷新按钮
    self.refreshButton.hidden = NO;
    self.scanLabel.text = NSLocalizedString(@"ScanStoppedLocKey", nil);
}

- (void)scheduleScanTimeout:(NSTimeInterval)timeout {
    [self invalidateScanTimeout];
    __weak typeof(self) weakSelf = self;
    self.scanTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeout repeats:NO block:^(NSTimer * _Nonnull timer) {
        [weakSelf stopScanning];
        weakSelf.scanLabel.text = NSLocalizedString(@"ScanStoppedLocKey", nil);
    }];
}

- (void)invalidateScanTimeout {
    [self.scanTimeoutTimer invalidate];
    self.scanTimeoutTimer = nil;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBManagerStatePoweredOn) {
        [self startScanningIfPossible];
    } else {
        [self stopScanning];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    ScanDeviceItem *item = [ScanDeviceItem new];
    if (@available(iOS 13.0, *)) {
        item.icon = [UIImage systemImageNamed:@"antenna.radiowaves.left.and.right"];
    }
    item.name = peripheral.name ?: NSLocalizedString(@"UnknownDeviceNameLocKey", nil);
    item.mac = [self extractMACAddressFromAdvertisement:advertisementData] ?: @"-";
    item.rssi = RSSI.integerValue;
    item.peripheral = peripheral;
    item.central = central;
    item.advertisementData = advertisementData;
    // Avoid duplicates by UUID
    BOOL exists = NO;
    for (ScanDeviceItem *d in self.devices) {
        if ([d.peripheral.identifier isEqual:peripheral.identifier]) { exists = YES; break; }
    }
    if (!exists) {
        [self.devices addObject:item];
        [self.tableView reloadData];
    }
}

- (NSString *)extractMACAddressFromAdvertisement:(NSDictionary<NSString *, id> *)adv {
    NSData *mData = adv[CBAdvertisementDataManufacturerDataKey];
    if (!mData) { return nil; }
    const uint8_t *bytes = mData.bytes;
    NSUInteger len = mData.length;
    if (len >= 6) {
        // Heuristic: last 6 bytes as MAC
        NSMutableString *mac = [NSMutableString string];
        for (NSInteger i = (NSInteger)len - 6; i < (NSInteger)len; i++) {
            [mac appendFormat:@"%02X", bytes[i]];
            if (i < (NSInteger)len - 1) { [mac appendString:@":"]; }
        }
        return mac.copy;
    }
    return nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ScanDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScanDeviceCell" forIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    [cell configureWithItem:self.devices[indexPath.row] target:weakSelf action:@selector(onAddTapped:)];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 84.0;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions

- (void)onAddTapped:(UIButton *)sender {
    CGPoint p = [sender.superview convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (!indexPath) { return; }
    __weak typeof(self) weakSelf = self;
    ScanDeviceItem *item = self.devices[indexPath.row];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"AddToMyDevicesLocKey", nil) message:item.name preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ConfirmLocKey", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        id<AIBudsDeviceConvertible> device = [AIBudsSDK makeStorableDeviceFromDiscovered:item.peripheral central:item.central advertisement:item.advertisementData rssi:@(item.rssi)];
        if (device) {
            device.screenName = device.name;
            device.thumbnail = [UIImage imageNamed:@"icon.glasses"];
            device.customContent = @"Smart Glasses";
            if([AIBudsStoredDevicesMgr addDevice:device])
            {
                [weakSelf stopScanning];
                [weakSelf.navigationController popViewControllerAnimated:YES];
                return;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showAlertWithTitle:NSLocalizedString(@"AddToMyDevicesFailedLocKey", nil) message:NSLocalizedString(@"AddToMyDevicesFailedMsgLocKey", nil)];
        });
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CancelLocKey", nil) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

// 新增刷新按钮点击事件
- (void)onRefreshTapped:(UIButton *)sender {
    [self startScanningIfPossible];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OKLocKey", nil) style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
