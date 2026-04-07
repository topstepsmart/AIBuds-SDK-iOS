//
//  OTADemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-03-02.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "OTADemoController.h"
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface OTADemoController () <UIDocumentPickerDelegate>

// 升级进度相关 UI
@property (nonatomic, strong) UIProgressView *progressView;        // 进度条
@property (nonatomic, strong) UILabel *percentLabel;               // 百分比文字
@property (nonatomic, strong) UILabel *filePathLabel;              // 升级文件路径
@property (nonatomic, strong) UILabel *statusLabel;                // 状态描述
@property (nonatomic, strong) UIButton *startButton;               // 开始升级按钮
@property (nonatomic, strong) UIButton *cancelButton;              // 取消升级按钮
@property (nonatomic, strong) UIButton *selectFileButton;          // 选择文件按钮

// 升级结果相关 UI
@property (nonatomic, strong) UIView *resultContainer;               // 结果展示容器
@property (nonatomic, strong) UILabel *fileSizeLabel;                // 文件大小
@property (nonatomic, strong) UILabel *transferredBytesLabel;      // 本次传输字节数
@property (nonatomic, strong) UILabel *totalTimeLabel;             // 总耗时
@property (nonatomic, strong) UILabel *pausedTimeLabel;            // 暂停时间
@property (nonatomic, strong) UILabel *actualTimeLabel;            // 实际用时
@property (nonatomic, strong) UILabel *avgSpeedLabel;              // 平均速度 kB/s

// 数据记录
@property (nonatomic, assign) NSTimeInterval startTime;              // 开始时间
@property (nonatomic, assign) NSTimeInterval pausedTime;           // 暂停时间
@property (nonatomic, assign) BOOL isPaused;                         // 是否暂停
@property (nonatomic, assign) CGFloat lastProgress;                // 上一次进度
@property (nonatomic, strong) NSTimer *progressTimer;                // 模拟进度计时器
@property (nonatomic, strong) NSURL *selectedFileURL;                // 选中的文件 URL
@property (nonatomic, strong) NSNumber* selectedFileSize;              // 选中的文件大小 (Bytes)

@end

@implementation OTADemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.97 alpha:1.0];
    [self setupUI];
}

#pragma mark - UI 构建

- (void)setupUI {
    // 顶部标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.OtaDemoTitle", nil);
    titleLabel.font = [UIFont boldSystemFontOfSize:22];
    titleLabel.textColor = [UIColor colorWithRed:0.15 green:0.25 blue:0.45 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor]
    ]];

    // 进度条容器
    UIView *progressCard = [self createCard];
    [self.view addSubview:progressCard];
    progressCard.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [progressCard.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:30],
        [progressCard.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [progressCard.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [progressCard.heightAnchor constraintEqualToConstant:180]
    ]];

    // 进度条
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.progressTintColor = [UIColor colorWithRed:0.20 green:0.60 blue:1.00 alpha:1.0];
    self.progressView.trackTintColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
    self.progressView.layer.cornerRadius = 6;
    self.progressView.clipsToBounds = YES;
    [progressCard addSubview:self.progressView];
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.progressView.topAnchor constraintEqualToAnchor:progressCard.topAnchor constant:20],
        [self.progressView.leadingAnchor constraintEqualToAnchor:progressCard.leadingAnchor constant:20],
        [self.progressView.trailingAnchor constraintEqualToAnchor:progressCard.trailingAnchor constant:-20],
        [self.progressView.heightAnchor constraintEqualToConstant:12]
    ]];

    // 百分比文字
    self.percentLabel = [[UILabel alloc] init];
    self.percentLabel.text = @"0%";
    self.percentLabel.font = [UIFont boldSystemFontOfSize:18];
    self.percentLabel.textColor = [UIColor colorWithRed:0.15 green:0.25 blue:0.45 alpha:1.0];
    self.percentLabel.textAlignment = NSTextAlignmentCenter;
    [progressCard addSubview:self.percentLabel];
    self.percentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.percentLabel.topAnchor constraintEqualToAnchor:self.progressView.bottomAnchor constant:12],
        [self.percentLabel.centerXAnchor constraintEqualToAnchor:progressCard.centerXAnchor]
    ]];

    // 文件路径
    self.filePathLabel = [[UILabel alloc] init];
    self.filePathLabel.text = NSLocalizedString(@"LocKey.OtaStatusNoFirmwareSelected", nil);
    self.filePathLabel.font = [UIFont systemFontOfSize:14];
    self.filePathLabel.textColor = [UIColor grayColor];
    self.filePathLabel.numberOfLines = 1;
    self.filePathLabel.lineBreakMode = NSLineBreakByTruncatingHead;
    [progressCard addSubview:self.filePathLabel];
    self.filePathLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.filePathLabel.topAnchor constraintEqualToAnchor:self.percentLabel.bottomAnchor constant:8],
        [self.filePathLabel.leadingAnchor constraintEqualToAnchor:progressCard.leadingAnchor constant:20],
        [self.filePathLabel.trailingAnchor constraintEqualToAnchor:progressCard.trailingAnchor constant:-20]
    ]];

    // 选择文件按钮
    self.selectFileButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.selectFileButton setTitle:NSLocalizedString(@"LocKey.OtaSelectFileButtonTitle", nil) forState:UIControlStateNormal];
    self.selectFileButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.selectFileButton setTitleColor:[UIColor colorWithRed:0.20 green:0.60 blue:1.00 alpha:1.0] forState:UIControlStateNormal];
    [self.selectFileButton addTarget:self action:@selector(selectFirmwareFile) forControlEvents:UIControlEventTouchUpInside];
    [progressCard addSubview:self.selectFileButton];
    self.selectFileButton.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.selectFileButton.topAnchor constraintEqualToAnchor:self.filePathLabel.bottomAnchor constant:8],
        [self.selectFileButton.trailingAnchor constraintEqualToAnchor:progressCard.trailingAnchor constant:-20],
        [self.selectFileButton.heightAnchor constraintEqualToConstant:30]
    ]];

    // 状态描述
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = NSLocalizedString(@"LocKey.OtaStatusWaiting", nil);
    self.statusLabel.font = [UIFont systemFontOfSize:14];
    self.statusLabel.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
    [progressCard addSubview:self.statusLabel];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.selectFileButton.bottomAnchor constant:8],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:progressCard.leadingAnchor constant:20],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:progressCard.trailingAnchor constant:-20]
    ]];

    // 按钮容器
    UIView *buttonContainer = [[UIView alloc] init];
    [self.view addSubview:buttonContainer];
    buttonContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [buttonContainer.topAnchor constraintEqualToAnchor:progressCard.bottomAnchor constant:20],
        [buttonContainer.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [buttonContainer.heightAnchor constraintEqualToConstant:44]
    ]];

    // 开始升级按钮
    self.startButton = [self createButtonWithTitle:NSLocalizedString(@"LocKey.OtaStartButtonTitle", nil)];
    self.startButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.startButton.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 16);
    [self.startButton addTarget:self action:@selector(startUpgrade) forControlEvents:UIControlEventTouchUpInside];
    self.startButton.enabled = NO;
    [buttonContainer addSubview:self.startButton];
    self.startButton.translatesAutoresizingMaskIntoConstraints = NO;

    // 取消升级按钮
    self.cancelButton = [self createButtonWithTitle:NSLocalizedString(@"LocKey.OtaCancelButtonTitle", nil)];
    self.cancelButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.cancelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 16);
    [self.cancelButton addTarget:self action:@selector(cancelUpgrade) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.enabled = NO;
    [buttonContainer addSubview:self.cancelButton];
    self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [self.startButton.leadingAnchor constraintEqualToAnchor:buttonContainer.leadingAnchor],
        [self.startButton.widthAnchor constraintEqualToConstant:120],
        [self.startButton.heightAnchor constraintEqualToConstant:44],
        [self.cancelButton.leadingAnchor constraintEqualToAnchor:self.startButton.trailingAnchor constant:20],
        [self.cancelButton.widthAnchor constraintEqualToConstant:120],
        [self.cancelButton.heightAnchor constraintEqualToConstant:44],
        [self.cancelButton.trailingAnchor constraintEqualToAnchor:buttonContainer.trailingAnchor]
    ]];

    // 结果卡片
    self.resultContainer = [self createCard];
    self.resultContainer.hidden = YES;
    [self.view addSubview:self.resultContainer];
    self.resultContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.resultContainer.topAnchor constraintEqualToAnchor:buttonContainer.bottomAnchor constant:30],
        [self.resultContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.resultContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.resultContainer.heightAnchor constraintEqualToConstant:220]
    ]];

    // 结果标题
    UILabel *resultTitle = [[UILabel alloc] init];
    resultTitle.text = NSLocalizedString(@"LocKey.OtaResultTitle", nil);
    resultTitle.font = [UIFont boldSystemFontOfSize:18];
    resultTitle.textColor = [UIColor colorWithRed:0.15 green:0.25 blue:0.45 alpha:1.0];
    [self.resultContainer addSubview:resultTitle];
    resultTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [resultTitle.topAnchor constraintEqualToAnchor:self.resultContainer.topAnchor constant:16],
        [resultTitle.leadingAnchor constraintEqualToAnchor:self.resultContainer.leadingAnchor constant:20]
    ]];

    // 结果详情
    NSDictionary *details = @{
        @"文件大小":@"fileSizeLabel",
        @"本次传输字节数":@"transferredBytesLabel",
        @"总耗时":@"totalTimeLabel",
        @"暂停时间":@"pausedTimeLabel",
        @"实际用时":@"actualTimeLabel",
        @"平均速度 (kB/s)":@"avgSpeedLabel"
    };

    UILabel *lastLabel = resultTitle;
    for (NSString *title in details) {
        NSString *key = details[title];
        UILabel *valueLabel = [[UILabel alloc] init];
        valueLabel.text = [NSString stringWithFormat:@"%@: --", title];
        valueLabel.font = [UIFont systemFontOfSize:14];
        valueLabel.textColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
        [self.resultContainer addSubview:valueLabel];
        valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [valueLabel.topAnchor constraintEqualToAnchor:lastLabel.bottomAnchor constant:10],
            [valueLabel.leadingAnchor constraintEqualToAnchor:self.resultContainer.leadingAnchor constant:20],
            [valueLabel.trailingAnchor constraintEqualToAnchor:self.resultContainer.trailingAnchor constant:-20]
        ]];
        [self setValue:valueLabel forKey:key];
        lastLabel = valueLabel;
    }
}

#pragma mark - UI 辅助方法

- (UIView *)createCard {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = [UIColor whiteColor];
    card.layer.cornerRadius = 12;
    card.layer.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.08].CGColor;
    card.layer.shadowOffset = CGSizeMake(0, 4);
    card.layer.shadowOpacity = 1.0;
    card.layer.shadowRadius = 10;
    return card;
}

- (UIButton *)createButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:0.20 green:0.60 blue:1.00 alpha:1.0]] forState:UIControlStateNormal];
    [button setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:0.20 green:0.60 blue:1.00 alpha:0.6]] forState:UIControlStateHighlighted];
    button.layer.cornerRadius = 8;
    button.clipsToBounds = YES;
    return button;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - 文件选择

- (void)selectFirmwareFile {
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[(__bridge NSString *)kUTTypeData] inMode:UIDocumentPickerModeOpen];
    picker.delegate = self;
    picker.allowsMultipleSelection = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIDocumentPickerDelegate

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
            NSNumber *fileSizeValue;
            [newURL getResourceValue:&fileSizeValue forKey:NSURLFileSizeKey error:&error];
            
            // 将文件拷贝到缓存目录
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
            NSString *fileName = newURL.lastPathComponent ?: @"firmware.fot";
            NSString *cachePath = [cacheDir stringByAppendingPathComponent:fileName];
            NSURL *cacheURL = [NSURL fileURLWithPath:cachePath];
            
            NSError *copyError;
            [fileManager removeItemAtURL:cacheURL error:nil]; // 先删除旧文件
            if (![fileManager copyItemAtURL:newURL toURL:cacheURL error:&copyError]) {
                self.statusLabel.text = NSLocalizedString(@"LocKey.OtaStatusCopyFailed", nil);
                return;
            }
            
            self.selectedFileURL = cacheURL;
            self.selectedFileSize = fileSizeValue;
            self.filePathLabel.text = cacheURL.path;
            self.startButton.enabled = YES;
            self.statusLabel.text = NSLocalizedString(@"LocKey.OtaStatusReady", nil);
        }];
        [fileURL stopAccessingSecurityScopedResource];
        
        
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    // 用户取消选择，无需处理
}

#pragma mark - 升级逻辑

- (void)startUpgrade {
    if (!self.selectedFileURL) {
        self.statusLabel.text = NSLocalizedString(@"LocKey.OtaStatusSelectFile", nil);
        return;
    }
    
    self.startButton.enabled = NO;
    self.cancelButton.enabled = YES;
    self.selectFileButton.enabled = NO;
    self.statusLabel.text = NSLocalizedString(@"LocKey.OtaStatusUpgrading", nil);
    self.resultContainer.hidden = YES;
    self.startTime = CACurrentMediaTime();
    self.pausedTime = 0;
    self.isPaused = NO;
    self.lastProgress = 0;

    id<AIBudsDeviceOtaAPI> device = (id<AIBudsDeviceOtaAPI>)self.device;
    if([device conformsToProtocol:@protocol(AIBudsDeviceOtaAPI)]) {
        [device startOtaWithFilePath:self.selectedFileURL.path startHandler:^(BOOL success, NSError * _Nullable error) {
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
        }];
    }
    
}

- (void)cancelUpgrade {
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    self.startButton.enabled = self.selectedFileURL ? YES : NO;
    self.cancelButton.enabled = NO;
    self.selectFileButton.enabled = YES;
    self.statusLabel.text = NSLocalizedString(@"LocKey.OtaStatusCanceled", nil);
    self.percentLabel.text = @"0%";
    self.progressView.progress = 0;
}

/*- (void)updateProgress {
    float progress = self.progressView.progress + 0.01;
    if (progress >= 1.0) {
        progress = 1.0;
        [self.progressTimer invalidate];
        self.progressTimer = nil;
        self.startButton.enabled = self.selectedFileURL ? YES : NO;
        self.cancelButton.enabled = NO;
        self.selectFileButton.enabled = YES;
        self.statusLabel.text = NSLocalizedString(@"LocKey.OtaStatusSuccess", nil);
        [self showResult];
    }
    self.progressView.progress = progress;
    self.percentLabel.text = [NSString stringWithFormat:@"%.0f%%", progress * 100];
}*/

- (void)showResult:(CGFloat)avgSpeed {
    NSTimeInterval totalTime = CACurrentMediaTime() - self.startTime;
    NSTimeInterval actualTime = totalTime - self.pausedTime;
    NSString *sizeString = [NSByteCountFormatter stringFromByteCount:self.selectedFileSize.longLongValue countStyle:NSByteCountFormatterCountStyleFile];
    self.fileSizeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.FileSizeLabelFormat", nil), sizeString];
    self.transferredBytesLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.TransferredBytesLabelFormat", nil), sizeString];
    self.totalTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.TotalTimeLabelFormat", nil), totalTime];
    self.pausedTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.PausedTimeLabelFormat", nil), self.pausedTime];
    self.actualTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.ActualTimeLabelFormat", nil), actualTime];
    self.avgSpeedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.AvgSpeedLabelFormat", nil), avgSpeed];

    self.resultContainer.hidden = NO;
}

@end
