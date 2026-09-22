//
//  InstantPhotoDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-09-18.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "InstantPhotoDemoController.h"
#import "InstantPhotoPreviewController.h"
#import <AIBuds/AIBuds.h>

static NSString *const kInstantPhotoCellReuseId = @"InstantPhotoCell";
static NSString *const kInstantPhotoReceivedNotification = @"InstantPhotoReceived";

@interface InstantPhotoDemoController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, strong) UILabel *countLabel;

@property (nonatomic, strong) NSMutableArray<NSDictionary *> *photos;

@end

@implementation InstantPhotoDemoController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithDevice:(id<AIBudsDeviceConvertible>)device {
    self = [super initWithDevice:device];
    if (self) {
        _photos = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"LocKey.InstantPhotoFeatureTitle", nil);
    [self setupUI];
    [self registerNotifications];
    [self updateEmptyState];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    _statusLabel = [[UILabel alloc] init];
    _statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    _statusLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    _statusLabel.textColor = [UIColor secondaryLabelColor];
    _statusLabel.text = NSLocalizedString(@"LocKey.InstantPhotoWaiting", nil);
    _statusLabel.backgroundColor = [UIColor secondarySystemBackgroundColor];
    _statusLabel.layer.cornerRadius = 0;
    [self.view addSubview:_statusLabel];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 2;
    layout.minimumLineSpacing = 2;
    layout.sectionInset = UIEdgeInsetsZero;

    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor systemBackgroundColor];
    _collectionView.alwaysBounceVertical = YES;
    [_collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:kInstantPhotoCellReuseId];
    [self.view addSubview:_collectionView];

    _emptyLabel = [[UILabel alloc] init];
    _emptyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _emptyLabel.textAlignment = NSTextAlignmentCenter;
    _emptyLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _emptyLabel.textColor = [UIColor secondaryLabelColor];
    _emptyLabel.numberOfLines = 0;
    _emptyLabel.text = NSLocalizedString(@"LocKey.InstantPhotoNoPhotos", nil);
    _emptyLabel.hidden = YES;
    [self.view addSubview:_emptyLabel];

    _countLabel = [[UILabel alloc] init];
    _countLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    _countLabel.textColor = [UIColor secondaryLabelColor];
    _countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.InstantPhotoPhotoCount", nil), 0];
    [self.view addSubview:_countLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.statusLabel.heightAnchor constraintEqualToConstant:36],

        [self.collectionView.topAnchor constraintEqualToAnchor:self.statusLabel.bottomAnchor],
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],

        [self.countLabel.topAnchor constraintEqualToAnchor:self.collectionView.bottomAnchor],
        [self.countLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.countLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.countLabel.heightAnchor constraintEqualToConstant:32],
        [self.countLabel.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],

        [self.emptyLabel.centerXAnchor constraintEqualToAnchor:self.collectionView.centerXAnchor],
        [self.emptyLabel.centerYAnchor constraintEqualToAnchor:self.collectionView.centerYAnchor],
        [self.emptyLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.collectionView.leadingAnchor constant:20],
        [self.emptyLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.collectionView.trailingAnchor constant:-20],
    ]];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(handleInstantPhotoReceived:)
                                                name:kInstantPhotoReceivedNotification
                                              object:nil];
}

- (void)handleInstantPhotoReceived:(NSNotification *)notification {
    NSError *error = notification.userInfo[@"error"];
    NSData *photoData = notification.userInfo[@"photoData"];
    NSDate *timestamp = notification.userInfo[@"timestamp"] ?: [NSDate date];

    if ([error isKindOfClass:[NSError class]]) {
        NSString *failureText = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"LocKey.InstantPhotoFailed", nil), error.localizedDescription];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text = failureText;
        });
        return;
    }

    if ([photoData isKindOfClass:[NSNull class]] || !photoData) {
        return;
    }

    // UIImage 解码开销较大，留在后台线程执行
    UIImage *image = [UIImage imageWithData:photoData];
    if (!image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text = NSLocalizedString(@"LocKey.InstantPhotoFailed", nil);
        });
        return;
    }

    NSDictionary *photoRecord = @{
        @"image": image,
        @"data": photoData,
        @"timestamp": timestamp,
    };

    // 数据源变更和 UI 更新都在主线程，避免后台线程操作 UICollectionView
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.photos insertObject:photoRecord atIndex:0];
        [self.collectionView performBatchUpdates:^{
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
        } completion:nil];
        self.statusLabel.text = NSLocalizedString(@"LocKey.InstantPhotoCompleted", nil);
        [self updateEmptyState];
    });
}

- (void)updateEmptyState {
    BOOL empty = self.photos.count == 0;
    self.emptyLabel.hidden = !empty;
    self.countLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.InstantPhotoPhotoCount", nil), (unsigned long)self.photos.count];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kInstantPhotoCellReuseId forIndexPath:indexPath];
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }

    UIImage *image = self.photos[indexPath.item][@"image"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.frame = cell.contentView.bounds;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [cell.contentView addSubview:imageView];

    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat totalSpacing = 2 * 2; // 2 inter-item gaps for 3 columns
    CGFloat width = (CGRectGetWidth(collectionView.bounds) - totalSpacing) / 3;
    return CGSizeMake(width, width);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *photoRecord = self.photos[indexPath.item];
    UIImage *image = photoRecord[@"image"];
    NSData *data = photoRecord[@"data"];
    InstantPhotoPreviewController *previewVC = [[InstantPhotoPreviewController alloc] initWithImage:image photoData:data];
    [self.navigationController pushViewController:previewVC animated:YES];
}

@end
