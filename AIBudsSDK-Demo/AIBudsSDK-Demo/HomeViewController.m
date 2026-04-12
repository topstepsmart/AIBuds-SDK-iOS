//
//  HomeViewController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-02-13.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "HomeViewController.h"
#import <Popover.OC/PopoverView.h>
#import "DeviceScanViewController.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DeviceHomeViewController.h"

@interface HomeDeviceItem : NSObject
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, copy) NSString *screenName;
@property (nonatomic, copy) NSString *remark;
@end

@implementation HomeDeviceItem
@end

@interface HomeDeviceCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *remarkLabel;
@property (nonatomic, strong) UIButton *deleteButton;

@property (nonatomic, weak) id<AIBudsDeviceConvertible> item;
@property (nonatomic, copy) void (^deleteBlock)(id<AIBudsDeviceConvertible>);

- (void)configureWithItem:(id<AIBudsDeviceConvertible>)item isEditing:(BOOL)isEditing onDelete:(void (^)(id<AIBudsDeviceConvertible>))deleteBlock;
@end

@implementation HomeDeviceCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor secondarySystemBackgroundColor];
        self.contentView.layer.cornerRadius = 8.0;
        self.contentView.layer.masksToBounds = YES;
        _iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        _iconView.tintColor = [UIColor labelColor];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _nameLabel.textColor = [UIColor labelColor];
        _remarkLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _remarkLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _remarkLabel.textColor = [UIColor secondaryLabelColor];

        _iconView.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _remarkLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_iconView];
        [self.contentView addSubview:_nameLabel];
        [self.contentView addSubview:_remarkLabel];

        _deleteButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_deleteButton setImage:[UIImage systemImageNamed:@"trash.fill"] forState:UIControlStateNormal];
        [_deleteButton setTintColor:[UIColor systemRedColor]];
        _deleteButton.hidden = YES;
        [_deleteButton addTarget:self action:@selector(deleteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_deleteButton];

        [NSLayoutConstraint activateConstraints:@[
            [_iconView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:12.0],
            [_iconView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
            [_iconView.widthAnchor constraintEqualToConstant:48.0],
            [_iconView.heightAnchor constraintEqualToConstant:48.0],

            [_nameLabel.topAnchor constraintEqualToAnchor:_iconView.bottomAnchor constant:10.0],
            [_nameLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:10.0],
            [_nameLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-10.0],

            [_remarkLabel.topAnchor constraintEqualToAnchor:_nameLabel.bottomAnchor constant:4.0],
            [_remarkLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:10.0],
            [_remarkLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-10.0],
            [_remarkLabel.bottomAnchor constraintLessThanOrEqualToAnchor:self.contentView.bottomAnchor constant:-10.0],
            
            [_deleteButton.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:12.0],
            [_deleteButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-12.0],
            [_deleteButton.widthAnchor constraintEqualToConstant:24.0],
            [_deleteButton.heightAnchor constraintEqualToConstant:24.0]
        ]];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.iconView.image = nil;
    self.nameLabel.text = nil;
    self.remarkLabel.text = nil;
}

- (void)configureWithItem:(id<AIBudsDeviceConvertible>)item isEditing:(BOOL)isEditing onDelete:(void (^)(id<AIBudsDeviceConvertible>))deleteBlock {
    self.item = item;
    self.deleteBlock = deleteBlock;

    self.iconView.image = item.thumbnail;
    self.nameLabel.text = item.screenName;
    
    self.remarkLabel.text = item.customContent;//item.connectionState == CBPeripheralStateConnected ? @"已连接" : @"未连接";
    self.deleteButton.hidden = !isEditing;
}

- (void)deleteButtonTapped:(UIButton *)sender {
    if (self.deleteBlock) {
        self.deleteBlock(self.item);
    }
}
@end

@interface HomeViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (nonatomic, assign) BOOL isLoading;
/// 是否正在编辑设备
@property (nonatomic, assign) BOOL isEditing;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<id<AIBudsDeviceConvertible>> *devices;
@end

@implementation HomeViewController

-(void)dealloc {
    [self removeNotificationObservers];
}

-(instancetype)init {
    if (self = [super init]) {
        self.isEditing = NO;
        self.isLoading = NO;
        self.devices = nil;
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(self.isEditing) {
        [self onToggleEditMode:nil event:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    self.navigationItem.title = NSLocalizedString(@"MyDevicesLocKey", nil);

    /// 左上角编辑按钮
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(onToggleEditMode:event:)];
    editButton.accessibilityLabel = @"[按钮] 编辑设备";
    editButton.tintColor = [UIColor labelColor];
    self.navigationItem.leftBarButtonItem = editButton;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddTapped:event:)];
    addButton.accessibilityLabel = @"[按钮] 添加设备";
    addButton.tintColor = [UIColor labelColor];
    self.navigationItem.rightBarButtonItem = addButton;

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 8.0;
    layout.minimumLineSpacing = 8.0;
    layout.sectionInset = UIEdgeInsetsMake(16, 16, 16, 16);

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor systemBackgroundColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.emptyDataSetSource = self;
    self.collectionView.emptyDataSetDelegate = self;
    [self.collectionView registerClass:HomeDeviceCell.class forCellWithReuseIdentifier:@"HomeDeviceCell"];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.collectionView];

    [NSLayoutConstraint activateConstraints:@[
        [self.collectionView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];

    [self.collectionView reloadEmptyDataSet];
    
    [self registerNotificationObservers];
    [self loadDevices];
}

- (void)removeNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onStoredDevicesChanged:) name:AIBudsNotifications.storedDevicesChangedNotificationName object:nil];
}

- (void)onStoredDevicesChanged:(NSNotification *)notification {
    NSArray<id<AIBudsDeviceConvertible>> *devices = AIBudsStoredDevicesMgr.allDevices;
    XLOG_VERBOSE(@"%@", APP_LOG_STRING(@"onStoredDevicesChanged:\n %@", [devices debugDescription]));
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.devices = devices;
        [weakSelf.collectionView reloadData];
        [weakSelf.collectionView reloadEmptyDataSet];
    });
}

- (void)loadDevices {
    self.isLoading = YES;
    [self.collectionView reloadEmptyDataSet];
    __weak typeof(self) weakSelf = self;
    [AIBudsStoredDevicesMgr loadDevicesInBackgroundWithCompletion:^(NSArray<id<AIBudsDeviceConvertible>> * _Nonnull devices, NSError * _Nullable error) {
        XLOG_VERBOSE(@"%@", APP_LOG_STRING(@"onStoredDevicesLoaded:\n %@", [devices debugDescription]));
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.isLoading = NO;
            if(error)
            {
                [weakSelf showError:error];
            }
            weakSelf.devices = devices;
            [weakSelf.collectionView reloadData];
            [weakSelf.collectionView reloadEmptyDataSet];
        });
    }];
}

- (void)showError:(NSError *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ErrorLocKey", nil) message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OKLocKey", nil) style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)onToggleEditMode:(UIBarButtonItem *)sender event:(UIEvent *)event {
    self.isEditing = !self.isEditing;
    
    UIBarButtonSystemItem systemItem = self.isEditing ? UIBarButtonSystemItemDone : UIBarButtonSystemItemEdit;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem
                                                                                target:self
                                                                                action:@selector(onToggleEditMode:event:)];
    barButton.tintColor = [UIColor labelColor];
    self.navigationItem.leftBarButtonItem = barButton;
    
    [self.collectionView reloadData];
}

- (void)onAddTapped:(UIBarButtonItem *)sender event:(UIEvent *)event {
    
    __weak typeof(self) weakSelf = self;
    PopoverView* popoverView = [PopoverView popoverView];
    popoverView.showShade = YES;
    NSMutableArray<PopoverAction *> * actions = [NSMutableArray array];
    PopoverAction *addDevice = [PopoverAction actionWithTitle:NSLocalizedString(@"AddDeviceMenuTitleLocKey", nil) handler:^(PopoverAction *action) {
        [weakSelf addDeviceAction];
    }];
    [actions addObject:addDevice];
    PopoverAction *scanDevice = [PopoverAction actionWithTitle:NSLocalizedString(@"ScanDeviceMenuTitleLocKey", nil) handler:^(PopoverAction *action) {
        [weakSelf scanAction];
    }];
    [actions addObject:scanDevice];
    [popoverView showToView:[event.allTouches.anyObject view] withActions:actions];
}

- (void)addDeviceAction {
    DeviceScanViewController *addDeviceVC = [DeviceScanViewController new];
    [self.navigationController pushViewController:addDeviceVC animated:YES];
}

- (void)scanAction {
}

#pragma mark - UICollectionViewDelegate

- (NSDictionary *)loadConfigs {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"configs" ofType:@"plist"];
    return [NSDictionary dictionaryWithContentsOfFile:plistPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<AIBudsDeviceConvertible> device = self.devices[indexPath.item];
    AIBudsConnectParams *param = [AIBudsConnectParams new];
    AIBudsAIAuthParams* aiAuthParams = [AIBudsAIAuthParams new];
    AIBudsStarBurstAIAuthParams* starBurstAuthParams = [AIBudsStarBurstAIAuthParams new];
    
    NSDictionary *configs = [self loadConfigs];
    starBurstAuthParams.productId = configs[@"STARBURST_PRODUCTID"];
    aiAuthParams.starburst = starBurstAuthParams;
    
    AIBudsMltCloudAIAuthParams* mltCloudAuthParams = [AIBudsMltCloudAIAuthParams new];
    mltCloudAuthParams.channelId = configs[@"MLTCLOUD_CHANNELID"];
    aiAuthParams.mltcloud = mltCloudAuthParams;
    
    param.aiAuthParams = aiAuthParams;
    param.userId = @"199";
    [device connectWithParams:param];
    DeviceHomeViewController *homeVC = [[DeviceHomeViewController alloc] initWithDevice:device];
    [self.navigationController pushViewController:homeVC animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.devices.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeDeviceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeDeviceCell" forIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    [cell configureWithItem:self.devices[indexPath.item] isEditing:self.isEditing onDelete:^(id<AIBudsDeviceConvertible>  _Nonnull item) {
        [weakSelf deleteDevice:item];
    }];
    return cell;
}

- (void)deleteDevice:(id<AIBudsDeviceConvertible>)device {
    [device unpair];
}

// MARK: - 编辑模式核心协议
    
// 1. 允许单元格被编辑（删除/移动）
- (BOOL)collectionView:(UICollectionView *)collectionView canEditItemAtIndexPath:(NSIndexPath *)indexPath {
    // 可以针对特定单元格设置是否允许编辑
    return YES;
}
/*
// 2. 设置编辑样式（删除/插入）
- (UICollectionViewCellEditingStyle)collectionView:(UICollectionView *)collectionView editingStyleForItemAtIndexPath:(NSIndexPath *)indexPath {
    // delete: 删除样式（默认带删除图标）
    // insert: 插入样式（带加号图标）
    // none: 无样式
    return UICollectionViewCellEditingStyleDelete;
}

// 3. 处理删除操作
- (void)collectionView:(UICollectionView *)collectionView commitEditingStyle:(UICollectionViewCellEditingStyle)editingStyle forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UICollectionViewCellEditingStyleDelete) {
        // 1. 删除数据源数据
        
        NSMutableArray *mutableDevices = [self.devices mutableCopy];
        id<AIBudsDeviceConvertible> device = [mutableDevices objectAtIndex:indexPath.item];
        [AIBudsStoredDevicesMgr removeDevice:device];
    }
}*/

// 4. 允许单元格移动（可选）
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// 5. 处理单元格移动逻辑（可选）
- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    // 1. 取出要移动的数据
    NSMutableArray *mutableDevices = [self.devices mutableCopy];
    id<AIBudsDeviceConvertible> movedItem = mutableDevices[sourceIndexPath.item];
    [mutableDevices removeObjectAtIndex:sourceIndexPath.item];
    // 2. 插入到新位置
    [mutableDevices insertObject:movedItem atIndex:destinationIndexPath.item];
    self.devices = [mutableDevices copy];
    __unused BOOL _ = [AIBudsStoredDevicesMgr moveDeviceFrom:sourceIndexPath.item to:destinationIndexPath.item];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UIEdgeInsets inset = ((UICollectionViewFlowLayout *)collectionViewLayout).sectionInset;
    CGFloat spacing = ((UICollectionViewFlowLayout *)collectionViewLayout).minimumInteritemSpacing;
    CGFloat availableWidth = collectionView.bounds.size.width - inset.left - inset.right - spacing;
    CGFloat width = floor(availableWidth / 2.0);
    return CGSizeMake(width, 140.0);
}

#pragma mark --DZNEmptyDataSetSource, DZNEmptyDataSetDelegate

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    if(self.isLoading)
    {
        return nil;
    }
    if(![self.devices isKindOfClass:[NSArray class]]
       || [self.devices count] == 0)
    {
        NSString* title = NSLocalizedString(@"NoDeviceAddedYetLocKey", nil);
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
        NSMutableDictionary *options = [NSMutableDictionary new];
        NSMutableParagraphStyle * paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        [options setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
        [options setObject:[UIFont systemFontOfSize:16 weight:UIFontWeightLight] forKey:NSFontAttributeName];
        [attributedString addAttributes:options range:NSMakeRange(0, attributedString.length)];
        return attributedString;
    }
    else
    {
        return nil;
    }
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    if(self.isLoading)
    {
        return [UIImage imageNamed:@"loading"];
    }
    return nil;
}

- (CAAnimation *)imageAnimationForEmptyDataSet:(UIScrollView *)scrollView
{
    if(self.isLoading)
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: @"transform"];
        animation.fromValue = [NSValue  valueWithCATransform3D:CATransform3DIdentity];
        animation.toValue = [NSValue   valueWithCATransform3D:CATransform3DMakeRotation(M_PI_2, 0.0, 0.0, 1.0)];
        
        animation.duration = 0.25;
        animation.cumulative = YES;
        animation.repeatCount = MAXFLOAT;
        
        return animation;
    }
    return nil;
}

- (BOOL)emptyDataSetShouldAnimateImageView:(UIScrollView *)scrollView {
    return YES;
}


-(CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return -100;
}

@end
