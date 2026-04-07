//
//  DeviceInfoDetailsController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-06.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "DeviceInfoDetailsController.h"
#import "DeviceInfoItemModel.h"

@interface DeviceInfoDetailsController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<DeviceInfoItemModel *> *deviceInfoItems;
@property (nonatomic, strong) NSMutableSet<NSNumber *> *expandedIndexPaths;

@end

@implementation DeviceInfoDetailsController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupDeviceInfoItems];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"LocKey.DeviceDetails", comment:@"Device Details");
    
    // Table View
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
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
    
    // Initialize expanded index paths
    self.expandedIndexPaths = [NSMutableSet new];
}

- (void)setupDeviceInfoItems {
    self.deviceInfoItems = [NSMutableArray new];
    
    if (!self.device) {
        return;
    }
    
    // Basic Information
    [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.DeviceThumbnail", comment:@"Device Thumbnail") detailsInfo:@"" isComplex:NO icon:self.device.thumbnail isIcon:YES]];
    [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.DeviceName", comment:@"Device Name") detailsInfo:self.device.name isComplex:NO]];
    [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.UUID", comment:@"UUID") detailsInfo:self.device.uuid.UUIDString isComplex:NO]];
    [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.BluetoothName", comment:@"Bluetooth Name") detailsInfo:self.device.bluetoothName ?: NSLocalizedString(@"LocKey.NA", comment:@"N/A") isComplex:NO]];
    [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.MACAddress", comment:@"MAC Address") detailsInfo:self.device.macAddress ?: NSLocalizedString(@"LocKey.NA", comment:@"N/A") isComplex:NO]];
    [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.ProductType", comment:@"Product Type") detailsInfo:[self productTypeString] isComplex:NO]];
    
    // Device Information
    [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.DeviceModel", comment:@"Device Model") detailsInfo:self.device.deviceModel ?: NSLocalizedString(@"LocKey.NA", comment:@"N/A") isComplex:NO]];
    [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.SerialNumber", comment:@"Serial Number") detailsInfo:self.device.deviceSerialNum ?: NSLocalizedString(@"LocKey.NA", comment:@"N/A") isComplex:NO]];
    [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.FirmwareVersion", comment:@"Firmware Version") detailsInfo:self.device.formatedFirmwareVersion ?: NSLocalizedString(@"LocKey.NA", comment:@"N/A") isComplex:NO]];
    [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.CoProcessorFirmwareVersion", comment:@"Co-processor Firmware Version") detailsInfo:self.device.coProcessorFirmwareVersion ?: NSLocalizedString(@"LocKey.NA", comment:@"N/A") isComplex:NO]];
    [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.ProjectNumber", comment:@"Project Number") detailsInfo:self.device.formatedProjNumber ?: NSLocalizedString(@"LocKey.NA", comment:@"N/A") isComplex:NO]];
    id<AIBudsDeviceInfoAPI> device = (id<AIBudsDeviceInfoAPI>)self.device;
    if([device conformsToProtocol:@protocol(AIBudsDeviceInfoAPI)]) {
        // 电池状态信息
        NSString* batteryInfo = [NSString stringWithFormat:@"%@", device.batteryStatusInfo];
        [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.BatteryStatus", comment:@"Battery Status") detailsInfo:batteryInfo isComplex:YES]];
        
        // 设备语言设置
        NSString *languageString = [self languageStringFromDeviceLanguage:device.languageSetting];
        [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.LanguageSetting", comment:@"Language Setting") detailsInfo:languageString isComplex:NO]];
        
        // 支持的语言列表
        if (device.supportedLanguages.count > 0) {
            NSMutableString *supportedLangs = [NSMutableString string];
            for (NSNumber *langNum in device.supportedLanguages) {
                AIBudsDeviceLanguage lang = (AIBudsDeviceLanguage)[langNum integerValue];
                if (supportedLangs.length > 0) {
                    [supportedLangs appendString:@", "];
                }
                [supportedLangs appendString:[self languageStringFromDeviceLanguage:lang]];
            }
            [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.SupportedLanguages", comment:@"Supported Languages") detailsInfo:supportedLangs isComplex:YES]];
        }
        
        // 当前通话状态
        NSString *callStatusString = [self callStatusString:device.callStatus];
        [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.CallStatus", comment:@"Call Status") detailsInfo:callStatusString isComplex:NO]];
        
        // 设备存储信息
        NSString* storageString = [NSString stringWithFormat:@"%@", device.storageInfo.description];
        [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.StorageInfo", comment:@"Storage Info") detailsInfo:storageString isComplex:YES]];
        
        // 媒体文件计数信息
        NSString *mediaInfo = [NSString stringWithFormat:@"%@", device.mediaCountInfo.description];
        [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.MediaCount", comment:@"Media Count") detailsInfo:mediaInfo isComplex:YES]];
        
        // 是否支持调整录制时长
        NSString *supportRecordDuration = device.isSupportAdjustRecordDuration ? NSLocalizedString(@"LocKey.Yes", comment:@"Yes") : NSLocalizedString(@"LocKey.No", comment:@"No");
        [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.SupportAdjustRecordDuration", comment:@"Support Adjust Record Duration") detailsInfo:supportRecordDuration isComplex:NO]];
    }
    
    // Connection Information
    [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.LastConnectTime", comment:@"Last Connect Time") detailsInfo:[self formatDate:self.device.lastConnectTime] isComplex:NO]];
    [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.BindUserID", comment:@"Bind User ID") detailsInfo:self.device.bindUserId ? [NSString stringWithFormat:@"%@", self.device.bindUserId] : NSLocalizedString(@"LocKey.NA", comment:@"N/A") isComplex:NO]];
    [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.UserBindTime", comment:@"User Bind Time") detailsInfo:[self formatDate:self.device.userBindTime] isComplex:NO]];
    [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.AutoReconnect", comment:@"Auto Reconnect") detailsInfo:self.device.shouldAutoReconnectWhenAppLaunch ? NSLocalizedString(@"LocKey.Yes", comment:@"Yes") : NSLocalizedString(@"LocKey.No", comment:@"No") isComplex:NO]];
    
    // Advertisement Information
    [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.AdvertisementData", comment:@"Advertisement Data") detailsInfo:self.device.advertisementDataString ?: NSLocalizedString(@"LocKey.NA", comment:@"N/A") isComplex:YES]];
    [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.ManufacturerData", comment:@"Manufacturer Data") detailsInfo:self.device.manufacturerHexDataString ?: NSLocalizedString(@"LocKey.NA", comment:@"N/A") isComplex:YES]];
    [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.AdvertisementTimestamp", comment:@"Advertisement Timestamp") detailsInfo:[self formatDate:self.device.timestampOfAdvertisementData] isComplex:NO]];
    
    // Additional Information
    [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.ScreenName", comment:@"Screen Name") detailsInfo:self.device.screenName ?: NSLocalizedString(@"LocKey.NA", comment:@"N/A") isComplex:NO]];
    [self.deviceInfoItems addObject:[DeviceInfoItemModel modelWithName:NSLocalizedString(@"LocKey.CustomContent", comment:@"Custom Content") detailsInfo:self.device.customContent ?: NSLocalizedString(@"LocKey.NA", comment:@"N/A") isComplex:YES]];

}

- (NSString *)callStatusString:(AIBudsCallStatus)callStatus {
    switch (callStatus) {
        case AIBudsCallStatusUnknown:
            return NSLocalizedString(@"LocKey.Unknown", comment:@"Unknown");
        case AIBudsCallStatusNotInCall:
            return NSLocalizedString(@"LocKey.NotInCall", comment:@"Not in call");
        case AIBudsCallStatusRinging:
            return NSLocalizedString(@"LocKey.Ringing", comment:@"Ringing");
        case AIBudsCallStatusInCall:
            return NSLocalizedString(@"LocKey.InCall", comment:@"In call");
        case AIBudsCallStatusThreeWayRinging:
            return NSLocalizedString(@"LocKey.ThreeWayRinging", comment:@"Three way ringing");
        case AIBudsCallStatusAiChat:
            return NSLocalizedString(@"LocKey.AIChat", comment:@"AI Chat");
        default:
            return NSLocalizedString(@"LocKey.Unknown", comment:@"Unknown");
    }
}

- (NSString *)languageStringFromDeviceLanguage:(AIBudsDeviceLanguage)language {
    switch (language) {
        case AIBudsDeviceLanguageUnknown:
            return NSLocalizedString(@"LocKey.Unknown", comment:@"Unknown");
        case AIBudsDeviceLanguageEnglish:
            return NSLocalizedString(@"LocKey.English", comment:@"English");
        case AIBudsDeviceLanguageSimplifiedChinese:
            return NSLocalizedString(@"LocKey.SimplifiedChinese", comment:@"Simplified Chinese");
        case AIBudsDeviceLanguageFrench:
            return NSLocalizedString(@"LocKey.French", comment:@"French");
        case AIBudsDeviceLanguageTraditionalChineseHK:
            return NSLocalizedString(@"LocKey.TraditionalChineseHK", comment:@"Traditional Chinese (Hong Kong)");
        case AIBudsDeviceLanguageGerman:
            return NSLocalizedString(@"LocKey.German", comment:@"German");
        case AIBudsDeviceLanguageRussian:
            return NSLocalizedString(@"LocKey.Russian", comment:@"Russian");
        case AIBudsDeviceLanguageSpanish:
            return NSLocalizedString(@"LocKey.Spanish", comment:@"Spanish");
        case AIBudsDeviceLanguagePortuguese:
            return NSLocalizedString(@"LocKey.Portuguese", comment:@"Portuguese");
        case AIBudsDeviceLanguageJapanese:
            return NSLocalizedString(@"LocKey.Japanese", comment:@"Japanese");
        case AIBudsDeviceLanguageArabic:
            return NSLocalizedString(@"LocKey.Arabic", comment:@"Arabic");
        case AIBudsDeviceLanguageDutch:
            return NSLocalizedString(@"LocKey.Dutch", comment:@"Dutch");
        case AIBudsDeviceLanguageItalian:
            return NSLocalizedString(@"LocKey.Italian", comment:@"Italian");
        case AIBudsDeviceLanguageCzech:
            return NSLocalizedString(@"LocKey.Czech", comment:@"Czech");
        case AIBudsDeviceLanguageDanish:
            return NSLocalizedString(@"LocKey.Danish", comment:@"Danish");
        case AIBudsDeviceLanguageGreek:
            return NSLocalizedString(@"LocKey.Greek", comment:@"Greek");
        case AIBudsDeviceLanguageHebrew:
            return NSLocalizedString(@"LocKey.Hebrew", comment:@"Hebrew");
        case AIBudsDeviceLanguageHindi:
            return NSLocalizedString(@"LocKey.Hindi", comment:@"Hindi");
        case AIBudsDeviceLanguageHungarian:
            return NSLocalizedString(@"LocKey.Hungarian", comment:@"Hungarian");
        case AIBudsDeviceLanguageIndonesian:
            return NSLocalizedString(@"LocKey.Indonesian", comment:@"Indonesian");
        case AIBudsDeviceLanguageKorean:
            return NSLocalizedString(@"LocKey.Korean", comment:@"Korean");
        case AIBudsDeviceLanguageMalay:
            return NSLocalizedString(@"LocKey.Malay", comment:@"Malay");
        case AIBudsDeviceLanguagePolish:
            return NSLocalizedString(@"LocKey.Polish", comment:@"Polish");
        case AIBudsDeviceLanguagePersian:
            return NSLocalizedString(@"LocKey.Persian", comment:@"Persian");
        case AIBudsDeviceLanguageSwedish:
            return NSLocalizedString(@"LocKey.Swedish", comment:@"Swedish");
        case AIBudsDeviceLanguageThai:
            return NSLocalizedString(@"LocKey.Thai", comment:@"Thai");
        case AIBudsDeviceLanguageVietnamese:
            return NSLocalizedString(@"LocKey.Vietnamese", comment:@"Vietnamese");
        case AIBudsDeviceLanguageSlovak:
            return NSLocalizedString(@"LocKey.Slovak", comment:@"Slovak");
        case AIBudsDeviceLanguageFinnish:
            return NSLocalizedString(@"LocKey.Finnish", comment:@"Finnish");
        case AIBudsDeviceLanguageIrish:
            return NSLocalizedString(@"LocKey.Irish", comment:@"Irish");
        case AIBudsDeviceLanguageRomanian:
            return NSLocalizedString(@"LocKey.Romanian", comment:@"Romanian");
        case AIBudsDeviceLanguageTurkish:
            return NSLocalizedString(@"LocKey.Turkish", comment:@"Turkish");
        case AIBudsDeviceLanguageCroatian:
            return NSLocalizedString(@"LocKey.Croatian", comment:@"Croatian");
        case AIBudsDeviceLanguageAlbanian:
            return NSLocalizedString(@"LocKey.Albanian", comment:@"Albanian");
        case AIBudsDeviceLanguageUkrainian:
            return NSLocalizedString(@"LocKey.Ukrainian", comment:@"Ukrainian");
        case AIBudsDeviceLanguageBulgarian:
            return NSLocalizedString(@"LocKey.Bulgarian", comment:@"Bulgarian");
        case AIBudsDeviceLanguageSlovenian:
            return NSLocalizedString(@"LocKey.Slovenian", comment:@"Slovenian");
        default:
            return NSLocalizedString(@"LocKey.Unknown", comment:@"Unknown");
    }
}

- (NSString *)productTypeString {
    switch (self.device.product) {
        case AIBudsDeviceProductUnknown:
            return NSLocalizedString(@"LocKey.Unknown", comment:@"Unknown");
        case AIBudsDeviceProductWatch:
            return NSLocalizedString(@"LocKey.SmartWatch", comment:@"Smart Watch");
        case AIBudsDeviceProductRing:
            return NSLocalizedString(@"LocKey.SmartRing", comment:@"Smart Ring");
        case AIBudsDeviceProductGlasses:
            return NSLocalizedString(@"LocKey.SmartGlasses", comment:@"Smart Glasses");
        case AIBudsDeviceProductChargingCase:
            return NSLocalizedString(@"LocKey.ChargingCase", comment:@"Charging Case");
        case AIBudsDeviceProductEarbuds:
            return NSLocalizedString(@"LocKey.Earbuds", comment:@"Earbuds");
        case AIBudsDeviceProductSpeaker:
            return NSLocalizedString(@"LocKey.SmartSpeaker", comment:@"Smart Speaker");
        default:
            return NSLocalizedString(@"LocKey.Unknown", comment:@"Unknown");
    }
}

- (NSString *)formatDate:(NSDate *)date {
    if (!date) {
        return NSLocalizedString(@"LocKey.NA", comment:@"N/A");
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterMediumStyle;
    return [formatter stringFromDate:date];
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceInfoItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"DeviceInfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    DeviceInfoItemModel *item = self.deviceInfoItems[indexPath.row];
    cell.textLabel.text = item.name;
    
    if (item.isComplex) {
        cell.detailTextLabel.text = NSLocalizedString(@"LocKey.TapToViewDetails", comment:@"Tap to view details");
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        cell.detailTextLabel.text = item.detailsInfo;
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if(item.isIcon){
        UIImageView *iconView = [[UIImageView alloc] initWithImage:item.icon];
        iconView.frame = CGRectMake(0, 0, 24, 24);
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        cell.accessoryView = iconView;
    }
    else {
        cell.accessoryView = nil;
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DeviceInfoItemModel *item = self.deviceInfoItems[indexPath.row];
    if (item.isComplex) {
        // Toggle expanded state
        NSNumber *indexPathNumber = [NSNumber numberWithInteger:indexPath.row];
        if ([self.expandedIndexPaths containsObject:indexPathNumber]) {
            [self.expandedIndexPaths removeObject:indexPathNumber];
        } else {
            [self.expandedIndexPaths addObject:indexPathNumber];
        }
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceInfoItemModel *item = self.deviceInfoItems[indexPath.row];
    NSNumber *indexPathNumber = [NSNumber numberWithInteger:indexPath.row];
    
    if (item.isComplex && [self.expandedIndexPaths containsObject:indexPathNumber]) {
        return 200.0;
    }
    
    return 44.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceInfoItemModel *item = self.deviceInfoItems[indexPath.row];
    NSNumber *indexPathNumber = [NSNumber numberWithInteger:indexPath.row];
    
    if (item.isComplex && [self.expandedIndexPaths containsObject:indexPathNumber]) {
        // Remove any existing subviews
        for (UIView *subview in cell.contentView.subviews) {
            if ([subview isKindOfClass:[UITextView class]]) {
                [subview removeFromSuperview];
            }
        }
        
        // Adjust textLabel to top alignment
        cell.textLabel.contentMode = UIViewContentModeTop;
        cell.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [cell.textLabel.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:8],
            [cell.textLabel.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:15],
            [cell.textLabel.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-150],
        ]];
        
        // Hide detailTextLabel
        cell.detailTextLabel.hidden = YES;
        
        // Add text view for complex details
        UITextView *textView = [[UITextView alloc] init];
        textView.text = item.detailsInfo;
        textView.font = [UIFont systemFontOfSize:14];
        textView.editable = NO;
        textView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
        textView.layer.cornerRadius = 8.0;
        textView.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:textView];
        
        [NSLayoutConstraint activateConstraints:@[
            [textView.topAnchor constraintEqualToAnchor:cell.textLabel.bottomAnchor constant:8],
            [textView.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:15],
            [textView.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-15],
            [textView.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-8],
        ]];
    } else {
        // Reset to default layout for non-expanded cells
        cell.textLabel.translatesAutoresizingMaskIntoConstraints = YES;
        cell.detailTextLabel.hidden = NO;
    }
}

@end
