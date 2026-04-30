//
//  DeviceHomeViewController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-03-02.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "DeviceHomeViewController.h"
#import "DeviceFeatureGroupModel.h"
#import "FeatureDemoBaseController.h"
#import "AIChatContext.h"
#import "AIFeatureContext.h"
#import "AIAudioRecordingContext.h"


@interface DeviceHomeViewController () <UITableViewDataSource, UITableViewDelegate, AIBudsDeviceDelegate>

@property (nonatomic, strong) id<AIBudsDeviceConvertible> device;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) DeviceFeatureModel* aiServiceVendorFeature;
@property (nonatomic, strong) DeviceFeatureModel* firmwareVersionFeature;
@property (nonatomic, strong) DeviceFeatureModel* onDeviceVoiceAssistantCapabilityFeature;
@property (nonatomic, strong) DeviceFeatureModel* onDeviceVoiceAssistantModeFeature;
@property (nonatomic, strong) DeviceFeatureModel* workModeFeature;
@property (nonatomic, strong) DeviceFeatureModel* workStateFeature;
@property (nonatomic, strong) DeviceFeatureModel* wearDetectionCapabilityFeature;
@property (nonatomic, strong) DeviceFeatureModel* wearDetectionEnabledFeature;
@property (nonatomic, strong) DeviceFeatureModel* volumeSetCapabilityFeature;
@property (nonatomic, strong) DeviceFeatureModel* twsSupportedFeature;
@property (nonatomic, strong) DeviceFeatureModel* twsConnectionFeature;
@end

@implementation DeviceHomeViewController

-(instancetype) initWithDevice:(id<AIBudsDeviceConvertible>)device
{
    self = [super init];
    if (self) {
        self.device = device;
        device.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.device.name;
    
    // 初始化并添加 UITableView
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.featureGroups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DeviceFeatureGroupModel *group = self.featureGroups[section];
    return group.features.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FeatureCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    DeviceFeatureGroupModel *group = self.featureGroups[indexPath.section];
    DeviceFeatureModel *feature = group.features[indexPath.row];
    
    if(feature.icon) {
        cell.imageView.image = [UIImage imageNamed:feature.icon];
    }
    cell.textLabel.text = feature.name;
    cell.detailTextLabel.text = feature.valueText;
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    DeviceFeatureGroupModel *group = self.featureGroups[section];
    return group.name;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DeviceFeatureGroupModel *group = self.featureGroups[indexPath.section];
    DeviceFeatureModel *feature = group.features[indexPath.row];
    
    if (feature.classNameOfDemoVC) {
        Class demoVCClass = NSClassFromString(feature.classNameOfDemoVC);
        if (demoVCClass) {
            FeatureDemoBaseController *demoVC = [[demoVCClass alloc] initWithDevice:self.device];
            demoVC.title = feature.name;
            [self.navigationController pushViewController:demoVC animated:YES];
        }
    } else if (feature.handler) {
        feature.handler();
    }
}

+ (NSArray<NSNumber *> *) availableAIVendorKeys {
    return @[@(AIBudsAIServiceVendorStarBurst), @(AIBudsAIServiceVendorMltcloud)];
}

+ (NSDictionary<NSNumber *, NSString *> *) availableAIVendorDictionary {
    return @{
        @(AIBudsAIServiceVendorStarBurst) : NSLocalizedString(@"LocKey.StarBurstAI", nil),
        @(AIBudsAIServiceVendorMltcloud) : NSLocalizedString(@"LocKey.MLTCloudAI", nil),
    };
}

+ (NSArray<NSString *> *) availableAIVendorNames {
    NSMutableArray<NSString *> *vendorNames = [NSMutableArray array];
    for (NSNumber *vendorKey in [[self class] availableAIVendorKeys]) {
        [vendorNames addObject:[[self class] availableAIVendorDictionary][vendorKey]];
    }
    return vendorNames;
}

- (NSString*) onDeviceVoiceAssistantCapabilityStringOf:(AIBudsOnDeviceVoiceAssistantCapability)capability {
    switch (capability) {
        case AIBudsOnDeviceVoiceAssistantCapabilityNone:
            return NSLocalizedString(@"LocKey.OnDeviceVoiceAssistantCapabilityNone", nil);
        case AIBudsOnDeviceVoiceAssistantCapabilityKeywordWakeup:
            return NSLocalizedString(@"LocKey.OnDeviceVoiceAssistantCapabilityKeywordWakeup", nil);
        case AIBudsOnDeviceVoiceAssistantCapabilityCommon:
            return NSLocalizedString(@"LocKey.OnDeviceVoiceAssistantCapabilityCommon", nil);
        default:
            return NSLocalizedString(@"LocKey.Unknown", nil);
    }
}

- (NSString*) onDeviceVoiceAssistantModeStringOf:(AIBudsOnDeviceVoiceAssistantMode)mode {
    switch (mode) {
        case AIBudsOnDeviceVoiceAssistantModeUnknown:
            return NSLocalizedString(@"LocKey.OnDeviceVoiceAssistantModeUnknown", nil);
        case AIBudsOnDeviceVoiceAssistantModeDisabled:
            return NSLocalizedString(@"LocKey.OnDeviceVoiceAssistantModeDisabled", nil);
        case AIBudsOnDeviceVoiceAssistantModeBasic:
            return NSLocalizedString(@"LocKey.OnDeviceVoiceAssistantModeBasic", nil);
        case AIBudsOnDeviceVoiceAssistantModeAdvanced:
            return NSLocalizedString(@"LocKey.OnDeviceVoiceAssistantModeAdvanced", nil);
        default:
            return NSLocalizedString(@"LocKey.Unknown", nil);
    }
}

-(NSArray<NSNumber*>*) availableOnDeviceVoiceAssistantModeKeys {
    AIBudsOnDeviceVoiceAssistantCapability onDeviceVoiceAssistantCapability = ((id<AIBudsOnDeviceVoiceAssistantAPI>)self.device).onDeviceVoiceAssistantCapability;
    switch (onDeviceVoiceAssistantCapability) {
    case AIBudsOnDeviceVoiceAssistantCapabilityNone:
        return @[];
    case AIBudsOnDeviceVoiceAssistantCapabilityKeywordWakeup:
        return @[@(AIBudsOnDeviceVoiceAssistantModeDisabled), @(AIBudsOnDeviceVoiceAssistantModeBasic)];
    case AIBudsOnDeviceVoiceAssistantCapabilityCommon:
        return @[@(AIBudsOnDeviceVoiceAssistantModeDisabled), @(AIBudsOnDeviceVoiceAssistantModeBasic), @(AIBudsOnDeviceVoiceAssistantModeAdvanced)];
    default:
        return @[];
    }
    return @[];
}

-(NSDictionary<NSNumber*, NSString*>*) onDeviceVoiceAssistantModeNameDictionary {
    return @{
        @(AIBudsOnDeviceVoiceAssistantModeDisabled) : NSLocalizedString(@"LocKey.OnDeviceVoiceAssistantModeDisabled", nil), 
        @(AIBudsOnDeviceVoiceAssistantModeBasic) : NSLocalizedString(@"LocKey.OnDeviceVoiceAssistantModeBasic", nil), 
        @(AIBudsOnDeviceVoiceAssistantModeAdvanced) : NSLocalizedString(@"LocKey.OnDeviceVoiceAssistantModeAdvanced", nil),
    };
}

-(NSString*)workModeStringOf:(AIBudsWorkMode)mode {
    switch (mode) {
        case AIBudsWorkModeUnknown:
            return NSLocalizedString(@"LocKey.WorkModeUnknown", nil);
        case AIBudsWorkModeNormal:
            return NSLocalizedString(@"LocKey.WorkModeNormal", nil);
        case AIBudsWorkModeGame:
            return NSLocalizedString(@"LocKey.WorkModeGame", nil);
        default:
            return NSLocalizedString(@"LocKey.Unknown", nil);
    }
}

-(NSString*)workStateStringOf:(AIBudsWorkState)state {
    switch (state) {
        case AIBudsWorkStateUnknown:
            return NSLocalizedString(@"LocKey.WorkStateUnknown", nil);
        case AIBudsWorkStateReserved:
            return NSLocalizedString(@"LocKey.WorkStateReserved", nil);
        case AIBudsWorkStateInitializing:
            return NSLocalizedString(@"LocKey.WorkStateInitializing", nil);
        case AIBudsWorkStateBtOrBleWaitingForConnection:
            return NSLocalizedString(@"LocKey.WorkStateBtOrBleWaitingForConnection", nil);
        case AIBudsWorkStateBtOrBleConnectedIdle:
            return NSLocalizedString(@"LocKey.WorkStateBtOrBleConnectedIdle", nil);
        case AIBudsWorkStateBtOrBleDisconnectedIdle:
            return NSLocalizedString(@"LocKey.WorkStateBtOrBleDisconnectedIdle", nil);
        case AIBudsWorkStateCalling:
            return NSLocalizedString(@"LocKey.WorkStateCalling", nil);
        case AIBudsWorkStatePlayingLocalMusic:
            return NSLocalizedString(@"LocKey.WorkStatePlayingLocalMusic", nil);
        case AIBudsWorkStateAiConversing:
            return NSLocalizedString(@"LocKey.WorkStateAiConversing", nil);
        case AIBudsWorkStateRestoringFactorySettings:
            return NSLocalizedString(@"LocKey.WorkStateRestoringFactorySettings", nil);
        case AIBudsWorkStateTakingPhoto:
            return NSLocalizedString(@"LocKey.WorkStateTakingPhoto", nil);
        case AIBudsWorkStateAiTakingPhoto:
            return NSLocalizedString(@"LocKey.WorkStateAiTakingPhoto", nil);
        case AIBudsWorkStateRecordingVideo:
            return NSLocalizedString(@"LocKey.WorkStateRecordingVideo", nil);
        case AIBudsWorkStateRecordingAudio:
            return NSLocalizedString(@"LocKey.WorkStateRecordingAudio", nil);
        case AIBudsWorkStateFileTransferring:
            return NSLocalizedString(@"LocKey.WorkStateFileTransferring", nil);
        case AIBudsWorkStateStreaming:
            return NSLocalizedString(@"LocKey.WorkStateStreaming", nil);
        case AIBudsWorkStateOta:
            return NSLocalizedString(@"LocKey.WorkStateOta", nil);
        case AIBudsWorkStateShuttingDown:
            return NSLocalizedString(@"LocKey.WorkStateShuttingDown", nil);
        case AIBudsWorkStateFactoryTesting:
            return NSLocalizedString(@"LocKey.WorkStateFactoryTesting", nil);
        case AIBudsWorkStateLedTesting:
            return NSLocalizedString(@"LocKey.WorkStateLedTesting", nil);
        case AIBudsWorkStateButtonTesting:
            return NSLocalizedString(@"LocKey.WorkStateButtonTesting", nil);
        case AIBudsWorkStateEchoTesting:
            return NSLocalizedString(@"LocKey.WorkStateEchoTesting", nil);
        default:
            return NSLocalizedString(@"LocKey.Unknown", nil);
    }
}

-(NSArray<NSNumber*>*) availableWorkModeKeys {
    return @[@(AIBudsWorkModeNormal), @(AIBudsWorkModeGame)];
}

-(NSDictionary<NSNumber*, NSString*>*) workModeNameDictionary {
    return @{
        @(AIBudsWorkModeNormal) : NSLocalizedString(@"LocKey.WorkModeNormal", nil),
        @(AIBudsWorkModeGame) : NSLocalizedString(@"LocKey.WorkModeGame", nil),
    };
}

-(NSString*)wearDetectionCapabilityStringOf:(AIBudsWearDetectionCapability)capability
{
    switch (capability) {
        case AIBudsWearDetectionCapabilityNone:
            return NSLocalizedString(@"LocKey.WearDetectionCapabilityNone", nil);
        case AIBudsWearDetectionCapabilitySupportedNotConfigurable:
            return NSLocalizedString(@"LocKey.WearDetectionCapabilitySupportedNotConfigurable", nil);
        case AIBudsWearDetectionCapabilitySupportedAndConfigurable:
            return NSLocalizedString(@"LocKey.WearDetectionCapabilitySupportedAndConfigurable", nil);
        default:
            return NSLocalizedString(@"LocKey.Unknown", nil);
    }
}

-(NSString*)wearDetectionEnabledStringOf:(BOOL)enabled
{
    return enabled ? NSLocalizedString(@"LocKey.WearDetectionEnabled", nil) : NSLocalizedString(@"LocKey.WearDetectionDisabled", nil);
}

-(NSString*)volumeSetCapabilityStringOf:(AIBudsVolumeSetCapability)capability
{
    switch (capability) {
        case AIBudsVolumeSetCapabilityNone:
            return NSLocalizedString(@"LocKey.VolumeSetCapabilityNone", nil);
        case AIBudsVolumeSetCapabilityCommon:
            return NSLocalizedString(@"LocKey.VolumeSetCapabilityCommon", nil);
        case AIBudsVolumeSetCapabilityAdvanced:
            return NSLocalizedString(@"LocKey.VolumeSetCapabilityAdvanced", nil);
        default:
            return NSLocalizedString(@"LocKey.Unknown", nil);
    }
}

-(NSString*)twsSupportedStringOf:(BOOL)supported
{
    return supported ? NSLocalizedString(@"LocKey.TWSupported", nil) : NSLocalizedString(@"LocKey.TWSNotSupported", nil);
}

-(NSString*)twsConnectionStringOf:(BOOL)connected
{
    return connected ? NSLocalizedString(@"LocKey.TWSConnected", nil) : NSLocalizedString(@"LocKey.TWSNotConnected", nil);
}



- (NSArray<DeviceFeatureGroupModel*>*)featureGroups
{
    __weak typeof(self) weakSelf = self;
    self.aiServiceVendorFeature = [DeviceFeatureModel modelWithIcon:@"icon_ai_vendor" name:NSLocalizedString(@"LocKey.SelectAiServiceVendorFeatureTitle", nil) handler:^{
                [weakSelf selectAiServiceVendor];
        }];
    NSNumber* vendorKey = @([AIFeatureContext sharedInstance].serviceVendor);
    self.aiServiceVendorFeature.valueText = [[[self class] availableAIVendorDictionary] objectForKey:vendorKey];
    self.firmwareVersionFeature = [DeviceFeatureModel modelWithIcon:@"icon_firmware_version" name:NSLocalizedString(@"LocKey.FirmwareVersionFeatureTitle", nil) handler:^{
        
    }];
    self.firmwareVersionFeature.valueText = self.device.firmwareVersion;

    self.onDeviceVoiceAssistantCapabilityFeature = [DeviceFeatureModel modelWithIcon:@"icon_voice_assistant" name:NSLocalizedString(@"LocKey.OnDeviceVoiceAssistantCapabilityFeatureTitle", nil) handler:^{
        
    }];

    id<AIBudsOnDeviceVoiceAssistantAPI> voiceAssistantDevice = (id<AIBudsOnDeviceVoiceAssistantAPI>)self.device;
    if ([voiceAssistantDevice conformsToProtocol:@protocol(AIBudsOnDeviceVoiceAssistantAPI)]) {
        self.onDeviceVoiceAssistantCapabilityFeature.valueText = [self onDeviceVoiceAssistantCapabilityStringOf:voiceAssistantDevice.onDeviceVoiceAssistantCapability];
    } else {
        self.onDeviceVoiceAssistantCapabilityFeature.valueText = NSLocalizedString(@"LocKey.NotSupported", nil);
    }

    self.onDeviceVoiceAssistantModeFeature = [DeviceFeatureModel modelWithIcon:@"icon_voice_assistant_mode" name:NSLocalizedString(@"LocKey.OnDeviceVoiceAssistantModeFeatureTitle", nil) handler:^{
        [self selectOnDeviceVoiceAssistantMode];
    }];
    if ([voiceAssistantDevice conformsToProtocol:@protocol(AIBudsOnDeviceVoiceAssistantAPI)]) {
        self.onDeviceVoiceAssistantModeFeature.valueText = [self onDeviceVoiceAssistantModeStringOf:voiceAssistantDevice.onDeviceVoiceAssistantMode];
    } else {
        self.onDeviceVoiceAssistantModeFeature.valueText = NSLocalizedString(@"LocKey.NotSupported", nil);
    }

    self.workModeFeature = [DeviceFeatureModel modelWithIcon:@"icon_work_mode" name:NSLocalizedString(@"LocKey.WorkModeFeatureTitle", nil) handler:^{
        [self selectWorkMode];
    }];
    id<AIBudsDeviceWorkModeAPI> workModeDevice = (id<AIBudsDeviceWorkModeAPI>)self.device;
    if ([workModeDevice conformsToProtocol:@protocol(AIBudsDeviceWorkModeAPI)]) {
        self.workModeFeature.valueText = [self workModeStringOf:workModeDevice.workMode];
    } else {
        self.workModeFeature.valueText = NSLocalizedString(@"LocKey.NotSupported", nil);
    }
    
    self.workStateFeature = [DeviceFeatureModel modelWithIcon:@"icon_work_state" name:NSLocalizedString(@"LocKey.WorkStateFeatureTitle", nil) handler:^{
        
    }];
    id<AIBudsDeviceWorkStateAPI> workStateDevice = (id<AIBudsDeviceWorkStateAPI>)self.device;
    if ([workStateDevice conformsToProtocol:@protocol(AIBudsDeviceWorkStateAPI)]) {
        self.workStateFeature.valueText = [self workStateStringOf:workStateDevice.workState];
    } else {
        self.workStateFeature.valueText = NSLocalizedString(@"LocKey.NotSupported", nil);
    }
    
    
    self.wearDetectionCapabilityFeature = [DeviceFeatureModel modelWithIcon:@"icon_wear_detection" name:NSLocalizedString(@"LocKey.WearDetectionCapabilityFeatureTitle", nil) handler:^{
        
    }];

    id<AIBudsDeviceWearDetectionAPI> wearDetectionDevice = (id<AIBudsDeviceWearDetectionAPI>)self.device;
    if ([wearDetectionDevice conformsToProtocol:@protocol(AIBudsDeviceWearDetectionAPI)]) {
        self.wearDetectionCapabilityFeature.valueText = [self wearDetectionCapabilityStringOf:wearDetectionDevice.wearDetectionCapability];
    } else {
        self.wearDetectionCapabilityFeature.valueText = NSLocalizedString(@"LocKey.NotSupported", nil);
    }

    self.wearDetectionEnabledFeature = [DeviceFeatureModel modelWithIcon:@"icon_wear_detection_status" name:NSLocalizedString(@"LocKey.WearDetectionEnabledFeatureTitle", nil) handler:^{
        [self toggleWearDetectionEnabled];
    }];
    if ([wearDetectionDevice conformsToProtocol:@protocol(AIBudsDeviceWearDetectionAPI)]) {
        self.wearDetectionEnabledFeature.valueText = [self wearDetectionEnabledStringOf:wearDetectionDevice.isWearDetectionEnabled];
    } else {
        self.wearDetectionEnabledFeature.valueText = NSLocalizedString(@"LocKey.NotSupported", nil);
    }

    self.volumeSetCapabilityFeature = [DeviceFeatureModel modelWithIcon:@"icon_volume_set_capability" name:NSLocalizedString(@"LocKey.VolumeSetCapabilityFeatureTitle", nil) handler:^{
        
    }];

    id<AIBudsDeviceVolumeControlAPI> volumeControlDevice = (id<AIBudsDeviceVolumeControlAPI>)self.device;
    if ([volumeControlDevice conformsToProtocol:@protocol(AIBudsDeviceVolumeControlAPI)]) {
        self.volumeSetCapabilityFeature.valueText = [self volumeSetCapabilityStringOf:volumeControlDevice.volumeSetCapability];
    } else {
        self.volumeSetCapabilityFeature.valueText = NSLocalizedString(@"LocKey.NotSupported", nil);
    }

    self.twsSupportedFeature = [DeviceFeatureModel modelWithIcon:@"icon_tws_supported" name:NSLocalizedString(@"LocKey.TWSupportedFeatureTitle", nil) handler:^{
        
    }];
    id<AIBudsDeviceTWSAPI> twsDevice = (id<AIBudsDeviceTWSAPI>)self.device;
    if ([twsDevice conformsToProtocol:@protocol(AIBudsDeviceTWSAPI)]) {
        self.twsSupportedFeature.valueText = [self twsSupportedStringOf:twsDevice.isTws];
    } else {
        self.twsSupportedFeature.valueText = NSLocalizedString(@"LocKey.NotSupported", nil);
    }

    self.twsConnectionFeature = [DeviceFeatureModel modelWithIcon:@"icon_tws_connection" name:NSLocalizedString(@"LocKey.TWSConnectionFeatureTitle", nil) handler:^{
        
    }];
    if ([twsDevice conformsToProtocol:@protocol(AIBudsDeviceTWSAPI)]) {
        self.twsConnectionFeature.valueText = [self twsConnectionStringOf:twsDevice.isTwsConnected];
    } else {
        self.twsConnectionFeature.valueText = NSLocalizedString(@"LocKey.NotSupported", nil);
    }


    
    return @[
        [DeviceFeatureGroupModel modelWithIcon:@"icon_basic_features" name:NSLocalizedString(@"LocKey.BasicFeaturesGroupTitle", nil) features:@[
            [DeviceFeatureModel modelWithIcon:@"icon_factory_reset" name:NSLocalizedString(@"LocKey.FactoryResetFeatureTitle", nil) handler:^{
                id<AIBudsDeviceCommonAPI> device = (id<AIBudsDeviceCommonAPI>)self.device;
                if([device conformsToProtocol:@protocol(AIBudsDeviceCommonAPI)]) {
                    [device factoryResetWithCompletion:^(BOOL success, NSError * _Nullable error) {
                        __strong typeof(self) strongSelf = weakSelf;
                        if(!strongSelf) return;
                        NSString* message = success? NSLocalizedString(@"LocKey.FactoryResetSuccessMessage", nil) : [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"LocKey.FactoryResetFailedMessage", nil), error.localizedDescription];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [strongSelf.view makeToast:message duration:3.0 position:CSToastPositionTop];
                        });
                    }];
                }
            }],
            [DeviceFeatureModel modelWithIcon:@"icon_power_off" name:NSLocalizedString(@"LocKey.PowerOffFeatureTitle", nil) handler:^{
                id<AIBudsDeviceCommonAPI> device = (id<AIBudsDeviceCommonAPI>)self.device;
                if([device conformsToProtocol:@protocol(AIBudsDeviceCommonAPI)]) {
                    [device powerOffWithCompletion:^(BOOL success, NSError * _Nullable error) {
                        __strong typeof(self) strongSelf = weakSelf;
                        if(!strongSelf) return;
                        NSString* message = success? NSLocalizedString(@"LocKey.PowerOffSuccessMessage", nil) : [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"LocKey.PowerOffFailedMessage", nil), error.localizedDescription];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [strongSelf.view makeToast:message duration:3.0 position:CSToastPositionTop];
                        });
                    }];
                }
            }],
            [DeviceFeatureModel modelWithIcon:@"icon_unpair_device" name:NSLocalizedString(@"LocKey.UnpairDeviceFeatureTitle", nil) handler:^{
                    __strong typeof(self) strongSelf = weakSelf;
                    if(!strongSelf) return;
                    [self.device unpair];
                    NSString* message = NSLocalizedString(@"LocKey.UnpairSuccessMessage", nil);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf.view makeToast:message duration:3.0 position:CSToastPositionTop];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            __strong typeof(self) strongSelf = weakSelf;
                            if(!strongSelf) return;
                            [strongSelf.navigationController popViewControllerAnimated:YES];
                        });
                    });
            }],
        ]],
        [DeviceFeatureGroupModel modelWithIcon:@"icon_device" name:NSLocalizedString(@"LocKey.DeviceInfoGroupTitle", nil) features:@[
            [DeviceFeatureModel modelWithIcon:@"icon_device_info" name:NSLocalizedString(@"LocKey.DeviceInfoDetailsTitle", nil) classNameOfDemoVC:@"DeviceInfoDetailsController"],
            [DeviceFeatureModel modelWithIcon:@"icon_time_sync" name:NSLocalizedString(@"LocKey.SyncDeviceTimeFeatureTitle", nil) handler:^{
                id<AIBudsDeviceInfoAPI> device = (id<AIBudsDeviceInfoAPI>)self.device;
                if([device conformsToProtocol:@protocol(AIBudsDeviceInfoAPI)]) {
                    [device syncDeviceTimeWithCompletion:^(BOOL success, NSNumber * _Nullable statusCode, NSError * _Nullable error) {
                        __strong typeof(self) strongSelf = weakSelf;
                        if(!strongSelf) return;
                        NSString* message = success? NSLocalizedString(@"LocKey.SyncDeviceTimeSuccessMessage", nil) : [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"LocKey.SyncDeviceTimeFailedMessage", nil), error.localizedDescription];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [strongSelf.view makeToast:message duration:3.0 position:CSToastPositionTop];
                        });
                    }];
                }
            }],
            [DeviceFeatureModel modelWithIcon:@"icon_time_set" name:NSLocalizedString(@"LocKey.SetDeviceTimeFeatureTitle", nil) handler:^{
                id<AIBudsDeviceInfoAPI> device = (id<AIBudsDeviceInfoAPI>)self.device;
                if([device conformsToProtocol:@protocol(AIBudsDeviceInfoAPI)]) {
                    NSDate* date = [[NSDate date] dateByAddingTimeInterval:60*60];
                    [device setDeviceTime:date completion:^(BOOL success, NSNumber * _Nullable statusCode, NSError * _Nullable error) {
                        __strong typeof(self) strongSelf = weakSelf;
                        if(!strongSelf) return;
                        NSString* message = success? NSLocalizedString(@"LocKey.SetDeviceTimeSuccessMessage", nil) : [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"LocKey.SetDeviceTimeFailedMessage", nil), error.localizedDescription];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [strongSelf.view makeToast:message duration:3.0 position:CSToastPositionTop];
                        });
                    }];
                }
            }],
            [DeviceFeatureModel modelWithIcon:@"icon_language_set" name:NSLocalizedString(@"LocKey.SetDeviceLanguageFeatureTitle", nil) handler:^{
                id<AIBudsDeviceInfoAPI> device = (id<AIBudsDeviceInfoAPI>)self.device;
                if([device conformsToProtocol:@protocol(AIBudsDeviceInfoAPI)]) {
                    [device setDeviceLanguage:AIBudsDeviceLanguageEnglish completion:^(BOOL success, NSError * _Nullable error) {
                        __strong typeof(self) strongSelf = weakSelf;
                        if(!strongSelf) return;
                        NSString* message = success? NSLocalizedString(@"LocKey.SetDeviceLanguageSuccessMessage", nil) : [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"LocKey.SetDeviceLanguageFailedMessage", nil), error.localizedDescription];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [strongSelf.view makeToast:message duration:3.0 position:CSToastPositionTop];
                        });
                    }];
                }
            }],
            [DeviceFeatureModel modelWithIcon:@"icon_storage_info" name:NSLocalizedString(@"LocKey.QueryStorageInfoFeatureTitle", nil) handler:^{
                id<AIBudsDeviceInfoAPI> device = (id<AIBudsDeviceInfoAPI>)self.device;
                if([device conformsToProtocol:@protocol(AIBudsDeviceInfoAPI)]) {
                    [device requestQueryStorageInfoWithCompletion:^(BOOL success, NSError * _Nullable error) {
                        __strong typeof(self) strongSelf = weakSelf;
                        if(!strongSelf) return;
                        NSString* message = success? NSLocalizedString(@"LocKey.RequestQueryStorageInfoSuccessMessage", nil) : [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"LocKey.RequestQueryStorageInfoFailedMessage", nil), error.localizedDescription];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [strongSelf.view makeToast:message duration:3.0 position:CSToastPositionTop];
                        });
                    }];
                }
            }],
            [DeviceFeatureModel modelWithIcon:@"icon_media_count_info" name:NSLocalizedString(@"LocKey.QueryMediaCountInfoFeatureTitle", nil) handler:^{
                id<AIBudsDeviceInfoAPI> device = (id<AIBudsDeviceInfoAPI>)self.device;
                if([device conformsToProtocol:@protocol(AIBudsDeviceInfoAPI)]) {
                    [device requestQueryMediaCountInfoWithCompletion:^(BOOL success, NSError * _Nullable error) {
                        __strong typeof(self) strongSelf = weakSelf;
                        if(!strongSelf) return;
                        NSString* message = success? NSLocalizedString(@"LocKey.RequestQueryMediaCountInfoSuccessMessage", nil) : [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"LocKey.RequestQueryMediaCountInfoFailedMessage", nil), error.localizedDescription];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [strongSelf.view makeToast:message duration:3.0 position:CSToastPositionTop];
                        });
                    }];
                }
            }],
        ]],
        [DeviceFeatureGroupModel modelWithIcon:@"icon_find_device" name:NSLocalizedString(@"LocKey.FindFeatureGroupTitle", nil) features:@[
            [DeviceFeatureModel modelWithIcon:@"icon_find_device" name:NSLocalizedString(@"LocKey.FindDeviceFeatureTitle", nil) handler:^{
                id<AIBudsDeviceFindAPI> device = (id<AIBudsDeviceFindAPI>)self.device;
                if([device conformsToProtocol:@protocol(AIBudsDeviceFindAPI)]) {
                    [device findDeviceWithCompletion:^(BOOL success, NSError * _Nullable error) {
                        __strong typeof(self) strongSelf = weakSelf;
                        if(!strongSelf) return;
                        NSString* message = success? NSLocalizedString(@"LocKey.FindDeviceSuccessMessage", nil) : [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"LocKey.FindDeviceFailedMessage", nil), error.localizedDescription];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [strongSelf.view makeToast:message duration:3.0 position:CSToastPositionTop];
                        });
                    }];
                }
            }],
            [DeviceFeatureModel modelWithIcon:@"icon_stop_find_device" name:NSLocalizedString(@"LocKey.StopFindDeviceFeatureTitle", nil) handler:^{
                id<AIBudsDeviceFindAPI> device = (id<AIBudsDeviceFindAPI>)self.device;
                if([device conformsToProtocol:@protocol(AIBudsDeviceFindAPI)]) {
                    [device stopFindDeviceWithCompletion:^(BOOL success, NSError * _Nullable error) {
                        __strong typeof(self) strongSelf = weakSelf;
                        if(!strongSelf) return;
                        NSString* message = success? NSLocalizedString(@"LocKey.StopFindDeviceSuccessMessage", nil) : [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"LocKey.StopFindDeviceFailedMessage", nil), error.localizedDescription];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [strongSelf.view makeToast:message duration:3.0 position:CSToastPositionTop];
                        });
                    }];
                }
            }],
        ]],
        [DeviceFeatureGroupModel modelWithIcon:@"icon_firmware" name:NSLocalizedString(@"LocKey.FirmwareGroupTitle", nil) features:@[
            self.firmwareVersionFeature,
        ]],
        [DeviceFeatureGroupModel modelWithIcon:@"icon_physical_operations" name:NSLocalizedString(@"LocKey.PhysicalOperationsGroupTitle", nil) features:@[
            [DeviceFeatureModel modelWithIcon:@"icon_physical_operations" name:NSLocalizedString(@"LocKey.PhysicalOperationsMappingFeatureTitle", nil) classNameOfDemoVC:@"PhysicalOperationsMappingDemoController"],
            [DeviceFeatureModel modelWithIcon:@"icon_operations_assign" name:NSLocalizedString(@"LocKey.AssignPhysicalOperationsFeatureTitle", nil) classNameOfDemoVC:@"AssignPhysicalOperationsDemoController"],
        ]],
        [DeviceFeatureGroupModel modelWithIcon:@"icon_service_auth" name:NSLocalizedString(@"LocKey.ServiceAuthGroupTitle", nil) features:@[
            [DeviceFeatureModel modelWithIcon:@"icon_authorized_services" name:NSLocalizedString(@"LocKey.AuthorizedServicesFeatureTitle", nil) classNameOfDemoVC:@"AuthorizedServicesController"],
            [DeviceFeatureModel modelWithIcon:@"icon_retry_service_auth" name:NSLocalizedString(@"LocKey.RetryServiceAuthFeatureTitle", nil) handler:^{
                [(id<AIBudsDeviceServiceAuthAPI>)self.device retryServiceAuth:AIBudsServiceAuthTypeOnDeviceVoiceAssistant completion:^(BOOL success, NSError * _Nullable error) {
                    __strong typeof(self) strongSelf = weakSelf;
                    if(!strongSelf) return;
                    NSString* message = success? NSLocalizedString(@"LocKey.RetryServiceAuthSuccessMessage", nil) : [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"LocKey.RetryServiceAuthFailedMessage", nil), error.localizedDescription];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf.view makeToast:message duration:3.0 position:CSToastPositionTop];
                    });
                }];
        }],
        [DeviceFeatureModel modelWithIcon:@"icon_self_ai_report" name:NSLocalizedString(@"LocKey.ReportSelfAiServiceAuthResultFeatureTitle", nil) handler:^{
            [(id<AIBudsDeviceServiceAuthAPI>)self.device reportSelfAiServiceAuthResult:YES completion:^(BOOL success, NSError * _Nullable error) {
            
                __strong typeof(self) strongSelf = weakSelf;
                if(!strongSelf) return;
                NSString* message = success? NSLocalizedString(@"LocKey.ReportSelfAiServiceAuthResultSuccessMessage", nil) : [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"LocKey.ReportSelfAiServiceAuthResultFailedMessage", nil), error.localizedDescription];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.view makeToast:message duration:3.0 position:CSToastPositionTop];
                });
            }];
        }],
        ]],
        [DeviceFeatureGroupModel modelWithIcon:@"icon_voice_assistant" name:NSLocalizedString(@"LocKey.VoiceAssistantGroupTitle", nil) features:@[
            self.onDeviceVoiceAssistantCapabilityFeature,
            self.onDeviceVoiceAssistantModeFeature,
        ]],
        [DeviceFeatureGroupModel modelWithIcon:@"icon_work_mode" name:NSLocalizedString(@"LocKey.WorkModeGroupTitle", nil) features:@[
            self.workModeFeature,
        ]],
        [DeviceFeatureGroupModel modelWithIcon:@"icon_work_state" name:NSLocalizedString(@"LocKey.WorkStateGroupTitle", nil) features:@[
            self.workStateFeature,
        ]],
        [DeviceFeatureGroupModel modelWithIcon:@"icon_wear_detection" name:NSLocalizedString(@"LocKey.WearDetectionGroupTitle", nil) features:@[
            self.wearDetectionCapabilityFeature,
            self.wearDetectionEnabledFeature,
        ]],
        [DeviceFeatureGroupModel modelWithIcon:@"icon_volume_control" name:NSLocalizedString(@"LocKey.VolumeControlGroupTitle", nil) features:@[
            self.volumeSetCapabilityFeature,
            [DeviceFeatureModel modelWithIcon:@"icon_volume_set" name:NSLocalizedString(@"LocKey.VolumeSetFeatureTitle", nil) handler:^{
            [self goVolumeSetDemo];
        }],
        ]],
        [DeviceFeatureGroupModel modelWithIcon:@"icon_music_control" name:NSLocalizedString(@"LocKey.MusicControlGroupTitle", nil) features:@[
            [DeviceFeatureModel modelWithIcon:@"icon_music_control" name:NSLocalizedString(@"LocKey.MusicControlFeatureTitle", nil) classNameOfDemoVC:@"MusicControlDemoController"],
        ]],
        [DeviceFeatureGroupModel modelWithIcon:@"icon_tws" name:NSLocalizedString(@"LocKey.TWSGroupTitle", nil) features:@[
            self.twsSupportedFeature,
            self.twsConnectionFeature,
        ]],
        [DeviceFeatureGroupModel modelWithIcon:@"icon_equalizer" name:NSLocalizedString(@"LocKey.EqualizerGroupTitle", nil) features:@[
            [DeviceFeatureModel modelWithIcon:@"icon_equalizer" name:NSLocalizedString(@"LocKey.EqualizerFeatureTitle", nil) classNameOfDemoVC:@"EqualizerDemoController"],
        ]],
        [DeviceFeatureGroupModel modelWithIcon:@"icon_anc" name:NSLocalizedString(@"LocKey.ANCGroupTitle", nil) features:@[
            [DeviceFeatureModel modelWithIcon:@"icon_anc" name:NSLocalizedString(@"LocKey.ANCFeatureTitle", nil) classNameOfDemoVC:@"ANCDemoController"],
        ]],
        [DeviceFeatureGroupModel modelWithIcon:@"icon_audio_recording" name:NSLocalizedString(@"LocKey.AudioRecordingGroupTitle", nil) features:@[
            [DeviceFeatureModel modelWithIcon:@"icon_audio_recording" name:NSLocalizedString(@"LocKey.AudioRecordingFeatureTitle", nil) classNameOfDemoVC:@"AudioRecordingDemoController"],
        ]],
        [DeviceFeatureGroupModel modelWithIcon:@"icon_camera" name:NSLocalizedString(@"LocKey.CameraGroupTitle", nil) features:@[
            [DeviceFeatureModel modelWithIcon:@"icon_video_recording" name:NSLocalizedString(@"LocKey.VideoRecordingFeatureTitle", nil) classNameOfDemoVC:@"VideoRecordingDemoController"],
        ]],
        [DeviceFeatureGroupModel modelWithIcon:@"icon_remote_shutter" name:NSLocalizedString(@"LocKey.RemoteShutterGroupTitle", nil) features:@[
            [DeviceFeatureModel modelWithIcon:@"icon_remote_shutter" name:NSLocalizedString(@"LocKey.RemoteShutterFeatureTitle", nil) classNameOfDemoVC:@"RemoteShutterDemoController"],
        ]],
        [DeviceFeatureGroupModel modelWithIcon:@"icon_file_import" name:NSLocalizedString(@"LocKey.FileImportGroupTitle", nil) features:@[
            [DeviceFeatureModel modelWithIcon:@"icon_file_import" name:NSLocalizedString(@"LocKey.FileImportFeatureTitle", nil) classNameOfDemoVC:@"FileImportDemoController"],
        ]],
        [DeviceFeatureGroupModel modelWithIcon:@"icon_overlay_prompt" name:NSLocalizedString(@"LocKey.OverlayPromptGroupTitle", nil) features:@[
            [DeviceFeatureModel modelWithIcon:@"icon_overlay_prompt" name:NSLocalizedString(@"LocKey.OverlayPromptFeatureTitle", nil) classNameOfDemoVC:@"OverlayPromptDemoController"],
        ]],
        [DeviceFeatureGroupModel modelWithIcon:@"icon_turn_by_turn_navigation" name:NSLocalizedString(@"LocKey.TurnByTurnNavigationGroupTitle", nil) features:@[
            [DeviceFeatureModel modelWithIcon:@"icon_turn_by_turn_navigation" name:NSLocalizedString(@"LocKey.TurnByTurnNavigationFeatureTitle", nil) classNameOfDemoVC:@"TurnByTurnNavigationDemoController"],
        ]],
        [DeviceFeatureGroupModel modelWithIcon:@"icon_ota" name:NSLocalizedString(@"LocKey.OtaGroupTitle", nil) features:@[
            [DeviceFeatureModel modelWithIcon:@"icon_device_ota" name:NSLocalizedString(@"LocKey.OtaFeatureTitle", nil) classNameOfDemoVC:@"OTADemoController"],
        ]],
        [DeviceFeatureGroupModel modelWithIcon:@"icon_ota" name:NSLocalizedString(@"LocKey.CameraOtaGroupTitle", nil) features:@[
            [DeviceFeatureModel modelWithIcon:@"icon_camera_ota" name:NSLocalizedString(@"LocKey.CameraOtaFeatureTitle", nil) classNameOfDemoVC:@"CameraOtaDemoController"],
        ]],
        [DeviceFeatureGroupModel modelWithIcon:@"icon_ai" name:NSLocalizedString(@"LocKey.AiGroupTitle", nil) features:@[
            self.aiServiceVendorFeature,
            [DeviceFeatureModel modelWithIcon:@"icon_ai_recording" name:NSLocalizedString(@"LocKey.AiAudioRecordingFeatureTitle", nil) classNameOfDemoVC:@"AIAudioRecordingDemoController"],
            [DeviceFeatureModel modelWithIcon:@"icon_streaming_asr" name:NSLocalizedString(@"LocKey.StreamingASRFeatureTitle", nil) classNameOfDemoVC:@"StreamingASRDemoController"],
            [DeviceFeatureModel modelWithIcon:@"icon_ai_tts" name:NSLocalizedString(@"LocKey.TTSFeatureTitle", nil) classNameOfDemoVC:@"TTSDemoController"],
            [DeviceFeatureModel modelWithIcon:@"icon_ai_summary" name:NSLocalizedString(@"LocKey.AiSummaryFeatureTitle", nil) classNameOfDemoVC:@"AISummaryDemoController"],
            [DeviceFeatureModel modelWithIcon:@"icon_ai_translation" name:NSLocalizedString(@"LocKey.AiTextTranslationFeatureTitle", nil) classNameOfDemoVC:@"AITextTranslationDemoController"],
            [DeviceFeatureModel modelWithIcon:@"icon_simultaneous_interpretation" name:NSLocalizedString(@"LocKey.SimultaneousInterpretationFeatureTitle", nil) classNameOfDemoVC:@"SimultaneousInterpretationDemoController"],
            [DeviceFeatureModel modelWithIcon:@"icon_ai_chat" name:NSLocalizedString(@"LocKey.AiChatFeatureTitle", nil) classNameOfDemoVC:@"AIChatDemoController"],
            
        ]],

        [DeviceFeatureGroupModel modelWithIcon:@"icon_log" name:NSLocalizedString(@"LocKey.LogGroupTitle", nil) features:@[
            [DeviceFeatureModel modelWithIcon:@"icon_log" name:NSLocalizedString(@"LocKey.LogFeatureTitle", nil) classNameOfDemoVC:@"LogDemoController"],
        ]],
    ];
}

- (void) goVolumeSetDemo {
    id<AIBudsDeviceVolumeControlAPI> device = (id<AIBudsDeviceVolumeControlAPI>)self.device;
    if([device conformsToProtocol:@protocol(AIBudsDeviceVolumeControlAPI)]) {
        if (device.volumeSetCapability == AIBudsVolumeSetCapabilityNone) {
            [self.view makeToast:NSLocalizedString(@"LocKey.NoVolumeSetCapabilityMessage", nil) duration:3.0 position:CSToastPositionTop];
            return;
        }
    }
    Class demoVCClass = NSClassFromString(@"VolumeSetDemoController");
    if (demoVCClass) {
        FeatureDemoBaseController *demoVC = [[demoVCClass alloc] initWithDevice:self.device];
        [self.navigationController pushViewController:demoVC animated:YES];
    }
}

- (void)toggleWearDetectionEnabled {
    id<AIBudsDeviceWearDetectionAPI> device = (id<AIBudsDeviceWearDetectionAPI>)self.device;
    if([device conformsToProtocol:@protocol(AIBudsDeviceWearDetectionAPI)]) {
        if (device.wearDetectionCapability != AIBudsWearDetectionCapabilitySupportedAndConfigurable) {
            [self.view makeToast:NSLocalizedString(@"LocKey.WearDetectionNotConfigurableMessage", nil) duration:3.0 position:CSToastPositionTop];
            return;
        }
        BOOL isEnable = device.isWearDetectionEnabled;
        __weak typeof(self) weakSelf = self;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LocKey.ToggleWearDetectionEnableStatusAlertTitle", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];

        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"LocKey.EnableLocKey", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if(isEnable)
            {
                [self.view makeToast:NSLocalizedString(@"LocKey.WearDetectionAlreadyEnabledMessage", nil) duration:3.0 position:CSToastPositionTop];
                return;
            }
            [device setWearDetectionEnabled:YES completion:^(BOOL success, NSError * _Nullable error) {
                __strong typeof(self) strongSelf = weakSelf;
                if(!strongSelf) return;
                NSString* message = success? NSLocalizedString(@"LocKey.SetWearDetectionEnabledSuccessMessage", nil) : [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"LocKey.SetWearDetectionEnabledFailedMessage", nil), error.localizedDescription];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.view makeToast:message duration:3.0 position:CSToastPositionTop];
                    [strongSelf.tableView reloadData];
                });
            }];
        }]];

        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"LocKey.DisableLocKey", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if(!isEnable)
            {
                [self.view makeToast:NSLocalizedString(@"LocKey.WearDetectionAlreadyDisabledMessage", nil) duration:3.0 position:CSToastPositionTop];
                return;
            }
            [device setWearDetectionEnabled:NO completion:^(BOOL success, NSError * _Nullable error) {
                __strong typeof(self) strongSelf = weakSelf;
                if(!strongSelf) return;
                NSString* message = success? NSLocalizedString(@"LocKey.SetWearDetectionDisabledSuccessMessage", nil) : [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"LocKey.SetWearDetectionDisabledFailedMessage", nil), error.localizedDescription];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.view makeToast:message duration:3.0 position:CSToastPositionTop];
                    [strongSelf.tableView reloadData];
                });
            }];
        }]];

        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CancelLocKey", nil) style:UIAlertActionStyleCancel handler:nil]];
        
        // iPad 适配
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            alertController.popoverPresentationController.sourceView = self.view;
            alertController.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds), 0, 0);
            alertController.popoverPresentationController.permittedArrowDirections = 0;
        }
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)selectWorkMode {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LocKey.SelectWorkModeAlertTitle", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSDictionary<NSNumber*, NSString*>* workModeNameDictionary = [self workModeNameDictionary];
    NSArray<NSNumber*>* workModeKeys = [self availableWorkModeKeys];
    for(NSNumber* key in workModeKeys)
    {
        [alertController addAction:[UIAlertAction actionWithTitle:workModeNameDictionary[key] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            id<AIBudsDeviceWorkModeAPI> device = (id<AIBudsDeviceWorkModeAPI>)self.device;
            if([device conformsToProtocol:@protocol(AIBudsDeviceWorkModeAPI)]) {
                /// 当前游戏模式固件存在问题，可能导致设备变砖，需要确认是否继续
                AIBudsWorkMode workMode = (AIBudsWorkMode)[key integerValue];
                if (workMode == AIBudsWorkModeGame) {
                    UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LocKey.Warning", nil) message:NSLocalizedString(@"LocKey.GameModeBrickRiskMessage", nil) preferredStyle:UIAlertControllerStyleAlert];
                    
                    [confirmAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"LocKey.Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
                    
                    [confirmAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"LocKey.Continue", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                        [device setWorkMode:workMode completion:^(BOOL success, NSError * _Nullable error) {
                            __strong typeof(self) strongSelf = weakSelf;
                            if(!strongSelf) return;
                            NSString* message = success? NSLocalizedString(@"LocKey.WorkModeSuccessMessage", nil) : [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"LocKey.WorkModeFailedMessage", nil), error.localizedDescription];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [strongSelf.view makeToast:message duration:3.0 position:CSToastPositionTop];
                                [strongSelf.tableView reloadData];
                            });
                        }];
                    }]];
                    
                    // iPad 适配
                    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                        confirmAlert.popoverPresentationController.sourceView = self.view;
                        confirmAlert.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds), 0, 0);
                        confirmAlert.popoverPresentationController.permittedArrowDirections = 0;
                    }
                    
                    [self presentViewController:confirmAlert animated:YES completion:nil];
                } else {
                    [device setWorkMode:workMode completion:^(BOOL success, NSError * _Nullable error) {
                        __strong typeof(self) strongSelf = weakSelf;
                        if(!strongSelf) return;
                        NSString* message = success? NSLocalizedString(@"LocKey.WorkModeSuccessMessage", nil) : [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"LocKey.WorkModeFailedMessage", nil), error.localizedDescription];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [strongSelf.view makeToast:message duration:3.0 position:CSToastPositionTop];
                            [strongSelf.tableView reloadData];
                        });
                    }];
                }
            }
        }]];
    }

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CancelLocKey", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    // iPad 适配
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        alertController.popoverPresentationController.sourceView = self.view;
        alertController.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds), 0, 0);
        alertController.popoverPresentationController.permittedArrowDirections = 0;
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)selectOnDeviceVoiceAssistantMode {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LocKey.SelectOnDeviceVoiceAssistantModeAlertTitle", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSDictionary<NSNumber*, NSString*>* onDeviceVoiceAssistantModeNameDictionary = [self onDeviceVoiceAssistantModeNameDictionary];
    NSArray<NSNumber*>* onDeviceVoiceAssistantModeKeys = [self availableOnDeviceVoiceAssistantModeKeys];
    for(NSNumber* key in onDeviceVoiceAssistantModeKeys)
    {
        [alertController addAction:[UIAlertAction actionWithTitle:onDeviceVoiceAssistantModeNameDictionary[key] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            id<AIBudsOnDeviceVoiceAssistantAPI> device = (id<AIBudsOnDeviceVoiceAssistantAPI>)self.device;
            if([device conformsToProtocol:@protocol(AIBudsOnDeviceVoiceAssistantAPI)]) {
                [device setOnDeviceVoiceAssistantMode:(AIBudsOnDeviceVoiceAssistantMode)[key integerValue] completion:^(BOOL success, NSError * _Nullable error) {
                    __strong typeof(self) strongSelf = weakSelf;
                    if(!strongSelf) return;
                    NSString* message = success? NSLocalizedString(@"LocKey.OnDeviceVoiceAssistantModeSuccessMessage", nil) : [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"LocKey.OnDeviceVoiceAssistantModeFailedMessage", nil), error.localizedDescription];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf.view makeToast:message duration:3.0 position:CSToastPositionTop];
                        [strongSelf.tableView reloadData];
                    });
                }];
            }
        }]];
    }

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CancelLocKey", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    // iPad 适配
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        alertController.popoverPresentationController.sourceView = self.view;
        alertController.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds), 0, 0);
        alertController.popoverPresentationController.permittedArrowDirections = 0;
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)selectAiServiceVendor {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LocKey.SelectAiServiceVendorAlertTitle", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"LocKey.StarBurstAI", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [AIChatContext sharedInstance].settings.serviceVendor = AIBudsAIServiceVendorStarBurst;
        AIChatContext *context = [AIChatContext sharedInstance];
        context.settings.serviceVendor = AIBudsAIServiceVendorStarBurst;
        [AIFeatureContext sharedInstance].serviceVendor = context.settings.serviceVendor;
        [AIBudsAISDK setAIServiceVendor:context.settings.serviceVendor];
        
        AIBudsAIDeviceInfoModel* deviceInfo = [AIBudsAISDK deviceInfo];
        if([deviceInfo isKindOfClass:[AIBudsAIDeviceInfoModel class]])
        {
            AIBudsAIServiceVendor aiServiceVendor = [AIFeatureContext sharedInstance].serviceVendor;
            if([AIBudsAISDK authenticationModeForVendor:aiServiceVendor] == AIBudsAIAuthenticationModeAppInitiated
               && ![AIBudsAISDK isAuthenticatedForVendor:aiServiceVendor]) {
                [AIBudsAISDK authenticateDevice:deviceInfo completion:^(BOOL isSuccess, NSError * _Nullable error) {
                    if([error isKindOfClass:[NSError class]])
                    {
                        XLOG_ERROR(@"%@", APP_LOG_STRING(@"AI 鉴权失败 (vendor = %@)：%@", @(aiServiceVendor), error));
                        return;
                    }
                    XLOG_INFO(@"%@", APP_LOG_STRING(@"AI 鉴权成功 (vendor = %@)。", @(aiServiceVendor)));
                }];
            }
        }
        else
        {
            XLOG_ERROR(@"%@", APP_LOG_STRING(@"设备信息为空，可能设备尚未连接成功。"));
        }
        
        self.aiServiceVendorFeature.valueText = [[[self class] availableAIVendorDictionary] objectForKey:@(AIBudsAIServiceVendorStarBurst)];
        [self.tableView reloadData];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"LocKey.MLTCloudAI", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [AIChatContext sharedInstance].settings.serviceVendor = AIBudsAIServiceVendorMltcloud;
        AIChatContext *context = [AIChatContext sharedInstance];
        context.settings.serviceVendor = AIBudsAIServiceVendorMltcloud;
        [AIFeatureContext sharedInstance].serviceVendor = context.settings.serviceVendor;
        [AIBudsAISDK setAIServiceVendor:context.settings.serviceVendor];
        
        AIBudsAIDeviceInfoModel* deviceInfo = [AIBudsAISDK deviceInfo];
        if([deviceInfo isKindOfClass:[AIBudsAIDeviceInfoModel class]])
        {
            AIBudsAIServiceVendor aiServiceVendor = [AIFeatureContext sharedInstance].serviceVendor;
            if([AIBudsAISDK authenticationModeForVendor:aiServiceVendor] == AIBudsAIAuthenticationModeAppInitiated
               && ![AIBudsAISDK isAuthenticatedForVendor:aiServiceVendor]) {
                [AIBudsAISDK authenticateDevice:deviceInfo completion:^(BOOL isSuccess, NSError * _Nullable error) {
                    if([error isKindOfClass:[NSError class]])
                    {
                        XLOG_ERROR(@"%@", APP_LOG_STRING(@"AI 鉴权失败 (vendor = %@)：%@", @(aiServiceVendor), error));
                        return;
                    }
                    XLOG_INFO(@"%@", APP_LOG_STRING(@"AI 鉴权成功 (vendor = %@)。", @(aiServiceVendor)));
                }];
            }
        }
        else
        {
            XLOG_ERROR(@"%@", APP_LOG_STRING(@"设备信息为空，可能设备尚未连接成功。"));
        }
        
        self.aiServiceVendorFeature.valueText = [[[self class] availableAIVendorDictionary] objectForKey:@(AIBudsAIServiceVendorMltcloud)];
        [self.tableView reloadData];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CancelLocKey", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    // iPad 适配
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        alertController.popoverPresentationController.sourceView = self.view;
        alertController.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds), 0, 0);
        alertController.popoverPresentationController.permittedArrowDirections = 0;
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)device:(id<AIBudsDeviceConvertible>)device didCoProcessorFirmwareVersionChanged:(NSString *)firmwareVersion {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CameraFirmwareVersionChangedNotification" object:firmwareVersion];
}

- (void)device:(id<AIBudsDeviceConvertible>)device didVolumesChanged:(AIBudsVolumesInfoModel *)volumes reason:(enum AIBudsVolumeChangedReason)reason {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VolumesChangedNotification" object:volumes];
}

- (void)deviceDidReady:(id<AIBudsDeviceConvertible>)device {
    
    AIBudsDeviceProduct product = device.product;
    NSString* name = device.name;
    NSString* bluetoothName = device.bluetoothName;
    NSString* macAddress = device.macAddress;
    NSString* model = device.deviceModel;
    NSString* formatedProjNumber = device.formatedProjNumber;
    NSString* formatedFirmwareVersion = device.formatedFirmwareVersion;
    NSString* userID = device.bindUserId;
    
    AIBudsAIDeviceInfoModel* deviceInfo = [[AIBudsAIDeviceInfoModel alloc] initWithProduct:product
                                                                                      name:name
                                                                             bluetoothName:bluetoothName
                                                                                macAddress:macAddress
                                                                                     model:model
                                                                        formatedProjNumber:formatedProjNumber
                                                                   formatedFirmwareVersion:formatedFirmwareVersion
                                                                                    userID:userID
                                                                            additionalInfo:nil];
    
    [AIBudsAISDK setDeviceInfo:deviceInfo];
    AIBudsAIServiceVendor aiServiceVendor = [AIChatContext sharedInstance].settings.serviceVendor;
    [AIBudsAISDK setAIServiceVendor:aiServiceVendor];
    
    if([AIBudsAISDK authenticationModeForVendor:aiServiceVendor] == AIBudsAIAuthenticationModeAppInitiated
       && ![AIBudsAISDK isAuthenticatedForVendor:aiServiceVendor]) {
        [AIBudsAISDK authenticateDevice:deviceInfo completion:^(BOOL isSuccess, NSError * _Nullable error) {
            if([error isKindOfClass:[NSError class]])
            {
                XLOG_ERROR(@"%@", APP_LOG_STRING(@"AI 鉴权失败 (vendor = %@)：%@", @(aiServiceVendor), error));
                return;
            }
            XLOG_INFO(@"%@", APP_LOG_STRING(@"AI 鉴权成功 (vendor = %@)。", @(aiServiceVendor)));
        }];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)device:(id<AIBudsDeviceConvertible>)device didReceiveAiChatSessionEvent:(enum AIBudsAIChatSessionEvent)event {
    switch (event) {
        case AIBudsAIChatSessionEventInitiateWithSCO:
        {
            [AIChatContext sharedInstance].settings.sessionCfg.audioChannel = AIBudsAIChatAudioChannelSco;
            [AIBudsAISDK startAIChatWithConfig:[AIChatContext sharedInstance].settings.sessionCfg
                                    onStartSuccess:^(id<AIBudsAIChatSessionConvertible> _Nonnull session) {
                
            } onStartFailure:^(NSError * _Nonnull error) {
                
            } onChatData:^(AIBudsAIChatDataModel * _Nonnull chatData) {
                
            } onIntent:^(AIBudsAIChatIntentModel * _Nonnull intent) {
                
            } onVoiceData:^(AIBudsAIChatVoiceDataModel * _Nonnull voiceData) {
                
            } onEvent:^(AIBudsAIChatEventModel * _Nonnull event) {
                [self handleAIChatEvent:event];
            } onError:^(NSError * _Nonnull error) {
                
            } onFinish:^(AIBudsAIChatSessionReportModel * _Nonnull report) {
                
            }];
            break;
        }
        case AIBudsAIChatSessionEventInitiateWithOpus:
        {
            __weak typeof(self) weakSelf = self;
            [AIChatContext sharedInstance].settings.sessionCfg.audioChannel = AIBudsAIChatAudioChannelOpusInA2dpOut;
            [AIBudsAISDK startAIChatWithConfig:[AIChatContext sharedInstance].settings.sessionCfg
                                    onStartSuccess:^(id<AIBudsAIChatSessionConvertible> _Nonnull session) {
                [AIChatContext sharedInstance].currentSession = session;
                id<AIBudsDeviceAIChatAPI> aiDevice = (id<AIBudsDeviceAIChatAPI>)device;
                if([aiDevice conformsToProtocol:@protocol(AIBudsDeviceAIChatAPI)]) {
                    [aiDevice reportAIChatStartSuccessWithCompletion:^(BOOL success, NSError * _Nullable error) {
                        
                    }];
                }
            } onStartFailure:^(NSError * _Nonnull error) {
                id<AIBudsDeviceAIChatAPI> aiDevice = (id<AIBudsDeviceAIChatAPI>)device;
                if([aiDevice conformsToProtocol:@protocol(AIBudsDeviceAIChatAPI)]) {
                    [aiDevice reportAIChatStartFailureWithCompletion:^(BOOL success, NSError * _Nullable error) {
                        
                    }];
                }
            } onChatData:^(AIBudsAIChatDataModel * _Nonnull chatData) {
                
            } onIntent:^(AIBudsAIChatIntentModel * _Nonnull intent) {
                [self handleIntent: intent];
            } onVoiceData:^(AIBudsAIChatVoiceDataModel * _Nonnull voiceData) {
                
            } onEvent:^(AIBudsAIChatEventModel * _Nonnull event) {
                [weakSelf handleAIChatEvent:event];
            } onError:^(NSError * _Nonnull error) {
                XLOG_ERROR(@"AI 会话发生错误：%@", error);
                NSString* message = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"LocKey.AIChatErrorMessage", nil), error.localizedDescription];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.view makeToast:message duration:3.0 position:CSToastPositionTop];
                });
            } onFinish:^(AIBudsAIChatSessionReportModel * _Nonnull report) {
                
            }];
            break;
        }
        case AIBudsAIChatSessionEventTerminate:
        {
            [AIBudsAISDK stopAIChat];
            break;
        }
        case AIBudsAIChatSessionEventInterruptByStateConflict:
        {
            [AIBudsAISDK stopAIChat];
            break;
        }
    }

}

- (void)device:(id<AIBudsDeviceConvertible>)device didReceiveOpusAudioData:(NSData *)opusAudioData decodedPCMAudioData:(NSData *)decodedPCMAudioData purpose:(enum AIBudsOpusAudioDataPurpose)purpose {
    switch (purpose) {
        case AIBudsOpusAudioDataPurposeAiChat:
        {
            id<AIBudsAIChatSessionConvertible> session = [AIChatContext sharedInstance].currentSession;
            if(session)
            {
                [session appendInt16PCM:decodedPCMAudioData];
            }
            break;
        }
        case AIBudsOpusAudioDataPurposeAiAudioRecord:
        {
            id<AIBudsAIAudioRecordingSessionConvertible> session = [AIAudioRecordingContext sharedInstance].currentSession;
            if(session)
            {
                [session appendInt16PCM:decodedPCMAudioData];
            }
            break;
        }
        default:
            break;
    }
}

- (void)handleAIChatEvent:(AIBudsAIChatEventModel * _Nonnull)event {
    switch (event.eventType) {
        case AIBudsAIChatEventTypeAutoEndSessionTriggered:
        {
            
            XLOG_INFO(@"触发自动结束会话....");
            id<AIBudsDeviceAIChatAPI> aiDevice = (id<AIBudsDeviceAIChatAPI>)self.device;
            if([aiDevice conformsToProtocol:@protocol(AIBudsDeviceAIChatAPI)]) {
                XLOG_INFO(@"通知设备端结束 AI 对话....");
                [aiDevice reportAIChatStoppedWithCompletion:^(BOOL success, NSError * _Nullable error) {
                    
                }];
            }
        }
            break;
        case AIBudsAIChatEventTypeVadStartSpeaking:
        {
            [AIChatContext sharedInstance].isSpeaking = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VadStartSpeakingNotification" object:nil];
        }
            break;
        case AIBudsAIChatEventTypeVadEndSpeaking:
        {
            [AIChatContext sharedInstance].isSpeaking = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VadEndSpeakingNotification" object:nil];
        }
            break;
        default:
            break;
    }
}

- (void)handleIntent:(AIBudsAIChatIntentModel * _Nonnull)intent {
    switch (intent.intent) {
            
        case AIBudsAIIntentTypePhotoStart:
        {
            id<AIBudsDeviceCameraAPI> aiDevice = (id<AIBudsDeviceCameraAPI>)self.device;
            if([aiDevice conformsToProtocol:@protocol(AIBudsDeviceCameraAPI)]) {
                
                [aiDevice requestPhotoTakingWithCaptureMode:AIBudsCaptureModeCamera completion:^(BOOL success, NSNumber * _Nullable statusCode, NSError * _Nullable error) {
                    
                }];
            }
        }
            break;
        case AIBudsAIIntentTypePhotoUnderstand:
        {
            id<AIBudsDeviceCameraAPI> aiDevice = (id<AIBudsDeviceCameraAPI>)self.device;
            if([aiDevice conformsToProtocol:@protocol(AIBudsDeviceCameraAPI)]) {
                
                [aiDevice requestPhotoTakingWithCaptureMode:AIBudsCaptureModeAi completion:^(BOOL success, NSNumber * _Nullable statusCode, NSError * _Nullable error) {
                    
                }];
            }
        }
            break;
        case AIBudsAIIntentTypeAudioRecording:
        {
            id<AIBudsDeviceAudioRecordingAPI> aiDevice = (id<AIBudsDeviceAudioRecordingAPI>)self.device;
            if([aiDevice conformsToProtocol:@protocol(AIBudsDeviceAudioRecordingAPI)]) {
                
                [aiDevice requestStartAudioRecordingWithCompletion:^(BOOL success, NSNumber * _Nullable statusCode, NSError * _Nullable error) {
                    
                }];
            }
        }
            break;
        case AIBudsAIIntentTypeVideoStart:
        {
            id<AIBudsDeviceCameraAPI> aiDevice = (id<AIBudsDeviceCameraAPI>)self.device;
            if([aiDevice conformsToProtocol:@protocol(AIBudsDeviceCameraAPI)]) {
                
                [aiDevice requestVideoRecordingWithCompletion:^(BOOL success, NSNumber * _Nullable statusCode, NSError * _Nullable error) {
                    
                }];
            }
        }
            break;
        case AIBudsAIIntentTypeVideoStop:
        {
            id<AIBudsDeviceCameraAPI> aiDevice = (id<AIBudsDeviceCameraAPI>)self.device;
            if([aiDevice conformsToProtocol:@protocol(AIBudsDeviceCameraAPI)]) {
                
                [aiDevice requestStopPhotoTakingWithCompletion:^(BOOL success, NSNumber * _Nullable statusCode, NSError * _Nullable error) {
                    
                }];
            }
        }
            break;
        case AIBudsAIIntentTypeVolumeUp:
        {
            id<AIBudsDeviceMusicControlAPI> aiDevice = (id<AIBudsDeviceMusicControlAPI>)self.device;
            if([aiDevice conformsToProtocol:@protocol(AIBudsDeviceMusicControlAPI)]) {
                
                [aiDevice musicVolumeUpWithCompletion:^(BOOL success, NSError * _Nullable error) {
                    
                }];
            }
        }
            break;
        case AIBudsAIIntentTypeVolumeDown:
        {
            id<AIBudsDeviceMusicControlAPI> aiDevice = (id<AIBudsDeviceMusicControlAPI>)self.device;
            if([aiDevice conformsToProtocol:@protocol(AIBudsDeviceMusicControlAPI)]) {
                
                [aiDevice musicVolumeDownWithCompletion:^(BOOL success, NSError * _Nullable error) {
                    
                }];
            }
        }
            break;
        case AIBudsAIIntentTypeVolumeSet:
        {
            id<AIBudsDeviceMusicControlAPI> aiDevice = (id<AIBudsDeviceMusicControlAPI>)self.device;
            if([aiDevice conformsToProtocol:@protocol(AIBudsDeviceMusicControlAPI)]) {
                NSInteger volumeValue = [[intent.valueDictionary objectForKey:@"volume"] integerValue];
                [aiDevice setMusicVolume:volumeValue completion:^(BOOL success, NSError * _Nullable error) {
                    
                }];
            }
        }
            break;
        case AIBudsAIIntentTypeDialogExit:
        {
            id<AIBudsDeviceAIChatAPI> aiDevice = (id<AIBudsDeviceAIChatAPI>)self.device;
            if([aiDevice conformsToProtocol:@protocol(AIBudsDeviceAIChatAPI)]) {
                XLOG_INFO(@"通知设备端结束 AI 对话....");
                [aiDevice reportAIChatStoppedWithCompletion:^(BOOL success, NSError * _Nullable error) {
                    
                }];
            }
            [AIBudsAISDK stopAIChat];
        }
            break;
        case AIBudsAIIntentTypeDevicePowerOff:
        {
            id<AIBudsDeviceCommonAPI> aiDevice = (id<AIBudsDeviceCommonAPI>)self.device;
            if([aiDevice conformsToProtocol:@protocol(AIBudsDeviceCommonAPI)]) {
                
                [aiDevice powerOffWithCompletion:^(BOOL success, NSError * _Nullable error) {
                    
                }];
            }
        }
            break;
        case AIBudsAIIntentTypeMusicPlay:
        {
            id<AIBudsDeviceMusicControlAPI> aiDevice = (id<AIBudsDeviceMusicControlAPI>)self.device;
            if([aiDevice conformsToProtocol:@protocol(AIBudsDeviceMusicControlAPI)]) {
                
                [aiDevice playMusicWithCompletion:^(BOOL success, NSError * _Nullable error) {
                    
                }];
            }
        }
            break;
        case AIBudsAIIntentTypeMusicNext:
        {
            id<AIBudsDeviceMusicControlAPI> aiDevice = (id<AIBudsDeviceMusicControlAPI>)self.device;
            if([aiDevice conformsToProtocol:@protocol(AIBudsDeviceMusicControlAPI)]) {
                
                [aiDevice playNextMusicWithCompletion:^(BOOL success, NSError * _Nullable error) {
                    
                }];
            }
        }
            break;
        case AIBudsAIIntentTypeMusicPrev:
        {
            id<AIBudsDeviceMusicControlAPI> aiDevice = (id<AIBudsDeviceMusicControlAPI>)self.device;
            if([aiDevice conformsToProtocol:@protocol(AIBudsDeviceMusicControlAPI)]) {
                
                [aiDevice playPreviousMusicWithCompletion:^(BOOL success, NSError * _Nullable error) {
                    
                }];
            }
        }
            break;
        case AIBudsAIIntentTypeMusicStop:
        {
            id<AIBudsDeviceMusicControlAPI> aiDevice = (id<AIBudsDeviceMusicControlAPI>)self.device;
            if([aiDevice conformsToProtocol:@protocol(AIBudsDeviceMusicControlAPI)]) {
                
                [aiDevice pauseMusicWithCompletion:^(BOOL success, NSError * _Nullable error) {
                    
                }];
            }
        }
            break;
        case AIBudsAIIntentTypeDeviceBattery:
        {
            id<AIBudsDeviceInfoAPI> aiDevice = (id<AIBudsDeviceInfoAPI>)self.device;
            if([aiDevice conformsToProtocol:@protocol(AIBudsDeviceInfoAPI)]) {
                
                //AIBudsBatteryStatusModel* batteryStatusInfo = aiDevice.batteryStatusInfo;
                
                /// do something
            }
        }
            break;
        default:
        {
            
        }
            break;
    }
}

- (void)device:(id<AIBudsDeviceConvertible>)device didReceivePhotoDataForSceneRecognition:(NSData *)photoData enhancedPhotoData:(NSData *)enhancedPhotoData error:(NSError *)error {
    id<AIBudsAIChatSessionConvertible> session = [AIChatContext sharedInstance].currentSession;
    if(session)
    {
        [session sendImageForPhotoUnderstanding:[UIImage imageWithData:photoData] prompt:nil];
    }
}

- (void)device:(id<AIBudsDeviceConvertible>)device didEQSettingChanged:(AIBudsEQSettingModel *)eqSetting {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"EQSettingChanged" object:nil userInfo:nil];
}

- (void)device:(id<AIBudsDeviceConvertible>)device didReceiveRemoteShutterEvent:(AIBudsRemoteShutterEvent)event {
    switch (event) {
        case AIBudsRemoteShutterEventExit:
        {
            // 退出相机
            XLOG_INFO(@"退出相机");
            NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
            [notification postNotificationName:@"RemoteShutterExit" object:nil userInfo:nil];
        }
            break;
        case AIBudsRemoteShutterEventEnter:
        {
            // 进入相机
            XLOG_INFO(@"进入相机");
            
            UINavigationController *navController = self.navigationController;
            UIViewController *topViewController = navController.topViewController;
            if (![NSStringFromClass([topViewController class]) isEqualToString:@"RemoteShutterDemoController"]) {
                // 使用 Runtime 打开 RemoteShutterDemoController
                Class remoteShutterClass = NSClassFromString(@"RemoteShutterDemoController");
                if (remoteShutterClass) {
                    FeatureDemoBaseController *remoteShutterVC = [[remoteShutterClass alloc] initWithDevice:self.device];
                    if (remoteShutterVC) {
                        [navController pushViewController:remoteShutterVC animated:YES];
                    }
                }
            }
        }
            break;
        case AIBudsRemoteShutterEventCapture:
        {
            // 拍照
            XLOG_INFO(@"拍照");
            NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
            [notification postNotificationName:@"RemoteShutterCapture" object:nil userInfo:nil];
        }
            break;
        case AIBudsRemoteShutterEventUnknown:
        default:
        {
            XLOG_ERROR(@"未知事件");
        }
            break;
    }
}

-(void)device:(id<AIBudsDeviceConvertible>)device didMediaCountInfoChanged:(AIBudsMediaCountInfoModel *)mediaCountInfo {
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification postNotificationName:@"MediaCountChanged" object:nil userInfo:nil];
}

@end
