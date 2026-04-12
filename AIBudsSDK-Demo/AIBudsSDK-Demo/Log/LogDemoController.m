//
//  LogDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-12.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "LogDemoController.h"

@interface LogDemoController ()

@property (nonatomic, strong) UIView *singleExportCard;
@property (nonatomic, strong) UIButton *singleExportButton;
@property (nonatomic, strong) UILabel *singleExportDescription;

@property (nonatomic, strong) UIView *multiExportCard;
@property (nonatomic, strong) UIButton *multiExportButton;
@property (nonatomic, strong) UILabel *multiExportDescription;
@property (nonatomic, strong) UILabel *fileSizeLabel;
@property (nonatomic, strong) UISlider *fileSizeSlider;

@property (nonatomic, strong) UIView *purgeCard;
@property (nonatomic, strong) UIButton *purgeButton;
@property (nonatomic, strong) UILabel *purgeDescription;
@property (nonatomic, strong) UILabel *daysLabel;
@property (nonatomic, strong) UISlider *daysSlider;

@property (nonatomic, strong) UIView *destinationCard;
@property (nonatomic, strong) UILabel *destinationDescription;
@property (nonatomic, strong) UISegmentedControl *destinationSegmentedControl;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *statusLabel;

@end

@implementation LogDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"LocKey.LogDemoTitle", @"Log Demo");
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    [self setupUI];
}

- (void)setupUI {
    // Destination Card
    [self createDestinationCard];
    
    // Single Export Card
    [self createSingleExportCard];
    
    // Multi Export Card
    [self createMultiExportCard];
    
    // Purge Card
    [self createPurgeCard];
    
    // Status Label
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = @"";
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.font = [UIFont systemFontOfSize:14];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.textColor = [UIColor systemGrayColor];
    [self.view addSubview:self.statusLabel];
    [self.statusLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.purgeCard.bottomAnchor constant:20],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
    
    // Activity Indicator
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.activityIndicator.topAnchor constraintEqualToAnchor:self.statusLabel.bottomAnchor constant:20]
    ]];
}

- (void)createSingleExportCard {
    self.singleExportCard = [[UIView alloc] init];
    self.singleExportCard.backgroundColor = [UIColor systemBackgroundColor];
    self.singleExportCard.layer.cornerRadius = 12;
    self.singleExportCard.layer.shadowColor = [UIColor blackColor].CGColor;
    self.singleExportCard.layer.shadowOpacity = 0.1;
    self.singleExportCard.layer.shadowOffset = CGSizeMake(0, 2);
    self.singleExportCard.layer.shadowRadius = 4;
    [self.view addSubview:self.singleExportCard];
    [self.singleExportCard setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.singleExportCard.topAnchor constraintEqualToAnchor:self.destinationCard.bottomAnchor constant:20],
        [self.singleExportCard.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.singleExportCard.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.singleExportCard.heightAnchor constraintEqualToConstant:120]
    ]];


    
    self.singleExportDescription = [[UILabel alloc] init];
    self.singleExportDescription.text = NSLocalizedString(@"LocKey.LogDemoSingleExportDescription", @"Export all logs to a single file and share it");
    self.singleExportDescription.font = [UIFont systemFontOfSize:16];
    self.singleExportDescription.textColor = [UIColor systemGrayColor];
    self.singleExportDescription.numberOfLines = 0;
    [self.singleExportCard addSubview:self.singleExportDescription];
    [self.singleExportDescription setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.singleExportDescription.topAnchor constraintEqualToAnchor:self.singleExportCard.topAnchor constant:20],
        [self.singleExportDescription.leadingAnchor constraintEqualToAnchor:self.singleExportCard.leadingAnchor constant:20],
        [self.singleExportDescription.trailingAnchor constraintEqualToAnchor:self.singleExportCard.trailingAnchor constant:-20]
    ]];
    
    self.singleExportButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.singleExportButton setTitle:NSLocalizedString(@"LocKey.LogDemoSingleExportButton", @"Export Logs") forState:UIControlStateNormal];
    self.singleExportButton.backgroundColor = [UIColor systemBlueColor];
    [self.singleExportButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.singleExportButton.layer.cornerRadius = 8;
    [self.singleExportButton addTarget:self action:@selector(singleExportButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.singleExportCard addSubview:self.singleExportButton];
    [self.singleExportButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.singleExportButton.topAnchor constraintEqualToAnchor:self.singleExportDescription.bottomAnchor constant:20],
        [self.singleExportButton.leadingAnchor constraintEqualToAnchor:self.singleExportCard.leadingAnchor constant:20],
        [self.singleExportButton.trailingAnchor constraintEqualToAnchor:self.singleExportCard.trailingAnchor constant:-20],
        [self.singleExportButton.heightAnchor constraintEqualToConstant:44]
    ]];
}

- (void)createMultiExportCard {
    self.multiExportCard = [[UIView alloc] init];
    self.multiExportCard.backgroundColor = [UIColor systemBackgroundColor];
    self.multiExportCard.layer.cornerRadius = 12;
    self.multiExportCard.layer.shadowColor = [UIColor blackColor].CGColor;
    self.multiExportCard.layer.shadowOpacity = 0.1;
    self.multiExportCard.layer.shadowOffset = CGSizeMake(0, 2);
    self.multiExportCard.layer.shadowRadius = 4;
    [self.view addSubview:self.multiExportCard];
    [self.multiExportCard setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.multiExportCard.topAnchor constraintEqualToAnchor:self.singleExportCard.bottomAnchor constant:20],
        [self.multiExportCard.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.multiExportCard.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.multiExportCard.heightAnchor constraintEqualToConstant:200]
    ]];

    
    self.multiExportDescription = [[UILabel alloc] init];
    self.multiExportDescription.text = NSLocalizedString(@"LocKey.LogDemoMultiExportDescription", @"Export logs to multiple files with size limit and share them");
    self.multiExportDescription.font = [UIFont systemFontOfSize:16];
    self.multiExportDescription.textColor = [UIColor systemGrayColor];
    self.multiExportDescription.numberOfLines = 0;
    [self.multiExportCard addSubview:self.multiExportDescription];
    [self.multiExportDescription setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.multiExportDescription.topAnchor constraintEqualToAnchor:self.multiExportCard.topAnchor constant:20],
        [self.multiExportDescription.leadingAnchor constraintEqualToAnchor:self.multiExportCard.leadingAnchor constant:20],
        [self.multiExportDescription.trailingAnchor constraintEqualToAnchor:self.multiExportCard.trailingAnchor constant:-20]
    ]];
    
    self.fileSizeLabel = [[UILabel alloc] init];
    self.fileSizeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.FileSizeLimitFormat", @"File Size Limit: %@ MB"), @(5)];
    self.fileSizeLabel.font = [UIFont systemFontOfSize:14];
    self.fileSizeLabel.textColor = [UIColor systemGrayColor];
    [self.multiExportCard addSubview:self.fileSizeLabel];
    [self.fileSizeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.fileSizeLabel.topAnchor constraintEqualToAnchor:self.multiExportDescription.bottomAnchor constant:20],
        [self.fileSizeLabel.leadingAnchor constraintEqualToAnchor:self.multiExportCard.leadingAnchor constant:20],
        [self.fileSizeLabel.trailingAnchor constraintEqualToAnchor:self.multiExportCard.trailingAnchor constant:-20]
    ]];
    
    self.fileSizeSlider = [[UISlider alloc] init];
    self.fileSizeSlider.minimumValue = 1;
    self.fileSizeSlider.maximumValue = 20;
    self.fileSizeSlider.value = 5;
    [self.fileSizeSlider addTarget:self action:@selector(fileSizeSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.multiExportCard addSubview:self.fileSizeSlider];
    [self.fileSizeSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.fileSizeSlider.topAnchor constraintEqualToAnchor:self.fileSizeLabel.bottomAnchor constant:10],
        [self.fileSizeSlider.leadingAnchor constraintEqualToAnchor:self.multiExportCard.leadingAnchor constant:20],
        [self.fileSizeSlider.trailingAnchor constraintEqualToAnchor:self.multiExportCard.trailingAnchor constant:-20]
    ]];
    
    self.multiExportButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.multiExportButton setTitle:NSLocalizedString(@"LocKey.LogDemoMultiExportButton", @"Export Multiple Files") forState:UIControlStateNormal];
    self.multiExportButton.backgroundColor = [UIColor systemGreenColor];
    [self.multiExportButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.multiExportButton.layer.cornerRadius = 8;
    [self.multiExportButton addTarget:self action:@selector(multiExportButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.multiExportCard addSubview:self.multiExportButton];
    [self.multiExportButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.multiExportButton.topAnchor constraintEqualToAnchor:self.fileSizeSlider.bottomAnchor constant:20],
        [self.multiExportButton.leadingAnchor constraintEqualToAnchor:self.multiExportCard.leadingAnchor constant:20],
        [self.multiExportButton.trailingAnchor constraintEqualToAnchor:self.multiExportCard.trailingAnchor constant:-20],
        [self.multiExportButton.heightAnchor constraintEqualToConstant:44]
    ]];
}

- (void)createPurgeCard {
    self.purgeCard = [[UIView alloc] init];
    self.purgeCard.backgroundColor = [UIColor systemBackgroundColor];
    self.purgeCard.layer.cornerRadius = 12;
    self.purgeCard.layer.shadowColor = [UIColor blackColor].CGColor;
    self.purgeCard.layer.shadowOpacity = 0.1;
    self.purgeCard.layer.shadowOffset = CGSizeMake(0, 2);
    self.purgeCard.layer.shadowRadius = 4;
    [self.view addSubview:self.purgeCard];
    [self.purgeCard setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.purgeCard.topAnchor constraintEqualToAnchor:self.multiExportCard.bottomAnchor constant:20],
        [self.purgeCard.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.purgeCard.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.purgeCard.heightAnchor constraintEqualToConstant:200]
    ]];

    
    self.purgeDescription = [[UILabel alloc] init];
    self.purgeDescription.text = NSLocalizedString(@"LocKey.LogDemoPurgeDescription", @"Delete logs older than specified days");
    self.purgeDescription.font = [UIFont systemFontOfSize:16];
    self.purgeDescription.textColor = [UIColor systemGrayColor];
    self.purgeDescription.numberOfLines = 0;
    [self.purgeCard addSubview:self.purgeDescription];
    [self.purgeDescription setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.purgeDescription.topAnchor constraintEqualToAnchor:self.purgeCard.topAnchor constant:20],
        [self.purgeDescription.leadingAnchor constraintEqualToAnchor:self.purgeCard.leadingAnchor constant:20],
        [self.purgeDescription.trailingAnchor constraintEqualToAnchor:self.purgeCard.trailingAnchor constant:-20]
    ]];
    
    self.daysLabel = [[UILabel alloc] init];
    self.daysLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.LogDemoDaysFormat", @"Delete logs older than %@ days"), @([AIBudsLogConfiguration shared].logFileMaxAge)];
    self.daysLabel.font = [UIFont systemFontOfSize:14];
    self.daysLabel.textColor = [UIColor systemGrayColor];
    [self.purgeCard addSubview:self.daysLabel];
    [self.daysLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.daysLabel.topAnchor constraintEqualToAnchor:self.purgeDescription.bottomAnchor constant:20],
        [self.daysLabel.leadingAnchor constraintEqualToAnchor:self.purgeCard.leadingAnchor constant:20],
        [self.daysLabel.trailingAnchor constraintEqualToAnchor:self.purgeCard.trailingAnchor constant:-20]
    ]];
    
    self.daysSlider = [[UISlider alloc] init];
    self.daysSlider.minimumValue = 1;
    self.daysSlider.maximumValue = 30;
    self.daysSlider.value = [AIBudsLogConfiguration shared].logFileMaxAge;
    [self.daysSlider addTarget:self action:@selector(daysSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.purgeCard addSubview:self.daysSlider];
    [self.daysSlider setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.daysSlider.topAnchor constraintEqualToAnchor:self.daysLabel.bottomAnchor constant:10],
        [self.daysSlider.leadingAnchor constraintEqualToAnchor:self.purgeCard.leadingAnchor constant:20],
        [self.daysSlider.trailingAnchor constraintEqualToAnchor:self.purgeCard.trailingAnchor constant:-20]
    ]];
    
    self.purgeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.purgeButton setTitle:NSLocalizedString(@"LocKey.LogDemoPurgeButton", @"Delete Old Logs") forState:UIControlStateNormal];
    self.purgeButton.backgroundColor = [UIColor systemRedColor];
    [self.purgeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.purgeButton.layer.cornerRadius = 8;
    [self.purgeButton addTarget:self action:@selector(purgeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.purgeCard addSubview:self.purgeButton];
    [self.purgeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.purgeButton.topAnchor constraintEqualToAnchor:self.daysSlider.bottomAnchor constant:20],
        [self.purgeButton.leadingAnchor constraintEqualToAnchor:self.purgeCard.leadingAnchor constant:20],
        [self.purgeButton.trailingAnchor constraintEqualToAnchor:self.purgeCard.trailingAnchor constant:-20],
        [self.purgeButton.heightAnchor constraintEqualToConstant:44]
    ]];
}

- (void)fileSizeSliderValueChanged:(UISlider *)slider {
    NSInteger value = (NSInteger)slider.value;
    self.fileSizeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.FileSizeLimitFormat", @"文件大小限制：%@ MB"), @(value)];
}

- (void)daysSliderValueChanged:(UISlider *)slider {
    NSInteger value = (NSInteger)slider.value;
    self.daysLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.LogDemoDaysFormat", @"删除指定天数天前的日志"), @(value)];
}

- (void)singleExportButtonTapped {
    [self.activityIndicator startAnimating];
    self.statusLabel.text = NSLocalizedString(@"LocKey.LogDemoExportingLogs", @"Exporting logs...");
    
    [AIBudsLogSDK.logService exportLogsWithCompletion:^(NSString * _Nullable filePath, NSDate * _Nullable logStartFrom, NSDate * _Nullable logEndAt, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
            
            if (error) {
                self.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.LogDemoExportFailedFormat", @"Export failed: %@"), error.localizedDescription];
                return;
            }
            
            if (filePath) {
                // 格式化日期
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                
                NSString *timeRange = @"";
                if (logStartFrom && logEndAt) {
                    NSString *startDate = [dateFormatter stringFromDate:logStartFrom];
                    NSString *endDate = [dateFormatter stringFromDate:logEndAt];
                    timeRange = [NSString stringWithFormat:NSLocalizedString(@"LocKey.LogDemoTimeRangeFormat", @"Time range: %@ - %@"), startDate, endDate];
                } else if (logStartFrom) {
                    NSString *startDate = [dateFormatter stringFromDate:logStartFrom];
                    timeRange = [NSString stringWithFormat:NSLocalizedString(@"LocKey.LogDemoTimeRangeStartFormat", @"Time range: From %@"), startDate];
                } else if (logEndAt) {
                    NSString *endDate = [dateFormatter stringFromDate:logEndAt];
                    timeRange = [NSString stringWithFormat:NSLocalizedString(@"LocKey.LogDemoTimeRangeEndFormat", @"Time range: Until %@"), endDate];
                }
                
                if (timeRange.length > 0) {
                    self.statusLabel.text = [NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"LocKey.LogDemoExportSuccess", @"Export successful"), timeRange];
                } else {
                    self.statusLabel.text = NSLocalizedString(@"LocKey.LogDemoExportSuccess", @"Export successful");
                }
                
                // 分享文件
                NSURL *fileURL = [NSURL fileURLWithPath:filePath];
                UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
                
                // 适配 iPad
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                    activityVC.popoverPresentationController.sourceView = self.singleExportButton;
                    activityVC.popoverPresentationController.sourceRect = self.singleExportButton.bounds;
                }
                
                [self presentViewController:activityVC animated:YES completion:nil];
            } else {
                self.statusLabel.text = NSLocalizedString(@"LocKey.LogDemoExportFailedNoFile", @"Export failed: No file generated");
            }
        });
    }];
}

- (void)multiExportButtonTapped {
    [self.activityIndicator startAnimating];
    self.statusLabel.text = NSLocalizedString(@"LocKey.LogDemoExportingLogs", @"Exporting logs...");
    
    // 从滑块获取文件大小限制（MB 转换为字节）
    NSInteger fileSizeMB = (NSInteger)self.fileSizeSlider.value;
    UInt64 fileSizeBytes = fileSizeMB * 1000 * 1000;
    
    [AIBudsLogSDK.logService exportLogsWithMaxFileSize:fileSizeBytes completion:^(NSArray<NSString *> * _Nullable filePaths, NSDate * _Nullable logStartFrom, NSDate * _Nullable logEndAt, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
            
            if (error) {
                self.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.LogDemoExportFailedFormat", @"Export failed: %@"), error.localizedDescription];
                return;
            }
            
            if (filePaths && filePaths.count > 0) {
                // 格式化日期
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                
                NSString *timeRange = @"";
                if (logStartFrom && logEndAt) {
                    NSString *startDate = [dateFormatter stringFromDate:logStartFrom];
                    NSString *endDate = [dateFormatter stringFromDate:logEndAt];
                    timeRange = [NSString stringWithFormat:NSLocalizedString(@"LocKey.LogDemoTimeRangeFormat", @"Time range: %@ - %@"), startDate, endDate];
                } else if (logStartFrom) {
                    NSString *startDate = [dateFormatter stringFromDate:logStartFrom];
                    timeRange = [NSString stringWithFormat:NSLocalizedString(@"LocKey.LogDemoTimeRangeStartFormat", @"Time range: From %@"), startDate];
                } else if (logEndAt) {
                    NSString *endDate = [dateFormatter stringFromDate:logEndAt];
                    timeRange = [NSString stringWithFormat:NSLocalizedString(@"LocKey.LogDemoTimeRangeEndFormat", @"Time range: Until %@"), endDate];
                }
                
                if (timeRange.length > 0) {
                    self.statusLabel.text = [NSString stringWithFormat:@"%@\n%@", [NSString stringWithFormat:NSLocalizedString(@"LocKey.LogDemoExportSuccessMultiple", @"Export successful: %@ files generated"), @(filePaths.count)], timeRange];
                } else {
                    self.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.LogDemoExportSuccessMultiple", @"Export successful: %@ files generated"), @(filePaths.count)];
                }
                
                // 分享文件
                NSMutableArray *shareItems = [NSMutableArray array];
                for (NSString *filePath in filePaths) {
                    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
                    [shareItems addObject:fileURL];
                }
                
                UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
                
                // 适配 iPad
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                    activityVC.popoverPresentationController.sourceView = self.multiExportButton;
                    activityVC.popoverPresentationController.sourceRect = self.multiExportButton.bounds;
                }
                
                [self presentViewController:activityVC animated:YES completion:nil];
            } else {
                self.statusLabel.text = NSLocalizedString(@"LocKey.LogDemoExportFailedNoFile", @"Export failed: No file generated");
            }
        });
    }];
}

- (void)purgeButtonTapped {
    [self.activityIndicator startAnimating];
    self.statusLabel.text = NSLocalizedString(@"LocKey.LogDemoDeletingLogs", @"Deleting old logs...");
    
    // 从滑块获取天数
    int days = (int)self.daysSlider.value;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ 
        [AIBudsDefaultLogger.shared purgeOldLogsWithMaxAge:days completion:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{ 
            [self.activityIndicator stopAnimating];
            self.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.LogDemoDeleteSuccessTipFormat", @"Successfully deleted logs older than %@ days"), @(days)];
        });
    });
}

- (void)createDestinationCard {
    self.destinationCard = [[UIView alloc] init];
    self.destinationCard.backgroundColor = [UIColor systemBackgroundColor];
    self.destinationCard.layer.cornerRadius = 12;
    self.destinationCard.layer.shadowColor = [UIColor blackColor].CGColor;
    self.destinationCard.layer.shadowOpacity = 0.1;
    self.destinationCard.layer.shadowOffset = CGSizeMake(0, 2);
    self.destinationCard.layer.shadowRadius = 4;
    [self.view addSubview:self.destinationCard];
    [self.destinationCard setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.destinationCard.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.destinationCard.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.destinationCard.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.destinationCard.heightAnchor constraintEqualToConstant:120]
    ]];
    
    self.destinationDescription = [[UILabel alloc] init];
    self.destinationDescription.text = NSLocalizedString(@"LocKey.LogDemoDestinationDescription", @"Select log output destination");
    self.destinationDescription.font = [UIFont systemFontOfSize:16];
    self.destinationDescription.textColor = [UIColor systemGrayColor];
    self.destinationDescription.numberOfLines = 0;
    [self.destinationCard addSubview:self.destinationDescription];
    [self.destinationDescription setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.destinationDescription.topAnchor constraintEqualToAnchor:self.destinationCard.topAnchor constant:20],
        [self.destinationDescription.leadingAnchor constraintEqualToAnchor:self.destinationCard.leadingAnchor constant:20],
        [self.destinationDescription.trailingAnchor constraintEqualToAnchor:self.destinationCard.trailingAnchor constant:-20]
    ]];
    
    // 创建分段控件
    NSArray *segmentTitles = @[NSLocalizedString(@"LocKey.LogDemoDestinationConsole", @"Console"), 
                               NSLocalizedString(@"LocKey.LogDemoDestinationOSLogger", @"OS Logger"), 
                               NSLocalizedString(@"LocKey.LogDemoDestinationFile", @"File"), 
                               NSLocalizedString(@"LocKey.LogDemoDestinationXLFacility", @"XL Facility")];
    self.destinationSegmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTitles];
    self.destinationSegmentedControl.selectedSegmentIndex = [self getCurrentDestinationIndex];
    [self.destinationSegmentedControl addTarget:self action:@selector(destinationSegmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.destinationCard addSubview:self.destinationSegmentedControl];
    [self.destinationSegmentedControl setTranslatesAutoresizingMaskIntoConstraints:NO];
    [NSLayoutConstraint activateConstraints:@[
        [self.destinationSegmentedControl.topAnchor constraintEqualToAnchor:self.destinationDescription.bottomAnchor constant:20],
        [self.destinationSegmentedControl.leadingAnchor constraintEqualToAnchor:self.destinationCard.leadingAnchor constant:20],
        [self.destinationSegmentedControl.trailingAnchor constraintEqualToAnchor:self.destinationCard.trailingAnchor constant:-20]
    ]];

}

- (NSInteger)getCurrentDestinationIndex {
    AIBudsLogConfiguration *sdkLogConfiguration = [AIBudsLogConfiguration shared];
    AIBudsLogDestination destination = sdkLogConfiguration.destination;
    
    switch (destination) {
        case AIBudsLogDestinationConsole:
            return 0;
        case AIBudsLogDestinationOslogger:
            return 1;
        case AIBudsLogDestinationFile:
            return 2;
        case AIBudsLogDestinationXlfacility:
            return 3;
        default:
            return 0;
    }
}

- (void)destinationSegmentedControlValueChanged:(UISegmentedControl *)sender {
    AIBudsLogConfiguration *sdkLogConfiguration = [AIBudsLogConfiguration shared];
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            sdkLogConfiguration.destination = AIBudsLogDestinationConsole;
            break;
        case 1:
            sdkLogConfiguration.destination = AIBudsLogDestinationOslogger;
            break;
        case 2:
            sdkLogConfiguration.destination = AIBudsLogDestinationFile;
            break;
        case 3:
            sdkLogConfiguration.destination = AIBudsLogDestinationXlfacility;
            break;
        default:
            sdkLogConfiguration.destination = AIBudsLogDestinationConsole;
            break;
    }
    
    // 获取选中的目标名称
    NSString *destinationName = [sender titleForSegmentAtIndex:sender.selectedSegmentIndex];
    // 更新状态标签显示目标变更信息
    self.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.LogDemoDestinationChangedToFormat", @"Log destination changed to: %@"), destinationName];
}

@end
