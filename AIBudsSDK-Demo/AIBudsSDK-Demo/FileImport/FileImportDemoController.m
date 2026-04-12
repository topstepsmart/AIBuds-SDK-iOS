//
//  FileImportDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-11.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "FileImportDemoController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface ImportedFile : NSObject
@property (nonatomic, strong) NSString *localPath;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, assign) AIBudsMediaFileType fileType;
@property (nonatomic, assign) BOOL containsSixAxisDebounceInfo;
@end

@implementation ImportedFile

@end

@interface FileImportDemoController () <UICollectionViewDelegate, UICollectionViewDataSource, AVAudioPlayerDelegate>

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

@property (nonatomic, assign) NSInteger totalMediaCount;
@property (nonatomic, strong) NSDictionary<NSString *, AIBudsMediaFileInfoModel *> *deviceMediaFilesInfo;
@property (nonatomic, strong) NSString* importingUrl;
@property (nonatomic, strong) NSMutableData* cacheData;

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
    self.view.backgroundColor = [UIColor systemGray6Color];
    
    // 滚动视图
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    // 主堆栈视图
    self.mainStackView = [[UIStackView alloc] init];
    self.mainStackView.axis = UILayoutConstraintAxisVertical;
    self.mainStackView.spacing = 20;
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
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        
        [self.mainStackView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor constant:20],
        [self.mainStackView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor constant:20],
        [self.mainStackView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor constant:-20],
        [self.mainStackView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor constant:-20],
        [self.mainStackView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor constant:-40]
    ]];
}

- (void)createDeviceInfoCard {
    self.deviceInfoCardView = [self createCardView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.DeviceMediaFiles", comment:@"Device Media Files");
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.deviceInfoCardView addSubview:titleLabel];
    
    self.mediaCountLabel = [[UILabel alloc] init];
    self.mediaCountLabel.text = NSLocalizedString(@"LocKey.LoadingMediaFiles", comment:@"Loading media files...");
    self.mediaCountLabel.font = [UIFont systemFontOfSize:16];
    self.mediaCountLabel.textColor = [UIColor secondaryLabelColor];
    self.mediaCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.deviceInfoCardView addSubview:self.mediaCountLabel];
    
    self.importButton = [self createPrimaryButtonWithTitle:NSLocalizedString(@"LocKey.ImportButton", comment:@"Import Files")];
    [self.importButton addTarget:self action:@selector(importButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.deviceInfoCardView addSubview:self.importButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.deviceInfoCardView.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.deviceInfoCardView.leadingAnchor constant:20],
        
        [self.mediaCountLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:10],
        [self.mediaCountLabel.leadingAnchor constraintEqualToAnchor:self.deviceInfoCardView.leadingAnchor constant:20],
        
        [self.importButton.topAnchor constraintEqualToAnchor:self.mediaCountLabel.bottomAnchor constant:20],
        [self.importButton.leadingAnchor constraintEqualToAnchor:self.deviceInfoCardView.leadingAnchor constant:20],
        [self.importButton.trailingAnchor constraintEqualToAnchor:self.deviceInfoCardView.trailingAnchor constant:-20],
        [self.importButton.bottomAnchor constraintEqualToAnchor:self.deviceInfoCardView.bottomAnchor constant:-20],
        [self.importButton.heightAnchor constraintEqualToConstant:44]
    ]];
    
    [self.mainStackView addArrangedSubview:self.deviceInfoCardView];
}

- (void)createImportStatusCard {
    self.importStatusCardView = [self createCardView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.ImportStatus", comment:@"Import Status");
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.importStatusCardView addSubview:titleLabel];
    
    self.currentFileNameLabel = [[UILabel alloc] init];
    self.currentFileNameLabel.text = @"";
    self.currentFileNameLabel.font = [UIFont systemFontOfSize:14];
    self.currentFileNameLabel.textColor = [UIColor secondaryLabelColor];
    self.currentFileNameLabel.numberOfLines = 2;
    self.currentFileNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.importStatusCardView addSubview:self.currentFileNameLabel];
    
    self.importProgressView = [[UIProgressView alloc] init];
    self.importProgressView.progress = 0.0;
    self.importProgressView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.importStatusCardView addSubview:self.importProgressView];
    
    self.importSpeedLabel = [[UILabel alloc] init];
    self.importSpeedLabel.text = @"";
    self.importSpeedLabel.font = [UIFont systemFontOfSize:14];
    self.importSpeedLabel.textColor = [UIColor secondaryLabelColor];
    self.importSpeedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.importStatusCardView addSubview:self.importSpeedLabel];
    
    self.importStatusLabel = [[UILabel alloc] init];
    self.importStatusLabel.text = @"";
    self.importStatusLabel.font = [UIFont systemFontOfSize:14];
    self.importStatusLabel.textColor = [UIColor systemBlueColor];
    self.importStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.importStatusCardView addSubview:self.importStatusLabel];
    
    // 新增：显示当前导入进度的 label
    self.importProgressLabel = [[UILabel alloc] init];
    self.importProgressLabel.text = @"";
    self.importProgressLabel.font = [UIFont systemFontOfSize:14];
    self.importProgressLabel.textColor = [UIColor secondaryLabelColor];
    self.importProgressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.importStatusCardView addSubview:self.importProgressLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.importStatusCardView.topAnchor constant:20],
        [titleLabel.leadingAnchor constraintEqualToAnchor:self.importStatusCardView.leadingAnchor constant:20],
        
        [self.currentFileNameLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:15],
        [self.currentFileNameLabel.leadingAnchor constraintEqualToAnchor:self.importStatusCardView.leadingAnchor constant:20],
        [self.currentFileNameLabel.trailingAnchor constraintEqualToAnchor:self.importStatusCardView.trailingAnchor constant:-20],
        
        [self.importProgressView.topAnchor constraintEqualToAnchor:self.currentFileNameLabel.bottomAnchor constant:15],
        [self.importProgressView.leadingAnchor constraintEqualToAnchor:self.importStatusCardView.leadingAnchor constant:20],
        [self.importProgressView.trailingAnchor constraintEqualToAnchor:self.importStatusCardView.trailingAnchor constant:-20],
        
        [self.importSpeedLabel.topAnchor constraintEqualToAnchor:self.importProgressView.bottomAnchor constant:10],
        [self.importSpeedLabel.leadingAnchor constraintEqualToAnchor:self.importStatusCardView.leadingAnchor constant:20],
        
        [self.importProgressLabel.topAnchor constraintEqualToAnchor:self.importSpeedLabel.bottomAnchor constant:10],
        [self.importProgressLabel.leadingAnchor constraintEqualToAnchor:self.importStatusCardView.leadingAnchor constant:20],
        
        [self.importStatusLabel.topAnchor constraintEqualToAnchor:self.importProgressLabel.bottomAnchor constant:10],
        [self.importStatusLabel.leadingAnchor constraintEqualToAnchor:self.importStatusCardView.leadingAnchor constant:20],
        [self.importStatusLabel.bottomAnchor constraintEqualToAnchor:self.importStatusCardView.bottomAnchor constant:-20]
    ]];
    
    [self.mainStackView addArrangedSubview:self.importStatusCardView];
}

- (void)createImportedFilesCard {
    self.importedFilesCardView = [self createCardView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"LocKey.ImportedFiles", comment:@"Imported Files");
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.importedFilesCardView addSubview:titleLabel];
    
    // 集合视图布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((self.view.frame.size.width - 80) / 3, 120);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    
    // 集合视图
    self.filesCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.filesCollectionView.delegate = self;
    self.filesCollectionView.dataSource = self;
    self.filesCollectionView.backgroundColor = [UIColor systemGray6Color];
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
        [self.filesCollectionView.heightAnchor constraintEqualToConstant:220]
    ]];
    
    [self.mainStackView addArrangedSubview:self.importedFilesCardView];
}

- (UIView *)createCardView {
    UIView *cardView = [[UIView alloc] init];
    cardView.backgroundColor = [UIColor whiteColor];
    cardView.layer.cornerRadius = 12;
    cardView.layer.shadowColor = [UIColor blackColor].CGColor;
    cardView.layer.shadowOffset = CGSizeMake(0, 2);
    cardView.layer.shadowOpacity = 0.1;
    cardView.layer.shadowRadius = 4;
    cardView.translatesAutoresizingMaskIntoConstraints = NO;
    return cardView;
}

- (UIButton *)createPrimaryButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor systemBlueColor];
    button.layer.cornerRadius = 8;
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
    self.cacheData = [NSMutableData data];
    // 开始导入文件
    [self startImportingFiles];
}

- (void)startImportingFiles {
    // 清空之前的导入文件
    [self.importedFiles removeAllObjects];
    [self.filesCollectionView reloadData];
    __weak typeof(self) weakSelf = self;
    id<AIBudsDeviceFileImportAPI> device = (id<AIBudsDeviceFileImportAPI>)self.device;
    if([device conformsToProtocol:@protocol(AIBudsDeviceFileImportAPI)])
    {
        [device fetchMediaFilesInfoWithConfigureHotspotStartingHandler:^{
            [weakSelf updateImportStatus:NSLocalizedString(@"LocKey.ConfiguringHotspot", comment:@"Configuring hotspot...") color:[UIColor systemBlueColor]];
        } hotspotConfigureCompletionHandler:^(BOOL success, NSError * _Nullable error) {
            if(success)
            {
                [weakSelf updateImportStatus:NSLocalizedString(@"LocKey.HotspotConfigured", comment:@"Hotspot configured") color:[UIColor systemGreenColor]];
            }
            else
            {
                NSString *errorMessage = error ? error.localizedDescription : @"Unknown error";
                NSString* message = [NSString stringWithFormat:NSLocalizedString(@"LocKey.HotspotConfigurationFailedFormat", comment:@"Hotspot configuration failed: %@"), errorMessage];
                [weakSelf updateImportStatus:message color:[UIColor systemRedColor]];
            }
        } enterFileTransferModeStartingHandler:^{
            [weakSelf updateImportStatus:NSLocalizedString(@"LocKey.AboutToEnterFileTransferMode", comment:@"About to enter file transfer mode...") color:[UIColor systemBlueColor]];
        } enterFileTransferModeCompletedHandler:^(BOOL success, NSError * _Nullable error) {
            if(success)
            {
                [weakSelf updateImportStatus:NSLocalizedString(@"LocKey.FileTransferModeEntered", comment:@"File transfer mode entered") color:[UIColor systemGreenColor]];
            }
            else
            {
                NSString *errorMessage = error ? error.localizedDescription : @"Unknown error";
                NSString* message = [NSString stringWithFormat:NSLocalizedString(@"LocKey.FileTransferModeEnterFailedFormat", comment:@"File transfer mode enter failed: %@"), errorMessage];
                [weakSelf updateImportStatus:message color:[UIColor systemRedColor]];
            }
        } waitingForHotspotOpenHandler:^{
            [weakSelf updateImportStatus:NSLocalizedString(@"LocKey.WaitingForHotspotOpen", comment:@"Waiting for hotspot to open...") color:[UIColor systemBlueColor]];
        } connectDeviceHotspotStartingHandler:^(NSString * _Nonnull ssid) {
            [weakSelf updateImportStatus:NSLocalizedString(@"LocKey.ConnectingToHotspot", comment:@"Connecting to hotspot...") color:[UIColor systemBlueColor]];
        } deviceHotspotConnectCompletionHandler:^(BOOL success, NSError * _Nullable error) {
            if(success)
            {
                [weakSelf updateImportStatus:NSLocalizedString(@"LocKey.HotspotConnected", comment:@"Hotspot connected") color:[UIColor systemGreenColor]];
            }
            else
            {
                NSString *errorMessage = error ? error.localizedDescription : @"Unknown error";
                NSString* message = [NSString stringWithFormat:NSLocalizedString(@"LocKey.HotspotConnectionFailedFormat", comment:@"Hotspot connection failed: %@"), errorMessage];
                [weakSelf updateImportStatus:message color:[UIColor systemRedColor]];
            }
        } completionHandler:^(BOOL success, NSArray<AIBudsMediaFileInfoModel *> * _Nonnull mediaFiles, NSError * _Nullable error) {
            if(success)
            {
                [weakSelf updateImportStatus:NSLocalizedString(@"LocKey.ReadyToImport", comment:@"Ready to import") color:[UIColor systemGreenColor]];
                NSMutableArray<NSString *> *toImportFiles = [NSMutableArray array];
                NSMutableDictionary<NSString *, AIBudsMediaFileInfoModel *> *fileInfoDict = [NSMutableDictionary dictionary];
                for(AIBudsMediaFileInfoModel *fileInfo in mediaFiles)
                {
                    [toImportFiles addObject:fileInfo.fileUrl];
                    [fileInfoDict setObject:fileInfo forKey:fileInfo.fileUrl];
                }
                weakSelf.deviceMediaFilesInfo = fileInfoDict;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [weakSelf importWithFileUrls:toImportFiles];
                });
            }
            else
            {
                NSString *errorMessage = error ? error.localizedDescription : @"Unknown error";
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

- (void) importWithFileUrls:(NSArray<NSString *> *)fileUrls {
    XLOG_INFO(@"importWithFileUrls: %@", fileUrls);
    __weak typeof(self) weakSelf = self;
    id<AIBudsDeviceFileImportAPI> device = (id<AIBudsDeviceFileImportAPI>)self.device;
    if([device conformsToProtocol:@protocol(AIBudsDeviceFileImportAPI)])
    {
        [device importFileWithUrls:fileUrls dataChunkHandler:^(NSData * _Nullable dataChunk, NSString * _Nonnull taskId, NSString * _Nonnull fileUrl, uint64_t fileSize, uint64_t transferredSize, NSError * _Nullable error) {
            weakSelf.importingUrl = fileUrl;
            if(error)
            {
                XLOG_ERROR(@"import file %@ error: %@", fileUrl, error);
                NSString *errorMessage = error ? error.localizedDescription : @"Unknown error";
                NSString* message = [NSString stringWithFormat:NSLocalizedString(@"LocKey.FileImportFailedFormat", comment:@"File import failed: %@"), errorMessage];
                [weakSelf updateImportStatus:message color:[UIColor systemRedColor]];
                return;
            }
            if(dataChunk)
            {
                [weakSelf.cacheData appendData:dataChunk];
                NSInteger progress = (NSInteger)(transferredSize * 100.0 / fileSize);
                [weakSelf updateCurrentImportingFileProgress:progress];
            }
        } singleTransferStartingHandler:^(NSString * _Nonnull fileUrl) {
            weakSelf.importingUrl = fileUrl;
            NSString* fileName = [fileUrl lastPathComponent];
            [weakSelf updateImportingFileName:fileName];
            [weakSelf updateCurrentImportingFileProgress:0];
        } singleTransferCompletionHandler:^(NSString * _Nonnull fileUrl, BOOL success, NSError * _Nullable error) {
            if(success)
            {
                NSData* data = [weakSelf.cacheData copy];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [weakSelf saveFileUrl:fileUrl data:data];
                });
            }
            
            [weakSelf updateCurrentImportingFileProgress:100];
        } speedHandler:^(uint64_t speed) {
            [weakSelf updateSpeed:speed];
        } batchProgressHandler:^(NSInteger fileIndex, NSInteger totalFileCount) {
            [weakSelf updateBatchProgress:fileIndex totalFileCount:totalFileCount];
        } completionHandler:^(BOOL success, NSNumber * _Nullable statusCode, NSError * _Nullable error) {
            [weakSelf updateImportStatus:NSLocalizedString(@"LocKey.FileImportAllSuccess", comment:@"All files import success") color:[UIColor systemGreenColor]];
        }];
    }
}

-(void) saveFileUrl:(NSString*)fileUrl data:(NSData*)data {
   AIBudsMediaFileInfoModel *fileInfo = self.deviceMediaFilesInfo[fileUrl];
    if(!fileInfo)
    {
        XLOG_ERROR(@"fileInfo not found for fileUrl: %@", fileUrl);
        return;
    }
    if(!data)
    {
        XLOG_ERROR(@"data is nil for fileUrl: %@", fileUrl);
        return;
    }
    // 保存文件到 cache 目录
    NSString* fileName = [fileUrl lastPathComponent];
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [cacheDir stringByAppendingPathComponent:fileName];
    BOOL writeSuccess = [data writeToFile:filePath atomically:YES];
    if (!writeSuccess) {
        XLOG_ERROR(@"Failed to write file to cache: %@", filePath);
        return;
    }
    XLOG_INFO(@"File saved to cache: %@", filePath);
    ImportedFile *importedFile = [ImportedFile new];
    importedFile.fileName = fileName;
    importedFile.fileType = fileInfo.fileType;
    importedFile.localPath = filePath;
    importedFile.containsSixAxisDebounceInfo = fileInfo.containsSixAxisDebounceInfo;
    [self.importedFiles addObject:importedFile];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.filesCollectionView reloadData];
    });
}

-(void) updateImportingFileName:(NSString*)fileName {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(!strongSelf) return;
        strongSelf.currentFileNameLabel.text = fileName;
    });
}

-(void) updateCurrentImportingFileProgress:(NSInteger)progress {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if(!strongSelf) return;
        strongSelf.importProgressView.progress = progress;
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
        strongSelf.importProgressLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)(fileIndex + 1), (long)totalFileCount];
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
    
    // 创建文件类型图标
    UIImageView *iconImageView = [[UIImageView alloc] init];
    iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    iconImageView.layer.cornerRadius = 4;
    iconImageView.layer.masksToBounds = YES;
    [cell.contentView addSubview:iconImageView];
    
    // 根据文件类型设置不同的图标
    if (fileType == AIBudsMediaFileTypeImage) {
        iconImageView.image = [self createImageIcon];
    } else if (fileType == AIBudsMediaFileTypeVideo) {
        iconImageView.image = [self createVideoIcon];
    } else if (fileType == AIBudsMediaFileTypeAudio) {
        iconImageView.image = [self createAudioIcon];
    }
    
    // 创建文件名标签
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = fileName;
    nameLabel.font = [UIFont systemFontOfSize:12];
    nameLabel.textColor = [UIColor labelColor];
    nameLabel.numberOfLines = 2;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:nameLabel];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [iconImageView.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:10],
        [iconImageView.centerXAnchor constraintEqualToAnchor:cell.contentView.centerXAnchor],
        [iconImageView.widthAnchor constraintEqualToConstant:48],
        [iconImageView.heightAnchor constraintEqualToConstant:48],
        
        [nameLabel.topAnchor constraintEqualToAnchor:iconImageView.bottomAnchor constant:10],
        [nameLabel.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:5],
        [nameLabel.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-5],
        [nameLabel.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-5]
    ]];
    
    return cell;
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
        // 视频类型 - 播放视频
        [self playVideoWithFilePath:filePath];
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
    playPauseButton.tintColor = [UIColor systemBlueColor];
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
