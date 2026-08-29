//
//  FileImportDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-11.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "FileImportDemoController.h"
#import "FileImportVideoComparisonController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

static UIColor *FileImportColor(NSInteger red, NSInteger green, NSInteger blue) {
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1.0];
}

@interface AIBudsGradientCardView : UIView
@end
@implementation AIBudsGradientCardView
+ (Class)layerClass { return CAGradientLayer.class; }
- (instancetype)init { if ((self = [super init])) { CAGradientLayer *g = (CAGradientLayer *)self.layer; g.colors = @[(id)FileImportColor(47, 91, 234).CGColor, (id)FileImportColor(104, 75, 215).CGColor]; g.startPoint = CGPointMake(0, 0); g.endPoint = CGPointMake(1, 1); self.layer.cornerRadius = 22; self.layer.masksToBounds = YES; } return self; }
@end

@interface ImportedFile : NSObject
@property (nonatomic, strong) NSString *localPath;
@property (nonatomic, strong, nullable) NSString *originalPath;
@property (nonatomic, strong, nullable) NSString *stabilizedPath;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, assign) AIBudsMediaFileType fileType;
@property (nonatomic, assign) BOOL containsSixAxisDebounceInfo;
@property (nonatomic, assign) AIBudsMediaFileStabilizationStatus stabilizationStatus;
@end

@implementation ImportedFile

@end

@interface FileImportDemoController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AVAudioPlayerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *mainStackView;

// 设备媒体文件信息
@property (nonatomic, strong) UIView *deviceInfoCardView;
@property (nonatomic, strong) UILabel *mediaCountLabel;
@property (nonatomic, strong) UIButton *importButton;

// 导入状态
@property (nonatomic, strong) UIView *importStatusCardView;
@property (nonatomic, strong) UILabel *currentFileNameLabel;
@property (nonatomic, strong) UIProgressView *importProgressView;
@property (nonatomic, strong) UILabel *importSpeedLabel;
@property (nonatomic, strong) UILabel *importStatusLabel;
@property (nonatomic, strong) UILabel *importProgressLabel;

// 导入的文件列表
@property (nonatomic, strong) UIView *importedFilesCardView;
@property (nonatomic, strong) UICollectionView *filesCollectionView;
@property (nonatomic, strong) NSMutableArray<ImportedFile*> *importedFiles;
@property (nonatomic, strong) NSMutableSet<NSString*> *displayedFileNames;
/// Serializes cache writes and owns `scheduledFileNames`.
@property (nonatomic, strong) dispatch_queue_t mediaFilePersistenceQueue;
/// Files already queued for persistence. This closes the gap between scheduling a
/// copy and updating `displayedFileNames` on the main queue.
@property (nonatomic, strong) NSMutableSet<NSString*> *scheduledFileNames;

@property (nonatomic, assign) NSInteger totalMediaCount;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) UIViewController *audioPlayerViewController;
@property (nonatomic, strong) NSTimer *audioProgressTimer;

@end

@implementation FileImportDemoController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"LocKey.FileImportDemoTitle", comment:@"File Import Demonstration");
    [self setupUI];
    [self loadDeviceMediaInfo];
    [self registerNotifications];
}

- (void) registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaCountChanged:) name:@"MediaCountChanged" object:nil];
}

- (void)mediaCountChanged:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        id<AIBudsDeviceInfoAPI> device = (id<AIBudsDeviceInfoAPI>)self.device;
        if([device conformsToProtocol:@protocol(AIBudsDeviceInfoAPI)])
        {
            AIBudsMediaCountInfoModel *mediaCountInfo = device.mediaCountInfo;
            if([mediaCountInfo isKindOfClass:[AIBudsMediaCountInfoModel class]])
            {
                NSInteger totalMediaCount = [mediaCountInfo.photoCount integerValue] + [mediaCountInfo.videoCount integerValue] + [mediaCountInfo.audioCount integerValue];
                
                self.mediaCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.TotalMediaCountFormat", comment:@"Total media files: %ld"), (long)totalMediaCount];
                self.importButton.enabled = YES;
                self.totalMediaCount = totalMediaCount;
                return;
            }
        }
        self.importButton.enabled = NO;
        self.mediaCountLabel.text = @"";
        self.totalMediaCount = 0;
    });
}

- (void)setupUI {
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    // 滚动视图
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    // 主堆栈视图
    self.mainStackView = [[UIStackView alloc] init];
    self.mainStackView.axis = UILayoutConstraintAxisVertical;
    self.mainStackView.spacing = 16;
    self.mainStackView.alignment = UIStackViewAlignmentFill;
    self.mainStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.mainStackView];
    
    // 设备媒体文件信息卡片
    [self createDeviceInfoCard];
    
    // 导入状态卡片
    [self createImportStatusCard];
    
    // 导入的文件列表卡片
    [self createImportedFilesCard];
    
    // 初始化数据
    self.importedFiles = [NSMutableArray array];
    self.displayedFileNames = [NSMutableSet set];
    self.scheduledFileNames = [NSMutableSet set];
    self.mediaFilePersistenceQueue = dispatch_queue_create("com.aibuds.demo.media-file-persistence", DISPATCH_QUEUE_SERIAL);
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        
        [self.mainStackView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor constant:16],
        [self.mainStackView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor constant:16],
        [self.mainStackView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor constant:-16],
        [self.mainStackView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor constant:-28],
        [self.mainStackView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor constant:-32]
    ]];
}

- (void)createDeviceInfoCard {
    self.deviceInfoCardView = [[AIBudsGradientCardView alloc] init];
    self.deviceInfoCardView.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *iconBackground = [UIView new];
    iconBackground.translatesAutoresizingMaskIntoConstraints = NO;
    iconBackground.backgroundColor = [UIColor colorWithWhite:1 alpha:.13];
    iconBackground.layer.cornerRadius = 24;
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"externaldrive.fill.badge.wifi"]];
    icon.translatesAutoresizingMaskIntoConstraints = NO; icon.tintColor = UIColor.whiteColor;
    [iconBackground addSubview:icon]; [self.deviceInfoCardView addSubview:iconBackground];

    UILabel *eyebrow = [UILabel new]; eyebrow.translatesAutoresizingMaskIntoConstraints = NO;
    eyebrow.text = NSLocalizedString(@"LocKey.FileImportDeviceLibraryEyebrow", nil);
    eyebrow.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
    eyebrow.textColor = [UIColor colorWithWhite:1 alpha:.62];
    [self.deviceInfoCardView addSubview:eyebrow];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.DeviceMediaFiles", comment:@"Device Media Files");
    titleLabel.font = [UIFont systemFontOfSize:27 weight:UIFontWeightBold];
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.deviceInfoCardView addSubview:titleLabel];
    
    self.mediaCountLabel = [[UILabel alloc] init];
    self.mediaCountLabel.text = NSLocalizedString(@"LocKey.LoadingMediaFiles", comment:@"Loading media files...");
    self.mediaCountLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.mediaCountLabel.textColor = [UIColor colorWithWhite:1 alpha:.72];
    self.mediaCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.deviceInfoCardView addSubview:self.mediaCountLabel];
    
    self.importButton = [self createPrimaryButtonWithTitle:NSLocalizedString(@"LocKey.ImportButton", comment:@"Import Files")];
    self.importButton.backgroundColor = UIColor.whiteColor;
    [self.importButton setTitleColor:FileImportColor(72, 86, 220) forState:UIControlStateNormal];
    [self.importButton setImage:[UIImage systemImageNamed:@"arrow.down.circle.fill"] forState:UIControlStateNormal];
    self.importButton.tintColor = FileImportColor(72, 86, 220);
    self.importButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    [self.importButton addTarget:self action:@selector(importButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.deviceInfoCardView addSubview:self.importButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [iconBackground.topAnchor constraintEqualToAnchor:self.deviceInfoCardView.topAnchor constant:20], [iconBackground.trailingAnchor constraintEqualToAnchor:self.deviceInfoCardView.trailingAnchor constant:-20], [iconBackground.widthAnchor constraintEqualToConstant:48], [iconBackground.heightAnchor constraintEqualToConstant:48],
        [icon.centerXAnchor constraintEqualToAnchor:iconBackground.centerXAnchor], [icon.centerYAnchor constraintEqualToAnchor:iconBackground.centerYAnchor], [icon.widthAnchor constraintEqualToConstant:24], [icon.heightAnchor constraintEqualToConstant:24],
        [eyebrow.topAnchor constraintEqualToAnchor:self.deviceInfoCardView.topAnchor constant:24], [eyebrow.leadingAnchor constraintEqualToAnchor:self.deviceInfoCardView.leadingAnchor constant:22],
        [titleLabel.topAnchor constraintEqualToAnchor:eyebrow.bottomAnchor constant:5],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.deviceInfoCardView.leadingAnchor constant:22],
        
        [self.mediaCountLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:7],
        [self.mediaCountLabel.leadingAnchor constraintEqualToAnchor:self.deviceInfoCardView.leadingAnchor constant:22],
        
        [self.importButton.topAnchor constraintEqualToAnchor:self.mediaCountLabel.bottomAnchor constant:22],
        [self.importButton.leadingAnchor constraintEqualToAnchor:self.deviceInfoCardView.leadingAnchor constant:22],
        [self.importButton.trailingAnchor constraintEqualToAnchor:self.deviceInfoCardView.trailingAnchor constant:-22],
        [self.importButton.bottomAnchor constraintEqualToAnchor:self.deviceInfoCardView.bottomAnchor constant:-22],
        [self.importButton.heightAnchor constraintEqualToConstant:50]
    ]];
    
    [self.mainStackView addArrangedSubview:self.deviceInfoCardView];
}

- (void)createImportStatusCard {
    self.importStatusCardView = [self createCardView];

    // Content container that clips to rounded corners, card itself keeps shadow
    UIView *contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    contentView.clipsToBounds = YES;
    contentView.layer.cornerRadius = 20;
    [self.importStatusCardView addSubview:contentView];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.ImportStatus", comment:@"Import Status");
    titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:titleLabel];

    self.currentFileNameLabel = [[UILabel alloc] init];
    self.currentFileNameLabel.text = @"";
    self.currentFileNameLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    self.currentFileNameLabel.textColor = [UIColor labelColor];
    self.currentFileNameLabel.numberOfLines = 2;
    self.currentFileNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:self.currentFileNameLabel];

    self.importProgressView = [[UIProgressView alloc] init];
    self.importProgressView.progress = 0.0;
    self.importProgressView.clipsToBounds = YES;
    self.importProgressView.layer.cornerRadius = 4;
    self.importProgressView.trackTintColor = UIColor.tertiarySystemFillColor;
    self.importProgressView.progressTintColor = FileImportColor(72, 86, 220);
    self.importProgressView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:self.importProgressView];

    self.importSpeedLabel = [[UILabel alloc] init];
    self.importSpeedLabel.text = @"";
    self.importSpeedLabel.font = [UIFont systemFontOfSize:14];
    self.importSpeedLabel.textColor = [UIColor secondaryLabelColor];
    self.importSpeedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:self.importSpeedLabel];

    self.importStatusLabel = [[UILabel alloc] init];
    self.importStatusLabel.text = @"";
    self.importStatusLabel.font = [UIFont systemFontOfSize:14];
    self.importStatusLabel.textColor = FileImportColor(72, 86, 220);
    self.importStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:self.importStatusLabel];

    self.importProgressLabel = [[UILabel alloc] init];
    self.importProgressLabel.text = @"";
    self.importProgressLabel.font = [UIFont systemFontOfSize:14];
    self.importProgressLabel.textColor = [UIColor secondaryLabelColor];
    self.importProgressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:self.importProgressLabel];

    [NSLayoutConstraint activateConstraints:@[
        // Content container fills the card
        [contentView.topAnchor constraintEqualToAnchor:self.importStatusCardView.topAnchor],
        [contentView.leadingAnchor constraintEqualToAnchor:self.importStatusCardView.leadingAnchor],
        [contentView.trailingAnchor constraintEqualToAnchor:self.importStatusCardView.trailingAnchor],
        [contentView.bottomAnchor constraintEqualToAnchor:self.importStatusCardView.bottomAnchor],

        // Inner subviews anchored to contentView
        [titleLabel.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:22],
        [titleLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:22],
        [titleLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-22],

        [self.currentFileNameLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:15],
        [self.currentFileNameLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [self.currentFileNameLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],

        [self.importProgressView.topAnchor constraintEqualToAnchor:self.currentFileNameLabel.bottomAnchor constant:14],
        [self.importProgressView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [self.importProgressView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20], [self.importProgressView.heightAnchor constraintEqualToConstant:8],

        [self.importSpeedLabel.topAnchor constraintEqualToAnchor:self.importProgressView.bottomAnchor constant:10],
        [self.importSpeedLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [self.importSpeedLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],

        [self.importProgressLabel.topAnchor constraintEqualToAnchor:self.importSpeedLabel.bottomAnchor constant:10],
        [self.importProgressLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [self.importProgressLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],

        [self.importStatusLabel.topAnchor constraintEqualToAnchor:self.importProgressLabel.bottomAnchor constant:10],
        [self.importStatusLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [self.importStatusLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],
        [self.importStatusLabel.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-20]
    ]];

    [self.mainStackView addArrangedSubview:self.importStatusCardView];
}

- (void)createImportedFilesCard {
    self.importedFilesCardView = [self createCardView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.ImportedFiles", comment:@"Imported Files");
    titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.importedFilesCardView addSubview:titleLabel];
    
    // 集合视图布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(150, 154);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    
    // 集合视图
    self.filesCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.filesCollectionView.delegate = self;
    self.filesCollectionView.dataSource = self;
    self.filesCollectionView.backgroundColor = UIColor.clearColor;
    self.filesCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.filesCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"FileCell"];
    [self.importedFilesCardView addSubview:self.filesCollectionView];
    
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.importedFilesCardView.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.importedFilesCardView.leadingAnchor constant:20],
        
        [self.filesCollectionView.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:15],
        [self.filesCollectionView.leadingAnchor constraintEqualToAnchor:self.importedFilesCardView.leadingAnchor constant:10],
        [self.filesCollectionView.trailingAnchor constraintEqualToAnchor:self.importedFilesCardView.trailingAnchor constant:-10],
        [self.filesCollectionView.bottomAnchor constraintEqualToAnchor:self.importedFilesCardView.bottomAnchor constant:-20],
        [self.filesCollectionView.heightAnchor constraintEqualToConstant:360]
    ]];
    
    [self.mainStackView addArrangedSubview:self.importedFilesCardView];
}

- (UIView *)createCardView {
    UIView *cardView = [[UIView alloc] init];
    cardView.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
    cardView.layer.cornerRadius = 18;
    cardView.layer.shadowColor = [UIColor blackColor].CGColor;
    cardView.layer.shadowOffset = CGSizeMake(0, 2);
    cardView.layer.shadowOpacity = 0.04;
    cardView.layer.shadowRadius = 8;
    cardView.translatesAutoresizingMaskIntoConstraints = NO;
    cardView.clipsToBounds = NO;
    return cardView;
}

- (UIButton *)createPrimaryButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = FileImportColor(72, 86, 220);
    button.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    button.layer.cornerRadius = 14;
    button.translatesAutoresizingMaskIntoConstraints = NO;
    return button;
}

- (void)loadDeviceMediaInfo {
    id<AIBudsDeviceInfoAPI> device = (id<AIBudsDeviceInfoAPI>)self.device;
    if([device conformsToProtocol:@protocol(AIBudsDeviceInfoAPI)])
    {
        AIBudsMediaCountInfoModel *mediaCountInfo = device.mediaCountInfo;
        if([mediaCountInfo isKindOfClass:[AIBudsMediaCountInfoModel class]])
        {
            NSInteger totalMediaCount = [mediaCountInfo.photoCount integerValue] + [mediaCountInfo.videoCount integerValue] + [mediaCountInfo.audioCount integerValue];
            
            self.mediaCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.TotalMediaCountFormat", comment:@"Total media files: %ld"), (long)totalMediaCount];
            self.importButton.enabled = YES;
            self.totalMediaCount = totalMediaCount;
            return;
        }
        else
        {
            self.mediaCountLabel.text = NSLocalizedString(@"LocKey.LoadingMediaFiles", comment:@"Loading media files...");
            [device requestQueryMediaCountInfoWithCompletion:^(BOOL success, NSError * _Nullable error) {
                            
            }];
            self.importButton.enabled = NO;
            self.totalMediaCount = 0;
            return;
        }
    }
    self.importButton.enabled = NO;
    self.mediaCountLabel.text = @"";
    self.totalMediaCount = 0;
}

- (void)importButtonTapped {
    if (self.totalMediaCount == 0) {
        self.importStatusLabel.text = NSLocalizedString(@"LocKey.NoFilesToImport", comment:@"No files to import");
        self.importStatusLabel.textColor = [UIColor systemRedColor];
        return;
    }
    // 开始导入文件
    [self startImportingFiles];
}

- (void)startImportingFiles {
    // 清空之前的导入文件
    [self.importedFiles removeAllObjects];
    [self.displayedFileNames removeAllObjects];
    dispatch_async(self.mediaFilePersistenceQueue, ^{
        [self.scheduledFileNames removeAllObjects];
    });
    [self.filesCollectionView reloadData];
    __weak typeof(self) weakSelf = self;
    id<AIBudsDeviceMediaFileImportAPI> device = (id<AIBudsDeviceMediaFileImportAPI>)self.device;
    if([device conformsToProtocol:@protocol(AIBudsDeviceMediaFileImportAPI)])
    {
        [device fetchMediaFilesInfoWithConfigureHotspotStartingHandler:^{
            [weakSelf updateImportStatus:NSLocalizedString(@"LocKey.ConfiguringHotspot", comment:@"Configuring hotspot...") color:FileImportColor(72, 86, 220)];
        } hotspotConfigureCompletionHandler:^(BOOL success, NSError * _Nullable error) {
            if(success)
            {
                [weakSelf updateImportStatus:NSLocalizedString(@"LocKey.HotspotConfigured", comment:@"Hotspot configured") color:[UIColor systemGreenColor]];
            }
            else
            {
                NSString *errorMessage = error ? error.localizedDescription : NSLocalizedString(@"LocKey.UnknownError", nil);
                NSString* message = [NSString stringWithFormat:NSLocalizedString(@"LocKey.HotspotConfigurationFailedFormat", comment:@"Hotspot configuration failed: %@"), errorMessage];
                [weakSelf updateImportStatus:message color:[UIColor systemRedColor]];
            }
        } enterFileTransferModeStartingHandler:^{
            [weakSelf updateImportStatus:NSLocalizedString(@"LocKey.AboutToEnterFileTransferMode", comment:@"About to enter file transfer mode...") color:FileImportColor(72, 86, 220)];
        } enterFileTransferModeCompletedHandler:^(BOOL success, NSError * _Nullable error) {
            if(success)
            {
                [weakSelf updateImportStatus:NSLocalizedString(@"LocKey.FileTransferModeEntered", comment:@"File transfer mode entered") color:[UIColor systemGreenColor]];
            }
            else
            {
                NSString *errorMessage = error ? error.localizedDescription : NSLocalizedString(@"LocKey.UnknownError", nil);
                NSString* message = [NSString stringWithFormat:NSLocalizedString(@"LocKey.FileTransferModeEnterFailedFormat", comment:@"File transfer mode enter failed: %@"), errorMessage];
                [weakSelf updateImportStatus:message color:[UIColor systemRedColor]];
            }
        } waitingForHotspotOpenHandler:^{
            [weakSelf updateImportStatus:NSLocalizedString(@"LocKey.WaitingForHotspotOpen", comment:@"Waiting for hotspot to open...") color:FileImportColor(72, 86, 220)];
        } connectDeviceHotspotStartingHandler:^(NSString * _Nonnull ssid) {
            [weakSelf updateImportStatus:NSLocalizedString(@"LocKey.ConnectingToHotspot", comment:@"Connecting to hotspot...") color:FileImportColor(72, 86, 220)];
        } deviceHotspotConnectCompletionHandler:^(BOOL success, NSError * _Nullable error) {
            if(success)
            {
                [weakSelf updateImportStatus:NSLocalizedString(@"LocKey.HotspotConnected", comment:@"Hotspot connected") color:[UIColor systemGreenColor]];
            }
            else
            {
                NSString *errorMessage = error ? error.localizedDescription : NSLocalizedString(@"LocKey.UnknownError", nil);
                NSString* message = [NSString stringWithFormat:NSLocalizedString(@"LocKey.HotspotConnectionFailedFormat", comment:@"Hotspot connection failed: %@"), errorMessage];
                [weakSelf updateImportStatus:message color:[UIColor systemRedColor]];
            }
        } completionHandler:^(BOOL success, NSArray<AIBudsMediaFileInfoModel *> * _Nonnull mediaFiles, NSError * _Nullable error) {
            if(success)
            {
                [weakSelf updateImportStatus:NSLocalizedString(@"LocKey.ReadyToImport", comment:@"Ready to import") color:[UIColor systemGreenColor]];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [weakSelf importMediaFiles:mediaFiles];
                });
            }
            else
            {
                NSString *errorMessage = error ? error.localizedDescription : NSLocalizedString(@"LocKey.UnknownError", nil);
                NSString* message = [NSString stringWithFormat:NSLocalizedString(@"LocKey.FileImportFailedFormat", comment:@"File import failed: %@"), errorMessage];
                [weakSelf updateImportStatus:message color:[UIColor systemRedColor]];
            }
        }];
    }
    
}

-(void)updateImportStatus:(NSString*)statusText color:(UIColor*)color {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(!strongSelf) return;
        strongSelf.importStatusLabel.text = statusText;
        strongSelf.importStatusLabel.textColor = color;
    });
}

- (void)importMediaFiles:(NSArray<AIBudsMediaFileInfoModel *> *)mediaFiles {
    XLOG_INFO(@"importMediaFiles: %@", mediaFiles);
    __weak typeof(self) weakSelf = self;
    id<AIBudsDeviceMediaFileImportAPI> device = (id<AIBudsDeviceMediaFileImportAPI>)self.device;
    if([device conformsToProtocol:@protocol(AIBudsDeviceMediaFileImportAPI)])
    {
        [device importMediaFiles:mediaFiles
                dataChunkHandler:^(NSData * _Nullable dataChunk, NSString * _Nonnull taskId, NSString * _Nonnull fileUrl, uint64_t fileSize, uint64_t transferredSize, NSError * _Nullable error) {
            if(error)
            {
                XLOG_ERROR(@"Media file data chunk %@ error: %@", fileUrl, error);
                return;
            }
            if(dataChunk)
            {
                XLOG_VERBOSE(@"Media file data chunk: task=%@, url=%@, chunk=%lu bytes, transferred=%llu/%llu (%.1f%%)",
                             taskId,
                             fileUrl,
                             (unsigned long)dataChunk.length,
                             (unsigned long long)transferredSize,
                             (unsigned long long)fileSize,
                             fileSize > 0 ? (double)transferredSize / (double)fileSize * 100 : 0);
            }
            if (fileSize > 0) {
                double progress = (double)transferredSize / (double)fileSize;
                [weakSelf updateCurrentImportingFileProgress:progress];
            }
        } singleTransferStartingHandler:^(AIBudsMediaFileInfoModel * _Nonnull mediaFile) {
            NSString *fileName = mediaFile.fileName.length > 0 ? mediaFile.fileName : mediaFile.fileUrl.lastPathComponent;
            [weakSelf updateImportingFileName:fileName];
            [weakSelf updateImportingFileStatus:NSLocalizedString(@"LocKey.FileImportDownloading", nil) color:FileImportColor(72, 86, 220)];
            [weakSelf updateCurrentImportingFileProgress:0];
        } singleTransferCompletionHandler:^(BOOL success, AIBudsImportedMediaFileModel * importedMediaFile, NSError * _Nullable error) {
            if (!success) {
                XLOG_ERROR(@"Media file transfer failed: %@, error: %@", importedMediaFile.metadata.fileName, error);
            } else if (importedMediaFile.stabilizationStatus != AIBudsMediaFileStabilizationStatusPending) {
                // 无需防抖或防抖已确定的文件，立即显示
                [weakSelf displaySingleImportedMediaFile:importedMediaFile];
            }
            [weakSelf updateCurrentImportingFileProgress:1];
        } transferSpeedHandler:^(uint64_t speed) {
            [weakSelf updateSpeed:speed];
        } transferBatchProgressHandler:^(NSInteger fileIndex, NSInteger totalFileCount) {
            [weakSelf updateBatchProgress:fileIndex totalFileCount:totalFileCount];
        } videoStabilizationPhaseBeginHandler:^{
            [weakSelf updateImportingFileStatus:NSLocalizedString(@"LocKey.FileImportStabilizing", nil) color:FileImportColor(104, 75, 215)];
            [weakSelf updateCurrentImportingFileProgress:0];
        } videoStabilizationSingleFileProgressHandler:^(AIBudsImportedMediaFileModel * _Nonnull mediaFile, double progress) {
            NSString *fileName = mediaFile.metadata.fileName.length > 0 ? mediaFile.metadata.fileName : mediaFile.localFileURL.lastPathComponent;
            [weakSelf updateImportingFileName:fileName];
            [weakSelf updateCurrentImportingFileProgress:progress];
            XLOG_INFO(@"Stabilization progress: %@ %.2f", fileName, progress);
        } videoStabilizationSingleFileCompletionHandler:^(AIBudsImportedMediaFileModel * _Nonnull mediaFile, BOOL success) {
            NSString *fileName = mediaFile.metadata.fileName.length > 0 ? mediaFile.metadata.fileName : mediaFile.localFileURL.lastPathComponent;
            XLOG_INFO(@"Stabilization single file completed: %@, success=%d, status=%ld", fileName, success, (long)mediaFile.stabilizationStatus);
            // 防抖完成后立即显示到列表，避免所有文件都处理完才刷新
            [weakSelf displaySingleImportedMediaFile:mediaFile];
        } videoStabilizationBatchProgressHandler:^(NSInteger fileIndex, NSInteger totalFileCount) {
            [weakSelf updatePostProcessBatchProgress:fileIndex totalFileCount:totalFileCount];
        } videoStabilizationPhaseFinishHandler:^{
            [weakSelf updateCurrentImportingFileProgress:1];
        } completionHandler:^(BOOL success, NSArray<AIBudsImportedMediaFileModel *> * _Nonnull importedMediaFiles, NSError * _Nullable error) {
            [weakSelf displayImportedMediaFiles:importedMediaFiles];
            if(success)
            {
                [weakSelf updateImportStatus:NSLocalizedString(@"LocKey.FileImportAllSuccess", comment:@"All media files imported successfully") color:[UIColor systemGreenColor]];
            }
            else
            {
                NSString *errorMessage = error ? error.localizedDescription : NSLocalizedString(@"LocKey.UnknownError", nil);
                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"LocKey.FileImportFailedFormat", comment:@"Media file import failed: %@"), errorMessage];
                [weakSelf updateImportStatus:message color:[UIColor systemRedColor]];
            }
        }];
    }
}

/// Returns the persistent directory where imported files are copied from the SDK's
/// temporary directory so the user can keep them across sessions.
- (NSURL *)persistentImportDirectoryURL {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *directoryPath = [cacheDir stringByAppendingPathComponent:@"AIBudsMediaImports"];
    return [NSURL fileURLWithPath:directoryPath isDirectory:YES];
}

- (void)displaySingleImportedMediaFile:(AIBudsImportedMediaFileModel *)result {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.mediaFilePersistenceQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(!strongSelf) return;

        NSURL *sourceURL = result.stabilizedFileURL ?: result.localFileURL;
        if (!sourceURL) {
            XLOG_WARNING(@"Skipping media file with no local URL: %@", result.metadata.fileName);
            return;
        }
        NSString *fileName = sourceURL.lastPathComponent.length > 0 ? sourceURL.lastPathComponent : result.metadata.fileName;
        if (fileName.length == 0) {
            XLOG_WARNING(@"Skipping media file with no file name: %@", sourceURL.path);
            return;
        }

        // A result can arrive through both the per-file callback and the final batch
        // callback. Reserve it before touching the filesystem so the second callback
        // becomes a no-op even while the first copy is still running.
        if ([strongSelf.scheduledFileNames containsObject:fileName]) {
            XLOG_VERBOSE(@"Skipping duplicate imported media callback: %@", fileName);
            return;
        }
        [strongSelf.scheduledFileNames addObject:fileName];

        NSURL *destinationDir = [strongSelf persistentImportDirectoryURL];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *directoryError = nil;
        if (![fileManager createDirectoryAtURL:destinationDir
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:&directoryError]) {
            [strongSelf.scheduledFileNames removeObject:fileName];
            XLOG_ERROR(@"Failed to create imported media directory %@: %@",
                       destinationDir.path,
                       directoryError.localizedDescription);
            return;
        }

        NSURL *destURL = [destinationDir URLByAppendingPathComponent:fileName];
        NSError *removeError = nil;
        if ([fileManager fileExistsAtPath:destURL.path] &&
            ![fileManager removeItemAtURL:destURL error:&removeError]) {
            [strongSelf.scheduledFileNames removeObject:fileName];
            XLOG_ERROR(@"Failed to replace existing imported media file at %@: %@",
                       destURL.path,
                       removeError.localizedDescription);
            return;
        }

        NSError *copyError = nil;
        if ([fileManager copyItemAtURL:sourceURL toURL:destURL error:&copyError]) {
            ImportedFile *importedFile = [ImportedFile new];
            importedFile.fileName = fileName;
            importedFile.fileType = result.metadata.fileType;
            importedFile.localPath = destURL.path;
            importedFile.stabilizedPath = result.stabilizedFileURL ? destURL.path : nil;
            if (result.stabilizedFileURL && result.localFileURL) {
                NSURL *originalsDirectory = [destinationDir URLByAppendingPathComponent:@"Originals" isDirectory:YES];
                [fileManager createDirectoryAtURL:originalsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
                NSString *originalName = result.localFileURL.lastPathComponent.length > 0 ? result.localFileURL.lastPathComponent : result.metadata.fileName;
                NSURL *originalDestination = [originalsDirectory URLByAppendingPathComponent:originalName];
                [fileManager removeItemAtURL:originalDestination error:nil];
                NSError *originalCopyError = nil;
                if ([fileManager copyItemAtURL:result.localFileURL toURL:originalDestination error:&originalCopyError]) {
                    importedFile.originalPath = originalDestination.path;
                } else {
                    XLOG_ERROR(@"Failed to retain original video for comparison: source=%@ error=%@", result.localFileURL.path, originalCopyError.localizedDescription);
                }
            } else {
                importedFile.originalPath = destURL.path;
            }
            importedFile.containsSixAxisDebounceInfo = result.metadata.containsSixAxisDebounceInfo;
            importedFile.stabilizationStatus = result.stabilizationStatus;

            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if(!strongSelf) return;
                [strongSelf.displayedFileNames addObject:fileName];
                [strongSelf.importedFiles addObject:importedFile];
                [strongSelf.filesCollectionView reloadData];
            });

            XLOG_INFO(@"Imported media file: source=%@, destination=%@, original=%@, stabilized=%@, status=%ld",
                      sourceURL.path,
                      destURL.path,
                      importedFile.originalPath ?: @"nil",
                      importedFile.stabilizedPath ?: @"nil",
                      (long)result.stabilizationStatus);
        } else if (copyError) {
            // Allow a later callback to retry a transient filesystem failure.
            [strongSelf.scheduledFileNames removeObject:fileName];
            XLOG_ERROR(@"Failed to copy imported media file from %@ to %@: %@",
                       sourceURL.path,
                       destURL.path,
                       copyError.localizedDescription);
        }
    });
}

- (void)displayImportedMediaFiles:(NSArray<AIBudsImportedMediaFileModel *> *)mediaFiles {
    for (AIBudsImportedMediaFileModel *result in mediaFiles) {
        [self displaySingleImportedMediaFile:result];
    }
}

-(void) updateImportingFileName:(NSString*)fileName {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(!strongSelf) return;
        strongSelf.currentFileNameLabel.text = fileName;
    });
}

-(void)updateCurrentImportingFileProgress:(double)progress {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(!strongSelf) return;
        double normalizedProgress = MIN(1.0, MAX(0.0, progress));
        [strongSelf.importProgressView setProgress:(float)normalizedProgress animated:YES];
    });
}

-(void)updateImportingFileStatus:(NSString*)status color:(UIColor*)color {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(!strongSelf) return;
        strongSelf.importStatusLabel.text = status;
        strongSelf.importStatusLabel.textColor = color;
        if ([color isEqual:[UIColor systemPurpleColor]]) {
            strongSelf.importSpeedLabel.text = @"";
        }
    });
}

-(void) updateSpeed:(uint64_t)speed {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(!strongSelf) return;
        // 根据实际情况显示 KB/s 还是 MB/s
        if (speed < 1024 * 1024) {
            strongSelf.importSpeedLabel.text = [NSString stringWithFormat:@"%.2f KB/s", speed / 1024.0];
        } else {
            strongSelf.importSpeedLabel.text = [NSString stringWithFormat:@"%.2f MB/s", speed / 1024.0 / 1024.0];
        }
    });
}

-(void) updateBatchProgress:(NSInteger)fileIndex totalFileCount:(NSInteger)totalFileCount {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(!strongSelf) return;
        NSInteger safeFileCount = MAX(totalFileCount, 1);
        NSInteger safeIndex = MAX(0, fileIndex);
        NSInteger displayIndex = MIN(safeFileCount, safeIndex + 1);
        strongSelf.importProgressLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)displayIndex, (long)safeFileCount];
    });
}

-(void) updatePostProcessBatchProgress:(NSInteger)fileIndex totalFileCount:(NSInteger)totalFileCount {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(!strongSelf) return;
        NSInteger safeFileCount = MAX(totalFileCount, 1);
        NSInteger safeIndex = MAX(0, fileIndex);
        NSInteger displayIndex = MIN(safeFileCount, safeIndex + 1);
        strongSelf.importProgressLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)displayIndex, (long)safeFileCount];
    });
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.importedFiles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FileCell" forIndexPath:indexPath];
    
    // 清除之前的内容
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    // 获取文件信息
    ImportedFile *fileInfo = self.importedFiles[indexPath.item];
    NSString *fileName = fileInfo.fileName;
    AIBudsMediaFileType fileType = fileInfo.fileType;
    NSString *statusText = NSLocalizedString(@"LocKey.FileImportStatusImported", nil);
    UIColor *statusColor = [UIColor colorWithRed:.12 green:.55 blue:.42 alpha:1];
    if (fileInfo.stabilizationStatus == AIBudsMediaFileStabilizationStatusStabilized) {
        statusText = NSLocalizedString(@"LocKey.FileImportStatusStabilizedCompare", nil);
        statusColor = FileImportColor(72, 86, 220);
    } else if (fileInfo.stabilizationStatus == AIBudsMediaFileStabilizationStatusFailed) {
        statusText = NSLocalizedString(@"LocKey.FileImportStatusStabilizationFailed", nil); statusColor = UIColor.systemRedColor;
    } else if (fileInfo.stabilizationStatus == AIBudsMediaFileStabilizationStatusPluginUnavailable) {
        statusText = NSLocalizedString(@"LocKey.FileImportStatusPluginUnavailable", nil); statusColor = UIColor.systemOrangeColor;
    } else if (fileInfo.stabilizationStatus == AIBudsMediaFileStabilizationStatusSkipped) {
        statusText = NSLocalizedString(@"LocKey.FileImportStatusStabilizationSkipped", nil); statusColor = UIColor.systemOrangeColor;
    } else if (fileInfo.stabilizationStatus == AIBudsMediaFileStabilizationStatusDisabled) {
        statusText = NSLocalizedString(@"LocKey.FileImportStatusStabilizationOff", nil); statusColor = UIColor.systemGrayColor;
    }
    
    // 创建文件类型图标
    UIView *iconContainer = [UIView new]; iconContainer.translatesAutoresizingMaskIntoConstraints = NO;
    iconContainer.layer.cornerRadius = 16; [cell.contentView addSubview:iconContainer];
    UIImageView *iconImageView = [[UIImageView alloc] init];
    iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    iconImageView.layer.cornerRadius = 12;
    iconImageView.layer.masksToBounds = YES;
    iconImageView.contentMode = UIViewContentModeScaleAspectFit; [iconContainer addSubview:iconImageView];
    cell.contentView.backgroundColor = UIColor.tertiarySystemBackgroundColor;
    cell.contentView.layer.cornerRadius = 18;
    cell.contentView.layer.shadowColor = UIColor.blackColor.CGColor;
    cell.contentView.layer.shadowOffset = CGSizeMake(0, 5); cell.contentView.layer.shadowRadius = 12; cell.contentView.layer.shadowOpacity = .07;
    
    // 根据文件类型设置不同的图标
    if (fileType == AIBudsMediaFileTypeImage) {
        iconImageView.image = [UIImage systemImageNamed:@"photo.fill"]; iconContainer.backgroundColor = [FileImportColor(104, 75, 215) colorWithAlphaComponent:.12]; iconImageView.tintColor = FileImportColor(104, 75, 215);
    } else if (fileType == AIBudsMediaFileTypeVideo) {
        iconImageView.image = [UIImage systemImageNamed:@"play.rectangle.fill"]; iconContainer.backgroundColor = [FileImportColor(72, 86, 220) colorWithAlphaComponent:.11]; iconImageView.tintColor = FileImportColor(72, 86, 220);
    } else if (fileType == AIBudsMediaFileTypeAudio) {
        iconImageView.image = [UIImage systemImageNamed:@"waveform"]; iconContainer.backgroundColor = [FileImportColor(47, 91, 234) colorWithAlphaComponent:.11]; iconImageView.tintColor = FileImportColor(47, 91, 234);
    }
    
    // 创建文件名标签
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = fileName;
    nameLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    nameLabel.textColor = [UIColor labelColor];
    nameLabel.numberOfLines = 2;
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:nameLabel];

    UILabel *statusLabel = [UILabel new]; statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    statusLabel.text = statusText; statusLabel.textColor = statusColor; statusLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightBold]; [cell.contentView addSubview:statusLabel];
    UIImageView *chevron = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]]; chevron.translatesAutoresizingMaskIntoConstraints = NO; chevron.tintColor = UIColor.tertiaryLabelColor; [cell.contentView addSubview:chevron];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [iconContainer.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:14], [iconContainer.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor], [iconContainer.widthAnchor constraintEqualToConstant:64], [iconContainer.heightAnchor constraintEqualToConstant:64],
        [iconImageView.centerXAnchor constraintEqualToAnchor:iconContainer.centerXAnchor], [iconImageView.centerYAnchor constraintEqualToAnchor:iconContainer.centerYAnchor], [iconImageView.widthAnchor constraintEqualToConstant:29], [iconImageView.heightAnchor constraintEqualToConstant:29],
        [nameLabel.leadingAnchor constraintEqualToAnchor:iconContainer.trailingAnchor constant:14], [nameLabel.trailingAnchor constraintEqualToAnchor:chevron.leadingAnchor constant:-10], [nameLabel.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:25],
        [statusLabel.leadingAnchor constraintEqualToAnchor:nameLabel.leadingAnchor], [statusLabel.trailingAnchor constraintLessThanOrEqualToAnchor:chevron.leadingAnchor constant:-8], [statusLabel.topAnchor constraintEqualToAnchor:nameLabel.bottomAnchor constant:8],
        [chevron.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-15], [chevron.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor], [chevron.widthAnchor constraintEqualToConstant:8]
    ]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat available = MAX(140, collectionView.bounds.size.width - 20);
    NSInteger columns = available >= 700 ? 2 : 1;
    CGFloat spacing = 10 * (columns - 1);
    return CGSizeMake(floor((available - spacing) / columns), 104);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 获取选中的文件信息
    ImportedFile *fileInfo = self.importedFiles[indexPath.item];
    AIBudsMediaFileType fileType = fileInfo.fileType;
    NSString *filePath = fileInfo.localPath;
    
    // 根据文件类型执行不同的操作
    if (fileType == AIBudsMediaFileTypeImage) {
        // 图片类型 - 显示大图预览
        [self showImagePreviewWithFilePath:filePath];
    } else if (fileType == AIBudsMediaFileTypeVideo) {
        if (fileInfo.originalPath.length > 0 && fileInfo.stabilizedPath.length > 0) {
            FileImportVideoComparisonController *comparison = [[FileImportVideoComparisonController alloc]
                initWithOriginalURL:[NSURL fileURLWithPath:fileInfo.originalPath]
                stabilizedURL:[NSURL fileURLWithPath:fileInfo.stabilizedPath]];
            [self.navigationController pushViewController:comparison animated:YES];
        } else {
            [self playVideoWithFilePath:filePath];
        }
    } else if (fileType == AIBudsMediaFileTypeAudio) {
        // 音频类型 - 播放音频
        //[self playAudioWithFilePath:filePath];
    }
}

#pragma mark - 文件预览与播放

- (void)showImagePreviewWithFilePath:(NSString *)filePath {
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    if (!image) {
        return;
    }
    
    // 创建图片预览控制器
    UIViewController *previewVC = [[UIViewController alloc] init];
    previewVC.view.backgroundColor = [UIColor blackColor];
    previewVC.modalPresentationStyle = UIModalPresentationFullScreen;
    
    // 创建滚动视图支持缩放
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:previewVC.view.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 3.0;
    scrollView.delegate = self;
    [previewVC.view addSubview:scrollView];
    
    // 创建图片视图
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = scrollView.bounds;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.tag = 1001; // 用于缩放的标识
    [scrollView addSubview:imageView];
    
    // 添加关闭按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setImage:[UIImage systemImageNamed:@"xmark.circle.fill"] forState:UIControlStateNormal];
    closeButton.tintColor = [UIColor whiteColor];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [closeButton addTarget:self action:@selector(closePreview:) forControlEvents:UIControlEventTouchUpInside];
    [previewVC.view addSubview:closeButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [closeButton.topAnchor constraintEqualToAnchor:previewVC.view.safeAreaLayoutGuide.topAnchor constant:10],
        [closeButton.trailingAnchor constraintEqualToAnchor:previewVC.view.trailingAnchor constant:-10],
        [closeButton.widthAnchor constraintEqualToConstant:44],
        [closeButton.heightAnchor constraintEqualToConstant:44]
    ]];
    
    [self presentViewController:previewVC animated:YES completion:nil];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [scrollView viewWithTag:1001];
}

- (void)closePreview:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)playVideoWithFilePath:(NSString *)filePath {
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.player = [AVPlayer playerWithURL:fileURL];
    [self presentViewController:playerViewController animated:YES completion:^{
        [playerViewController.player play];
    }];
}

- (void)playAudioWithFilePath:(NSString *)filePath {
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    // 创建音频播放器
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    if (error) {
        XLOG_ERROR(@"Failed to create audio player: %@", error);
        return;
    }
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];
    
    // 创建音频播放控制器
    UIViewController *audioPlayerVC = [[UIViewController alloc] init];
    audioPlayerVC.view.backgroundColor = [UIColor systemBackgroundColor];
    audioPlayerVC.modalPresentationStyle = UIModalPresentationPageSheet;
    
    // 添加音频信息标签
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = [filePath lastPathComponent];
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [audioPlayerVC.view addSubview:titleLabel];
    
    // 添加播放/暂停按钮
    UIButton *playPauseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [playPauseButton setImage:[UIImage systemImageNamed:@"pause.circle.fill"] forState:UIControlStateNormal];
    playPauseButton.tintColor = FileImportColor(72, 86, 220);
    playPauseButton.translatesAutoresizingMaskIntoConstraints = NO;
    [playPauseButton addTarget:self action:@selector(togglePlayPause:) forControlEvents:UIControlEventTouchUpInside];
    playPauseButton.tag = 1002;
    [audioPlayerVC.view addSubview:playPauseButton];
    
    // 添加进度滑块
    UISlider *progressSlider = [[UISlider alloc] init];
    progressSlider.minimumValue = 0;
    progressSlider.maximumValue = self.audioPlayer.duration;
    progressSlider.value = 0;
    progressSlider.translatesAutoresizingMaskIntoConstraints = NO;
    [progressSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    progressSlider.tag = 1003;
    [audioPlayerVC.view addSubview:progressSlider];
    
    // 添加时间标签
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.text = @"00:00 / 00:00";
    timeLabel.font = [UIFont systemFontOfSize:14];
    timeLabel.textColor = [UIColor secondaryLabelColor];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    timeLabel.tag = 1004;
    [audioPlayerVC.view addSubview:timeLabel];
    
    // 添加关闭按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setTitle:NSLocalizedString(@"LocKey.Close", comment:@"关闭") forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeAudioPlayer:) forControlEvents:UIControlEventTouchUpInside];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [audioPlayerVC.view addSubview:closeButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:audioPlayerVC.view.safeAreaLayoutGuide.topAnchor constant:40],
        [titleLabel.leadingAnchor constraintEqualToAnchor:audioPlayerVC.view.leadingAnchor constant:20],
        [titleLabel.trailingAnchor constraintEqualToAnchor:audioPlayerVC.view.trailingAnchor constant:-20],
        
        [playPauseButton.centerXAnchor constraintEqualToAnchor:audioPlayerVC.view.centerXAnchor],
        [playPauseButton.centerYAnchor constraintEqualToAnchor:audioPlayerVC.view.centerYAnchor],
        [playPauseButton.widthAnchor constraintEqualToConstant:80],
        [playPauseButton.heightAnchor constraintEqualToConstant:80],
        
        [progressSlider.leadingAnchor constraintEqualToAnchor:audioPlayerVC.view.leadingAnchor constant:20],
        [progressSlider.trailingAnchor constraintEqualToAnchor:audioPlayerVC.view.trailingAnchor constant:-20],
        [progressSlider.bottomAnchor constraintEqualToAnchor:playPauseButton.topAnchor constant:-40],
        
        [timeLabel.topAnchor constraintEqualToAnchor:progressSlider.bottomAnchor constant:10],
        [timeLabel.centerXAnchor constraintEqualToAnchor:audioPlayerVC.view.centerXAnchor],
        
        [closeButton.bottomAnchor constraintEqualToAnchor:audioPlayerVC.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
        [closeButton.centerXAnchor constraintEqualToAnchor:audioPlayerVC.view.centerXAnchor]
    ]];
    
    // 保存音频播放器控制器的引用
    self.audioPlayerViewController = audioPlayerVC;
    
    // 启动进度更新定时器
    self.audioProgressTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateAudioProgress) userInfo:nil repeats:YES];
    
    [self presentViewController:audioPlayerVC animated:YES completion:^{
        [self.audioPlayer play];
    }];
}

- (void)sliderValueChanged:(UISlider *)sender {
    if (sender.tag == 1003) {
        self.audioPlayer.currentTime = sender.value;
    }
}

- (void)closeAudioPlayer:(UIButton *)sender {
    
}

- (void)updateAudioProgress {
    
}

- (void)togglePlayPause:(UIButton *)sender {
    if (sender.tag == 1002) {
        if (self.audioPlayer.isPlaying) {
            [self.audioPlayer pause];
        }
        else {
            [self.audioPlayer play];
        }
    }
}


- (UIImage *)createImageIcon {
    CGRect rect = CGRectMake(0, 0, 48, 48);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 绘制背景
    CGContextSetFillColorWithColor(context, [UIColor systemGreenColor].CGColor);
    CGContextFillRect(context, rect);
    
    // 绘制相机图标
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGRect cameraRect = CGRectInset(rect, 8, 8);
    CGContextFillEllipseInRect(context, cameraRect);
    
    CGRect lensRect = CGRectInset(cameraRect, 8, 8);
    CGContextSetFillColorWithColor(context, [UIColor systemGrayColor].CGColor);
    CGContextFillEllipseInRect(context, lensRect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)createVideoIcon {
    CGRect rect = CGRectMake(0, 0, 48, 48);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 绘制背景
    CGContextSetFillColorWithColor(context, [UIColor systemRedColor].CGColor);
    CGContextFillRect(context, rect);
    
    // 绘制播放按钮
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGPoint points[3] = {
        CGPointMake(rect.size.width * 0.3, rect.size.height * 0.3),
        CGPointMake(rect.size.width * 0.3, rect.size.height * 0.7),
        CGPointMake(rect.size.width * 0.7, rect.size.height * 0.5)
    };
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, points[0].x, points[0].y);
    CGContextAddLineToPoint(context, points[1].x, points[1].y);
    CGContextAddLineToPoint(context, points[2].x, points[2].y);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)createAudioIcon {
    CGRect rect = CGRectMake(0, 0, 48, 48);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 绘制背景
    CGContextSetFillColorWithColor(context, [UIColor systemPurpleColor].CGColor);
    CGContextFillRect(context, rect);
    
    // 绘制音符
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    // 绘制音符头部
    CGRect noteHead = CGRectMake(rect.size.width * 0.6, rect.size.height * 0.3, 12, 12);
    CGContextFillEllipseInRect(context, noteHead);
    
    // 绘制音符 stem
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, rect.size.width * 0.6 + 6, rect.size.height * 0.3 + 6);
    CGContextAddLineToPoint(context, rect.size.width * 0.6 + 6, rect.size.height * 0.7);
    CGContextStrokePath(context);
    
    // 绘制音符 flag
    CGPoint points[3] = {
        CGPointMake(rect.size.width * 0.6 + 6, rect.size.height * 0.7),
        CGPointMake(rect.size.width * 0.7, rect.size.height * 0.6),
        CGPointMake(rect.size.width * 0.6 + 6, rect.size.height * 0.5)
    };
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, points[0].x, points[0].y);
    CGContextAddLineToPoint(context, points[1].x, points[1].y);
    CGContextAddLineToPoint(context, points[2].x, points[2].y);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
