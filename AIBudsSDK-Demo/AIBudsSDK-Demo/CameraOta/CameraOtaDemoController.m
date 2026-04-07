//
//  CameraOtaDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-03-11.
//  Copyright © 2026 Zero Status. All rights reserved.
//


#import "CameraOtaDemoController.h"
#import <MobileCoreServices/MobileCoreServices.h>

typedef NS_ENUM(NSInteger, CameraOtaState) {
    CameraOtaStateIdle,
    CameraOtaStateSelectingFile,
    CameraOtaStateReady,
    CameraOtaStateUpgrading,
    CameraOtaStateSuccess,
    CameraOtaStateFailed
};

typedef NS_ENUM(NSInteger, OtaPhase) {
    OtaPhaseIdle,
    OtaPhaseFileTransfer,
    OtaPhaseFlashing,
    OtaPhaseCompleted,
    OtaPhaseFailed
};

@interface CameraOtaDemoController () <UIDocumentPickerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *selectFileButton;
@property (nonatomic, strong) UILabel *fileInfoLabel;
@property (nonatomic, strong) UIButton *upgradeButton;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UITableView *logTableView;
@property (nonatomic, strong) NSMutableArray<NSString *> *logs;

@property (nonatomic, strong) NSString *selectedFilePath;
@property (nonatomic, assign) CameraOtaState currentState;
@property (nonatomic, assign) OtaPhase currentPhase;
@property (nonatomic, assign) float currentProgress;

@end

@implementation CameraOtaDemoController

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    [self setupUI];
    [self updateUIForState:CameraOtaStateIdle];
    self.logs = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCameraFirmwareVersionChanged:) name:@"CameraFirmwareVersionChangedNotification" object:nil];
}

-(void)onCameraFirmwareVersionChanged:(NSNotification*)notification {
    NSString* firmwareVersion = notification.object;
    if([firmwareVersion isKindOfClass:[NSString class]])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addLog:[NSString stringWithFormat:NSLocalizedString(@"LocKey.LogInfoLatestCameraFirmwareVersionFormat", nil), firmwareVersion]];
        });
    }
}

#pragma mark - UI Setup

- (void)setupUI {
    // 标题
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = NSLocalizedString(@"LocKey.CameraOtaDemoTitle", nil);
    self.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor labelColor];
    [self.view addSubview:self.titleLabel];
    
    // 选择文件按钮
    self.selectFileButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.selectFileButton setTitle:NSLocalizedString(@"LocKey.OtaSelectFileButtonTitle", nil) forState:UIControlStateNormal];
    self.selectFileButton.backgroundColor = [UIColor systemBlueColor];
    [self.selectFileButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.selectFileButton.layer.cornerRadius = 12;
    self.selectFileButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.selectFileButton addTarget:self action:@selector(selectFileTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.selectFileButton];
    
    // 文件信息标签
    self.fileInfoLabel = [[UILabel alloc] init];
    self.fileInfoLabel.font = [UIFont systemFontOfSize:14];
    self.fileInfoLabel.textColor = [UIColor secondaryLabelColor];
    self.fileInfoLabel.numberOfLines = 0;
    self.fileInfoLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.fileInfoLabel];
    
    // 升级按钮
    self.upgradeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.upgradeButton.backgroundColor = [UIColor systemGreenColor];
    [self.upgradeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.upgradeButton.layer.cornerRadius = 12;
    self.upgradeButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.upgradeButton addTarget:self action:@selector(upgradeTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.upgradeButton];
    
    // 进度条
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.progressTintColor = [UIColor systemGreenColor];
    self.progressView.trackTintColor = [UIColor systemGray5Color];
    self.progressView.layer.cornerRadius = 4;
    self.progressView.clipsToBounds = YES;
    [self.view addSubview:self.progressView];
    
    // 进度标签
    self.progressLabel = [[UILabel alloc] init];
    self.progressLabel.font = [UIFont systemFontOfSize:14];
    self.progressLabel.textColor = [UIColor secondaryLabelColor];
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.progressLabel];
    
    // 日志表格
    self.logTableView = [[UITableView alloc] init];
    self.logTableView.backgroundColor = [UIColor systemGray6Color];
    self.logTableView.layer.cornerRadius = 12;
    self.logTableView.dataSource = self;
    self.logTableView.delegate = self;
    self.logTableView.estimatedRowHeight = 44;
    self.logTableView.rowHeight = UITableViewAutomaticDimension;
    [self.logTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"LogCell"];
    [self.view addSubview:self.logTableView];
    
    // 布局
    [self layoutSubviews];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutSubviews];
}

- (void)layoutSubviews {
    CGFloat margin = 20;
    CGFloat spacing = 16;
    CGFloat buttonHeight = 50;
    
    self.titleLabel.frame = CGRectMake(margin, 100, self.view.bounds.size.width - 2 * margin, 40);
    
    self.selectFileButton.frame = CGRectMake(margin, CGRectGetMaxY(self.titleLabel.frame) + spacing, self.view.bounds.size.width - 2 * margin, buttonHeight);
    
    self.fileInfoLabel.frame = CGRectMake(margin, CGRectGetMaxY(self.selectFileButton.frame) + spacing, self.view.bounds.size.width - 2 * margin, 60);
    
    self.upgradeButton.frame = CGRectMake(margin, CGRectGetMaxY(self.fileInfoLabel.frame) + spacing, self.view.bounds.size.width - 2 * margin, buttonHeight);
    
    self.progressView.frame = CGRectMake(margin, CGRectGetMaxY(self.upgradeButton.frame) + spacing, self.view.bounds.size.width - 2 * margin, 8);
    
    self.progressLabel.frame = CGRectMake(margin, CGRectGetMaxY(self.progressView.frame) + 8, self.view.bounds.size.width - 2 * margin, 30);
    
    self.logTableView.frame = CGRectMake(margin, CGRectGetMaxY(self.progressLabel.frame) + spacing, self.view.bounds.size.width - 2 * margin, self.view.bounds.size.height - CGRectGetMaxY(self.progressLabel.frame) - spacing - 40);
}

#pragma mark - State Management

- (void)updateUIForState:(CameraOtaState)state {
    self.currentState = state;
    
    switch (state) {
        case CameraOtaStateIdle:
            [self.upgradeButton setTitle:NSLocalizedString(@"LocKey.StartUpgradeButtonTitle", nil) forState:UIControlStateNormal];
            self.upgradeButton.enabled = NO;
            self.upgradeButton.backgroundColor = [UIColor systemGrayColor];
            self.progressView.progress = 0;
            self.progressLabel.text = @"";
            break;
        case CameraOtaStateSelectingFile:
            self.selectFileButton.enabled = NO;
            break;
        case CameraOtaStateReady:
            [self.upgradeButton setTitle:NSLocalizedString(@"LocKey.StartUpgradeButtonTitle", nil) forState:UIControlStateNormal];
            self.upgradeButton.enabled = YES;
            self.upgradeButton.backgroundColor = [UIColor systemGreenColor];
            break;
        case CameraOtaStateUpgrading:
            [self.upgradeButton setTitle:NSLocalizedString(@"LocKey.UpgradingButtonTitle", nil) forState:UIControlStateNormal];
            self.upgradeButton.enabled = NO;
            self.upgradeButton.backgroundColor = [UIColor systemOrangeColor];
            self.selectFileButton.enabled = NO;
            break;
        case CameraOtaStateSuccess:
            [self.upgradeButton setTitle:NSLocalizedString(@"LocKey.UpgradeSuccessButtonTitle", nil) forState:UIControlStateNormal];
            self.upgradeButton.enabled = NO;
            self.upgradeButton.backgroundColor = [UIColor systemGreenColor];
            self.selectFileButton.enabled = YES;
            break;
        case CameraOtaStateFailed:
            [self.upgradeButton setTitle:NSLocalizedString(@"LocKey.UpgradeFailedButtonTitle", nil) forState:UIControlStateNormal];
            self.upgradeButton.enabled = NO;
            self.upgradeButton.backgroundColor = [UIColor systemRedColor];
            self.selectFileButton.enabled = YES;
            break;
    }
}

#pragma mark - Actions

- (void)selectFileTapped {
    [self updateUIForState:CameraOtaStateSelectingFile];
    
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[(__bridge NSString *)kUTTypeData] inMode:UIDocumentPickerModeOpen];
    picker.delegate = self;
    picker.allowsMultipleSelection = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)upgradeTapped {
    if (!self.selectedFilePath.length) {
        [self addLog:NSLocalizedString(@"LocKey.OtaStatusNoFirmwareSelected", nil)];
        return;
    }
    
    [self updateUIForState:CameraOtaStateUpgrading];
    //[self addLog:NSLocalizedString(@"LocKey.LogInfoStartingOtaUpgrade", nil)];
    
    //OTA 升级流程
    [self startUpgrade];
}

#pragma mark - Document Picker Delegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
   
    if (urls.count > 0) {
        NSURL *fileURL = urls.firstObject;
        
        // 获取授权
        [fileURL startAccessingSecurityScopedResource];
        
        // 通过文件协调工具来得到新的文件地址，以此得到文件保护功能
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;
        
        [fileCoordinator coordinateReadingItemAtURL:fileURL options:0 error:&error byAccessor:^(NSURL *newURL) {
            // 获取文件大小
            NSError *error;
            // 将文件拷贝到缓存目录
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
            NSString *fileName = newURL.lastPathComponent ?: @"firmware.fot";
            NSString *cachePath = [cacheDir stringByAppendingPathComponent:fileName];
            NSURL *cacheURL = [NSURL fileURLWithPath:cachePath];
            
            NSError *copyError;
            [fileManager removeItemAtURL:cacheURL error:nil]; // 先删除旧文件
            if (![fileManager copyItemAtURL:newURL toURL:cacheURL error:&copyError]) {
                self.fileInfoLabel.text = NSLocalizedString(@"LocKey.OtaStatusCopyFailed", nil);
                return;
            }
            
            self.selectedFilePath = cacheURL.path;
            NSNumber *fileSize;
            [cacheURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:&error];
            NSString *sizeString = [NSByteCountFormatter stringFromByteCount:fileSize.longLongValue countStyle:NSByteCountFormatterCountStyleFile];
            self.fileInfoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.SelectedFileInfoFormat", nil), fileName, sizeString];
            [self addLog:[NSString stringWithFormat:NSLocalizedString(@"LocKey.LogInfoSelectedFileInfoFormat", nil), fileName, sizeString]];
            [self updateUIForState:CameraOtaStateReady];
        }];
        [fileURL stopAccessingSecurityScopedResource];
        
        
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    [self updateUIForState:CameraOtaStateIdle];
}

#pragma mark - 升级逻辑

- (void)startUpgrade {
    

    id<AIBudsDeviceCameraOtaAPI> device = (id<AIBudsDeviceCameraOtaAPI>)self.device;
    if([device conformsToProtocol:@protocol(AIBudsDeviceCameraOtaAPI)]) {
        [device startCameraOtaWithFilePath:self.selectedFilePath configureHotspotStartingHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addLog:NSLocalizedString(@"LocKey.LogInfoStartingToConfigureDeviceHotspot", nil)];
            });
        } hotspotConfigureCompletionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    [self addLog:NSLocalizedString(@"LocKey.LogInfoConfigureDeviceHotspotSuccess", nil)];
                    self.currentPhase = OtaPhaseFileTransfer;
                }
                else {
                    [self addLog:[NSString stringWithFormat:NSLocalizedString(@"LocKey.LogInfoConfigureDeviceHotspotFailedFormat", nil), [error isKindOfClass:[NSError class]] ? error.localizedDescription : @"Unknown error"]];
                    self.currentPhase = OtaPhaseFailed;
                    
                }
            });
        } enterCameraOtaModeStartingHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addLog:NSLocalizedString(@"LocKey.LogInfoStartingToEnterCameraOtaMode", nil)];
            });
        } enterCameraOtaModeCompletedHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    [self addLog:NSLocalizedString(@"LocKey.LogInfoEnterCameraOtaModeSuccess", nil)];
                } else {
                    [self addLog:[NSString stringWithFormat:NSLocalizedString(@"LocKey.LogInfoEnterCameraOtaModeFailedFormat", nil), [error isKindOfClass:[NSError class]] ? error.localizedDescription : @"Unknown error"]];
                    self.currentPhase = OtaPhaseFailed;
                }
            });
        } waitingForHotspotOpenHandler:^ {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addLog:NSLocalizedString(@"LocKey.LogInfoStartingToWaitForHotspotOpen", nil)];
            });
        } connectDeviceHotspotStartingHandler:^(NSString* ssid){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addLog:[NSString stringWithFormat:NSLocalizedString(@"LocKey.LogInfoStartingToConnectDeviceHotspotFormat", nil), ssid]];
            });
        } deviceHotspotConnectCompletionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    [self addLog:NSLocalizedString(@"LocKey.LogInfoConnectDeviceHotspotSuccess", nil)];
                } else {
                    [self addLog:[NSString stringWithFormat:NSLocalizedString(@"LocKey.LogInfoConnectDeviceHotspotFailedFormat", nil), [error isKindOfClass:[NSError class]] ? error.localizedDescription : @"Unknown error"]];
                    self.currentPhase = OtaPhaseFailed;
                }
            });
        } httpServerStartingHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addLog:NSLocalizedString(@"LocKey.LogInfoStartingHttpServer", nil)];
            });
        } httpServerStartCompletionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    [self addLog:NSLocalizedString(@"LocKey.LogInfoHttpServerStarted", nil)];
                } else {
                    [self addLog:[NSString stringWithFormat:NSLocalizedString(@"LocKey.LogInfoHttpServerStartFailedFormat", nil), [error isKindOfClass:[NSError class]] ? error.localizedDescription : @"Unknown error"]];
                    self.currentPhase = OtaPhaseFailed;
                }
            });
        } sendingFirmwareUrlHandler:^(NSString* firmwareUrl){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addLog:[NSString stringWithFormat:NSLocalizedString(@"LocKey.LogInfoSendingFirmwareUrlFormat", nil), firmwareUrl]];
            });
        } firmwareUrlSendCompletionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    [self addLog:NSLocalizedString(@"LocKey.LogInfoFirmwareUrlSent", nil)];
                } else {
                    [self addLog:[NSString stringWithFormat:NSLocalizedString(@"LocKey.LogInfoFirmwareUrlSendFailedFormat", nil), [error isKindOfClass:[NSError class]] ? error.localizedDescription : @"Unknown error"]];
                    self.currentPhase = OtaPhaseFailed;
                }
            });
        } startCompletionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    [self addLog:NSLocalizedString(@"LocKey.LogInfoOtaUpgradeStarted", nil)];
                    self.currentPhase = OtaPhaseFileTransfer;
                }
                else {
                    [self addLog:[NSString stringWithFormat:NSLocalizedString(@"LocKey.LogInfoOtaUpgradeStartFailedFormat", nil), [error isKindOfClass:[NSError class]] ? error.localizedDescription : @"Unknown error"]];
                    self.currentPhase = OtaPhaseFailed;
                    
                }
            });
        } fileTransferStartedHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addLog:NSLocalizedString(@"LocKey.LogInfoFileTransferStarted", nil)];
            });
        } fileTransferCompletedHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addLog:NSLocalizedString(@"LocKey.LogInfoFileTransferCompleted", nil)];
                self.currentPhase = OtaPhaseFlashing;
            });
        } waitingForFlashingHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addLog:NSLocalizedString(@"LocKey.LogInfoWaitingForFlashing", nil)];
            });
        } flashingStartedHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addLog:NSLocalizedString(@"LocKey.LogInfoFlashingStarted", nil)];
            });
            
        } flashingCompletedHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addLog:NSLocalizedString(@"LocKey.LogInfoFlashingCompleted", nil)];
                self.currentPhase = OtaPhaseCompleted;
            });
            
        } phaseProgressHandler:^(AIBudsCameraOtaProgressPhase phase, NSInteger progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progressView.progress = (CGFloat)progress / 100.0;
                if (phase == AIBudsCameraOtaProgressPhaseTransferring) {
                    self.progressLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.LogInfoFileTransferredInfoFormat", nil), @(progress)];
                    [self addLog:[NSString stringWithFormat:NSLocalizedString(@"LocKey.LogInfoFileTransferredInfoFormat", nil), @(progress)]];
                }
                else if(phase == AIBudsCameraOtaProgressPhaseFlashing) {
                    self.progressLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.LogInfoFlashingProgressInfoFormat", nil), @(progress)];
                    [self addLog:[NSString stringWithFormat:NSLocalizedString(@"LocKey.LogInfoFlashingProgressInfoFormat", nil), @(progress)]];
                }
            });
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    [self updateUIForState:CameraOtaStateSuccess];
                    [self addLog:NSLocalizedString(@"LocKey.LogInfoOtaUpgradeSucceeded", nil)];
                }
                else {
                    [self updateUIForState:CameraOtaStateFailed];
                    [self addLog:NSLocalizedString(@"LocKey.LogInfoOtaUpgradeFailed", nil)];
                }
            });
            
        }];
        /*[device startOtaWithFilePath:self.selectedFileURL.path startHandler:^(BOOL success, NSError * _Nullable error) {
            if(!success) {
                NSString* errorDesc = [error isKindOfClass:[NSError class]] ? error.localizedDescription : NSLocalizedString(@"LocKey.OtaStatusUnknownError", nil);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.OtaStatusFailedFormat", nil), errorDesc];
                });
                return;
            }
        } progressHandler:^(CGFloat progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.percentLabel.text = [NSString stringWithFormat:@"%.0f%%", progress * 100];
                self.progressView.progress = progress;
            });
        } completionHandler:^(BOOL success, CGFloat avgSpeed, NSError * _Nullable error) {
            if(!success) {
                NSString* errorDesc = [error isKindOfClass:[NSError class]] ? error.localizedDescription : NSLocalizedString(@"LocKey.OtaStatusUnknownError", nil);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.OtaStatusFailedFormat", nil), errorDesc];
                });
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.statusLabel.text = NSLocalizedString(@"LocKey.OtaStatusSuccess", nil);
                 [self showResult:avgSpeed];
            });
        }];*/
    }
    
}

#pragma mark - OTA Simulation

/*- (void)simulateOtaUpgrade {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 模拟开始升级
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addLog:NSLocalizedString(@"LocKey.LogProgressOtaUpgradeStarted", nil)];
            self.currentPhase = OtaPhaseFileTransfer;
        });
        
        // 模拟文件传输阶段
        for (int i = 0; i <= 100; i += 5) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progressView.progress = i / 100.0;
                self.progressLabel.text = [NSString stringWithFormat:NSLocalizedString(@"File Transfer: %d%%", nil), i];
                if (i == 0) {
                    [self addLog:NSLocalizedString(@"File transfer started", nil)];
                }
            });
            [NSThread sleepForTimeInterval:0.1];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addLog:NSLocalizedString(@"File transfer completed", nil)];
            self.currentPhase = OtaPhaseFlashing;
        });
        
        // 模拟等待刷写
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addLog:NSLocalizedString(@"Waiting for flashing...", nil)];
        });
        [NSThread sleepForTimeInterval:1.0];
        
        // 模拟刷写阶段
        for (int i = 0; i <= 100; i += 10) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progressView.progress = i / 100.0;
                self.progressLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Flashing: %d%%", nil), i];
                if (i == 0) {
                    [self addLog:NSLocalizedString(@"Flashing started", nil)];
                }
            });
            [NSThread sleepForTimeInterval:0.2];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addLog:NSLocalizedString(@"Flashing completed", nil)];
            self.currentPhase = OtaPhaseCompleted;
            
            // 模拟成功或失败（90% 成功率）
            BOOL success = (arc4random_uniform(100) < 90);
            if (success) {
                [self updateUIForState:CameraOtaStateSuccess];
                [self addLog:NSLocalizedString(@"OTA upgrade succeeded", nil)];
            } else {
                [self updateUIForState:CameraOtaStateFailed];
                [self addLog:NSLocalizedString(@"OTA upgrade failed", nil)];
            }
        });
    });
}*/

#pragma mark - Logging

- (void)addLog:(NSString *)message {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss";
    NSString *timestamp = [formatter stringFromDate:[NSDate date]];
    
    NSString *log = [NSString stringWithFormat:@"[%@] %@", timestamp, message];
    [self.logs addObject:log];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.logTableView reloadData];
        [self.logTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.logs.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
}

#pragma mark - UITableView DataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.logs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogCell" forIndexPath:indexPath];
    cell.textLabel.text = self.logs[indexPath.row];
    cell.textLabel.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    cell.textLabel.numberOfLines = 0;
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
