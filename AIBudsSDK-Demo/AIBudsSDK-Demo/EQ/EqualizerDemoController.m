//
//  EqualizerDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-09.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "EqualizerDemoController.h"

@protocol EQGainsSliderViewDelegate <NSObject>

- (void)eqGainsSliderView:(id)sliderView didUpdateGains:(NSArray *)gains;

@end

@interface EQSlider : UIView

@property (nonatomic, assign) NSInteger value;
@property (nonatomic, assign) NSInteger minValue;
@property (nonatomic, assign) NSInteger maxValue;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, copy) void (^valueChanged)(NSInteger value);
@property (nonatomic, strong) NSTimer *debounceTimer;
@property (nonatomic, assign) NSInteger pendingValue;

@end

@implementation EQSlider {
    UIView *_trackView;
    UIView *_thumbView;
    BOOL _isDragging;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self setupGestures];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    
    // 滑杆轨道
    _trackView = [[UIView alloc] init];
    _trackView.backgroundColor = [UIColor systemGray3Color];
    _trackView.layer.cornerRadius = 2;
    _trackView.accessibilityLabel = @"Equalizer Slider";
    _trackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_trackView];
    
    // 滑块
    _thumbView = [[UIView alloc] init];
    _thumbView.backgroundColor = [UIColor systemBlueColor];
    _thumbView.accessibilityLabel = @"Equalizer Slider Thumb";
    _thumbView.layer.cornerRadius = 5;
    _thumbView.layer.shadowColor = [UIColor blackColor].CGColor;
    _thumbView.layer.shadowOffset = CGSizeMake(0, 2);
    _thumbView.layer.shadowOpacity = 0.2;
    _thumbView.layer.shadowRadius = 2;
    _thumbView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_thumbView];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [_trackView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [_trackView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [_trackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [_trackView.widthAnchor constraintEqualToConstant:4],
        
        [_thumbView.widthAnchor constraintEqualToConstant:10],
        [_thumbView.heightAnchor constraintEqualToConstant:10],
        [_thumbView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor]
    ]];
    
    // 默认值
    self.minValue = -12;
    self.maxValue = 12;
    self.value = 0;
    self.editable = YES;
}

- (void)setupGestures {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:panGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    if (!self.editable) return;
    
    CGPoint location = [gesture locationInView:self];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            _isDragging = YES;
            [self updateValueFromLocation:location];
            break;
        case UIGestureRecognizerStateChanged:
            [self updateValueFromLocation:location];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            _isDragging = NO;
            break;
        default:
            break;
    }
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    if (!self.editable) return;
    
    CGPoint location = [gesture locationInView:self];
    [self updateValueFromLocation:location];
}

- (void)updateValueFromLocation:(CGPoint)location {
    CGFloat percent = 1.0 - (location.y / self.bounds.size.height);
    percent = MAX(0, MIN(1, percent));
    
    NSInteger range = self.maxValue - self.minValue;
    NSInteger newValue = round(self.minValue + (percent * range));
    
    if (newValue != self.value) {
        self.value = newValue;
        
        // 防抖处理：取消之前的定时器
        [_debounceTimer invalidate];
        _debounceTimer = nil;
        
        // 保存待处理的值
        _pendingValue = newValue;
        
        // 启动防抖定时器，50ms 后执行回调
        _debounceTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(debounceTimerFired) userInfo:nil repeats:NO];
    }
}

- (void)debounceTimerFired {
    if (self.valueChanged) {
        self.valueChanged(_pendingValue);
    }
    [_debounceTimer invalidate];
    _debounceTimer = nil;
}

- (void)setValue:(NSInteger)value {
    _value = MAX(self.minValue, MIN(self.maxValue, value));
    [self updateUI];
}

- (void)updateUI {
    CGFloat range = self.maxValue - self.minValue;
    CGFloat percent = (self.value - self.minValue) / (CGFloat)range;
    
    // 更新滑块位置
    CGFloat thumbY = (1.0 - percent) * (self.bounds.size.height - 16) + 8;
    _thumbView.center = CGPointMake(self.bounds.size.width / 2, thumbY);
    
    // 更新颜色 - 根据增益值使用渐变色效果
    CGFloat absValue = ABS(self.value) / 12.0; // 归一化到 0-1
    if (self.value > 0) {
        // 正值：从浅蓝到深蓝渐变
        _thumbView.backgroundColor = [UIColor colorWithHue:0.58 saturation:0.8 + (absValue * 0.2) brightness:0.9 + (absValue * 0.1) alpha:1.0];
    } else if (self.value < 0) {
        // 负值：从浅红到深红渐变
        _thumbView.backgroundColor = [UIColor colorWithHue:0.02 saturation:0.7 + (absValue * 0.3) brightness:0.9 + (absValue * 0.1) alpha:1.0];
    } else {
        _thumbView.backgroundColor = [UIColor systemGrayColor];
    }
    
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateUI];
}

@end

@interface EQGainsSliderView : UIView

@property (nonatomic, strong) NSArray *gains;
@property (nonatomic, strong) NSArray *frequencyLabels;
@property (nonatomic, weak) id<EQGainsSliderViewDelegate> delegate;
@property (nonatomic, assign) BOOL editable;

@end

@implementation EQGainsSliderView {
    NSMutableArray *_sliders;
    NSMutableArray *_gainLabels;
    NSMutableArray *_freqLabels;
}

- (void)setGains:(NSArray *)gains {
    _gains = gains;
    [self setupSliders];
}

- (void)setEditable:(BOOL)editable {
    _editable = editable;
    for (EQSlider *slider in _sliders) {
        slider.editable = editable;
    }
}

- (NSArray *)frequencyLabels {
    if (!_frequencyLabels && self.gains) {
        // 根据增益点数量生成频率标签
        NSMutableArray *labels = [NSMutableArray array];
        NSInteger count = self.gains.count;
       for (NSInteger i = 0; i < count; i++) {
            [labels addObject:[NSString stringWithFormat:@"%ld", (long)i+1]];
        }
        _frequencyLabels = labels;
    }
    return _frequencyLabels;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setupSliders];
}

- (void)setupSliders {
    // 清除之前的视图
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    if (!self.gains || self.gains.count == 0) {
        return;
    }
    
    _sliders = [NSMutableArray array];
    _gainLabels = [NSMutableArray array];
    _freqLabels = [NSMutableArray array];
    
    // 定义布局参数
    CGFloat paddingTop = 30.0;
    CGFloat paddingBottom = 40.0;
    CGFloat paddingLeft = 40.0;
    CGFloat paddingRight = 20.0;
    
    CGFloat sliderHeight = self.bounds.size.height - paddingTop - paddingBottom;
    CGFloat sliderWidth = (self.bounds.size.width - paddingLeft - paddingRight) / self.gains.count;
    
    NSInteger maxGain = 12;
    NSInteger minGain = -12;
    
    // 确保宽度和高度有效
    if (sliderWidth <= 0 || sliderHeight <= 0) {
        return;
    }
    
    // 创建滑杆和标签
    for (int i = 0; i < self.gains.count; i++) {
        NSInteger gain = [self.gains[i] integerValue];
        CGFloat x = paddingLeft + (sliderWidth * i);
        
        // 创建频率标签
        UILabel *freqLabel = [[UILabel alloc] init];
        freqLabel.frame = CGRectMake(x, self.bounds.size.height - paddingBottom + 10, sliderWidth, 20);
        freqLabel.textAlignment = NSTextAlignmentCenter;
        freqLabel.font = [UIFont systemFontOfSize:10];
        freqLabel.textColor = [UIColor systemGrayColor];
        if (self.frequencyLabels && i < self.frequencyLabels.count) {
            freqLabel.text = self.frequencyLabels[i];
        }
        [self addSubview:freqLabel];
        [_freqLabels addObject:freqLabel];
        
        // 创建自定义滑杆
        EQSlider *slider = [[EQSlider alloc] initWithFrame:CGRectMake(x, paddingTop, sliderWidth, sliderHeight)];
        slider.minValue = minGain;
        slider.maxValue = maxGain;
        slider.value = gain;
        slider.editable = self.editable;
        
        __weak typeof(self) weakSelf = self;
        slider.valueChanged = ^(NSInteger newValue) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            // 更新增益值标签
            UILabel *gainLabel = strongSelf->_gainLabels[i];
            gainLabel.text = [NSString stringWithFormat:@"%ld", (long)newValue];
            
            // 更新增益数组
            NSMutableArray *updatedGains = [strongSelf.gains mutableCopy];
            updatedGains[i] = @(newValue);
            strongSelf.gains = updatedGains;
            
            // 通知代理
            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(eqGainsSliderView:didUpdateGains:)]) {
                [strongSelf.delegate eqGainsSliderView:strongSelf didUpdateGains:strongSelf.gains];
            }
        };
        
        [self addSubview:slider];
        [_sliders addObject:slider];
        
        // 创建增益值标签
        UILabel *gainLabel = [[UILabel alloc] init];
        gainLabel.frame = CGRectMake(x, paddingTop - 20, sliderWidth, 20);
        gainLabel.textAlignment = NSTextAlignmentCenter;
        gainLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
        gainLabel.textColor = [UIColor labelColor];
        gainLabel.text = [NSString stringWithFormat:@"%ld", (long)gain];
        [self addSubview:gainLabel];
        [_gainLabels addObject:gainLabel];
    }
    
    // 绘制左侧刻度
    for (int i = 0; i <= 4; i++) {
        NSInteger gain = maxGain - (6 * i);
        CGFloat y = paddingTop + (sliderHeight / 4) * i;
        
        UILabel *gainLabel = [[UILabel alloc] init];
        gainLabel.frame = CGRectMake(5, y - 10, paddingLeft - 10, 20);
        gainLabel.textAlignment = NSTextAlignmentRight;
        gainLabel.font = [UIFont systemFontOfSize:10];
        gainLabel.textColor = [UIColor systemGrayColor];
        gainLabel.text = [NSString stringWithFormat:@"%ld", (long)gain];
        [self addSubview:gainLabel];
    }
}

@end

@interface EqualizerDemoController ()<UICollectionViewDelegate, UICollectionViewDataSource, EQGainsSliderViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *mainStackView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UICollectionView *eqSettingsCollectionView;
@property (nonatomic, strong) NSArray *eqSettings;
@property (nonatomic, strong) UIView *currentEQCardView;
@property (nonatomic, strong) UILabel *currentEQNameLabel;
@property (nonatomic, strong) UILabel *currentEQTypeLabel;
@property (nonatomic, strong) EQGainsSliderView *currentEQGainsSliderView;
@property (nonatomic, strong) AIBudsEQSettingModel *currentEQSetting;

@end

@implementation EqualizerDemoController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"LocKey.EqualizerDemoTitle", comment:@"Equalizer Demo");
    [self setupUI];
    [self loadEQSettings];
    [self registerNotifications];
}

- (void)registerNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(eqSettingChanged:) name:@"EQSettingChanged" object:nil];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // 创建滚动视图
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.contentInset = UIEdgeInsetsMake(20, 20, 20, 20);
    [self.view addSubview:self.scrollView];
    
    // 创建主栈视图
    self.mainStackView = [[UIStackView alloc] init];
    self.mainStackView.axis = UILayoutConstraintAxisVertical;
    self.mainStackView.spacing = 20;
    self.mainStackView.alignment = UIStackViewAlignmentFill;
    self.mainStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.mainStackView];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        // 滚动视图约束
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        
        // 主栈视图约束
        [self.mainStackView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [self.mainStackView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [self.mainStackView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [self.mainStackView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [self.mainStackView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor constant:-40] // 考虑 contentInset
    ]];
    
    // 添加状态标签
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = NSLocalizedString(@"LocKey.NoDeviceConnected", comment:@"No device connected");
    self.statusLabel.font = [UIFont systemFontOfSize:16];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.textColor = [UIColor systemGrayColor];
    self.statusLabel.numberOfLines = 2;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.statusLabel.heightAnchor constraintEqualToConstant:44]
    ]];
    [self.mainStackView addArrangedSubview:self.statusLabel];
    
    // 创建当前均衡器卡片
    self.currentEQCardView = [self createCardView];
    
    // 添加卡片标题
    UILabel *currentEQTitleLabel = [[UILabel alloc] init];
    currentEQTitleLabel.text = NSLocalizedString(@"LocKey.CurrentEQSetting", comment:@"Current EQ Setting");
    currentEQTitleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    currentEQTitleLabel.textColor = [UIColor labelColor];
    currentEQTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.currentEQCardView addSubview:currentEQTitleLabel];
    
    // 均衡器名称标签
    self.currentEQNameLabel = [[UILabel alloc] init];
    self.currentEQNameLabel.text = NSLocalizedString(@"LocKey.NoEQSettingActive", comment:@"No EQ setting active");
    self.currentEQNameLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.currentEQNameLabel.textColor = [UIColor labelColor];
    self.currentEQNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.currentEQCardView addSubview:self.currentEQNameLabel];
    
    // 均衡器类型标签
    self.currentEQTypeLabel = [[UILabel alloc] init];
    self.currentEQTypeLabel.text = @"";
    self.currentEQTypeLabel.font = [UIFont systemFontOfSize:14];
    self.currentEQTypeLabel.textColor = [UIColor systemGrayColor];
    self.currentEQTypeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.currentEQCardView addSubview:self.currentEQTypeLabel];
    
    // 增益滑杆
    self.currentEQGainsSliderView = [[EQGainsSliderView alloc] init];
    self.currentEQGainsSliderView.translatesAutoresizingMaskIntoConstraints = NO;
    self.currentEQGainsSliderView.backgroundColor = [UIColor tertiarySystemBackgroundColor];
    self.currentEQGainsSliderView.layer.cornerRadius = 8;
    self.currentEQGainsSliderView.delegate = self;
    self.currentEQGainsSliderView.editable = YES;
    [self.currentEQCardView addSubview:self.currentEQGainsSliderView];
    
    // 设置当前均衡器卡片内约束
    [NSLayoutConstraint activateConstraints:@[
        [currentEQTitleLabel.topAnchor constraintEqualToAnchor:self.currentEQCardView.topAnchor constant:20],
        [currentEQTitleLabel.leadingAnchor constraintEqualToAnchor:self.currentEQCardView.leadingAnchor constant:20],
        [currentEQTitleLabel.trailingAnchor constraintEqualToAnchor:self.currentEQCardView.trailingAnchor constant:-20],
        
        [self.currentEQNameLabel.topAnchor constraintEqualToAnchor:currentEQTitleLabel.bottomAnchor constant:10],
        [self.currentEQNameLabel.leadingAnchor constraintEqualToAnchor:self.currentEQCardView.leadingAnchor constant:20],
        
        [self.currentEQTypeLabel.firstBaselineAnchor constraintEqualToAnchor:self.currentEQNameLabel.firstBaselineAnchor],
        [self.currentEQTypeLabel.leadingAnchor constraintEqualToAnchor:self.currentEQNameLabel.trailingAnchor constant:8],
        [self.currentEQTypeLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.currentEQCardView.trailingAnchor constant:-20],
        
        [self.currentEQGainsSliderView.topAnchor constraintEqualToAnchor:self.currentEQNameLabel.bottomAnchor constant:20],
        [self.currentEQGainsSliderView.leadingAnchor constraintEqualToAnchor:self.currentEQCardView.leadingAnchor constant:20],
        [self.currentEQGainsSliderView.trailingAnchor constraintEqualToAnchor:self.currentEQCardView.trailingAnchor constant:-20],
        [self.currentEQGainsSliderView.bottomAnchor constraintEqualToAnchor:self.currentEQCardView.bottomAnchor constant:-20],
        [self.currentEQGainsSliderView.heightAnchor constraintEqualToConstant:160]
    ]];
    
    [self.mainStackView addArrangedSubview:self.currentEQCardView];
    
    // 创建均衡器预设卡片
    UIView *cardView = [self createCardView];
    
    // 添加卡片标题
    UILabel *cardTitleLabel = [[UILabel alloc] init];
    cardTitleLabel.text = NSLocalizedString(@"LocKey.EqualizerPresetsTitle", comment:@"Equalizer Presets");
    cardTitleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    cardTitleLabel.textColor = [UIColor labelColor];
    cardTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [cardView addSubview:cardTitleLabel];
    
    // 创建集合视图布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(150, 60);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 15;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    // 创建集合视图
    self.eqSettingsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.eqSettingsCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.eqSettingsCollectionView.backgroundColor = [UIColor clearColor];
    [self.eqSettingsCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"EQSettingCell"];
    self.eqSettingsCollectionView.delegate = self;
    self.eqSettingsCollectionView.dataSource = self;
    [cardView addSubview:self.eqSettingsCollectionView];
    
    // 设置卡片内约束
    [NSLayoutConstraint activateConstraints:@[
        [cardTitleLabel.topAnchor constraintEqualToAnchor:cardView.topAnchor constant:20],
        [cardTitleLabel.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:20],
        [cardTitleLabel.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-20],
        
        [self.eqSettingsCollectionView.topAnchor constraintEqualToAnchor:cardTitleLabel.bottomAnchor constant:20],
        [self.eqSettingsCollectionView.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:10],
        [self.eqSettingsCollectionView.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-10],
        [self.eqSettingsCollectionView.bottomAnchor constraintEqualToAnchor:cardView.bottomAnchor constant:-20],
        [self.eqSettingsCollectionView.heightAnchor constraintEqualToConstant:240]
    ]];
    
    [self.mainStackView addArrangedSubview:cardView];
}

- (UIView *)createCardView {
    UIView *cardView = [[UIView alloc] init];
    cardView.translatesAutoresizingMaskIntoConstraints = NO;
    cardView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    cardView.layer.cornerRadius = 16;
    cardView.layer.shadowColor = [UIColor blackColor].CGColor;
    cardView.layer.shadowOffset = CGSizeMake(0, 2);
    cardView.layer.shadowOpacity = 0.1;
    cardView.layer.shadowRadius = 4;
    return cardView;
}

- (void)loadEQSettings {
    if (!self.device) {
        self.statusLabel.text = NSLocalizedString(@"LocKey.NoDeviceConnected", comment:@"No device connected");
        self.currentEQNameLabel.text = NSLocalizedString(@"LocKey.NoEQSettingActive", comment:@"No EQ setting active");
        self.currentEQTypeLabel.text = @"";
        self.currentEQGainsSliderView.gains = nil;
        self.currentEQSetting = nil;
        return;
    }
    
    id<AIBudsDeviceEqualizerAPI> eqDevice = (id<AIBudsDeviceEqualizerAPI>)self.device;
    if ([eqDevice conformsToProtocol:@protocol(AIBudsDeviceEqualizerAPI)]) {
        self.eqSettings = eqDevice.allEQSettings;
        [self.eqSettingsCollectionView reloadData];
        
        AIBudsEQSettingModel *currentSetting = eqDevice.eqSetting;
        if (currentSetting) {
            // 保存当前均衡器设置
            self.currentEQSetting = currentSetting;
            
            // 显示均衡器名称
            NSString* resolvedName = @"";
            NSString* name = currentSetting.name;
            if(name) {
                NSString* nameLocKey = [NSString stringWithFormat:@"LocKey.EQName.%@", name];
                NSString* localizedName = NSLocalizedStringWithDefaultValue(nameLocKey, nil, [NSBundle mainBundle], nil, comment:name);
                resolvedName = [localizedName isKindOfClass:[NSString class]] ? localizedName : name;
                if(!resolvedName) {
                    resolvedName = NSLocalizedString(@"LocKey.EQName.Custom", comment:@"Custom");
                }
            }
            else {
                resolvedName = NSLocalizedString(@"LocKey.EQName.Custom", comment:@"Custom");
            }
            self.currentEQNameLabel.text = resolvedName;
            
            // 显示均衡器类型
            BOOL isCustom = [self isCustomEQSetting:currentSetting];
            if (isCustom) {
                self.currentEQTypeLabel.text = NSLocalizedString(@"LocKey.EQTypeCustom", comment:@"Custom");
            } else {
                self.currentEQTypeLabel.text = NSLocalizedString(@"LocKey.EQTypePreset", comment:@"Preset");
            }
            
            // 显示增益滑杆
            if (currentSetting.gains && currentSetting.gains.count > 0) {
                self.currentEQGainsSliderView.gains = currentSetting.gains;
            } else {
                self.currentEQGainsSliderView.gains = nil;
            }
            
            self.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.CurrentEQSettingNameFormat", comment:@"Current EQ Setting: %@"), resolvedName];
        } else {
            self.currentEQSetting = nil;
            self.currentEQNameLabel.text = NSLocalizedString(@"LocKey.NoEQSettingActive", comment:@"No EQ setting active");
            self.currentEQTypeLabel.text = @"";
            self.currentEQGainsSliderView.gains = nil;
            self.statusLabel.text = NSLocalizedString(@"LocKey.NoEQSettingActive", comment:@"No EQ setting active");
        }
    } else {
        self.statusLabel.text = NSLocalizedString(@"LocKey.DeviceNotSupportEQ", comment:@"Device does not support equalizer");
        self.currentEQNameLabel.text = NSLocalizedString(@"LocKey.DeviceNotSupportEQ", comment:@"Device does not support equalizer");
        self.currentEQTypeLabel.text = @"";
        self.currentEQGainsSliderView.gains = nil;
        self.currentEQSetting = nil;
    }
}

- (BOOL)isCustomEQSetting:(AIBudsEQSettingModel *)setting {
    return setting.isCustom;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.eqSettings.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EQSettingCell" forIndexPath:indexPath];
    
    // 清除之前的内容
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    // 获取当前均衡器设置
    AIBudsEQSettingModel *setting = self.eqSettings[indexPath.item];
    
    // 创建标签
    UILabel *nameLabel = [[UILabel alloc] init];
    if(setting.isPreset)
    {
        NSString* name = setting.name;
        NSString* nameLocKey = [NSString stringWithFormat:@"LocKey.EQName.%@", name];
        NSString* localizedName = NSLocalizedStringWithDefaultValue(nameLocKey, nil, [NSBundle mainBundle], nil, comment:name);
        nameLabel.text = [localizedName isKindOfClass:[NSString class]] ? localizedName : name;
    }
    else {
        nameLabel.text = [setting.name isKindOfClass:[NSString class]] ? setting.name : NSLocalizedString(@"LocKey.EQName.Custom", comment:@"Custom");
    }
    nameLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor = [UIColor labelColor];
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:nameLabel];
    
    // 设置标签约束
    [NSLayoutConstraint activateConstraints:@[
        [nameLabel.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:20],
        [nameLabel.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:10],
        [nameLabel.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-10],
        [nameLabel.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-20]
    ]];
    
    // 检查是否为当前激活的设置
    id<AIBudsDeviceEqualizerAPI> eqDevice = (id<AIBudsDeviceEqualizerAPI>)self.device;
    if ([eqDevice conformsToProtocol:@protocol(AIBudsDeviceEqualizerAPI)]) {
        AIBudsEQSettingModel *currentSetting = eqDevice.eqSetting;
        if (currentSetting && [setting.name isEqualToString:currentSetting.name]) {
            cell.contentView.backgroundColor = [UIColor systemBlueColor];
            nameLabel.textColor = [UIColor whiteColor];
        } else {
            cell.contentView.backgroundColor = [UIColor tertiarySystemBackgroundColor];
            nameLabel.textColor = [UIColor labelColor];
        }
    }
    
    // 设置圆角
    cell.contentView.layer.cornerRadius = 12;
    cell.contentView.layer.masksToBounds = YES;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.device) {
        self.statusLabel.text = NSLocalizedString(@"LocKey.NoDeviceConnected", comment:@"No device connected");
        return;
    }
    
    id<AIBudsDeviceEqualizerAPI> eqDevice = (id<AIBudsDeviceEqualizerAPI>)self.device;
    if ([eqDevice conformsToProtocol:@protocol(AIBudsDeviceEqualizerAPI)]) {
        AIBudsEQSettingModel *setting = self.eqSettings[indexPath.item];
        
        __weak typeof(self) weakSelf = self;
        [eqDevice setEqualizer:setting withCompletion:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{ 
                __strong typeof(self) strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                if (success) {
                    strongSelf.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.EQSettingAppliedFormat", comment:@"EQ setting applied: %@"), setting.name];
                    [strongSelf.eqSettingsCollectionView reloadData];
                    [strongSelf hideStatusLabelAfterDelay];
                } else {
                    strongSelf.statusLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
                    strongSelf.statusLabel.textColor = [UIColor systemRedColor];
                    [strongSelf hideStatusLabelAfterDelay];
                }
            });
        }];
    }
}

- (void)hideStatusLabelAfterDelay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ 
        [self loadEQSettings];
    });
}

- (void)eqSettingChanged:(NSNotification *)notification {
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{ 
        __strong typeof(self)strongSelf = weakSelf;
        if(!strongSelf)return;
        [strongSelf loadEQSettings];
        [strongSelf.eqSettingsCollectionView reloadData];
    });
    
}

#pragma mark - EQGainsSliderViewDelegate

- (void)eqGainsSliderView:(id)sliderView didUpdateGains:(NSArray *)gains {
    if (!self.device || !self.currentEQSetting) {
        return;
    }
    
    id<AIBudsDeviceEqualizerAPI> eqDevice = (id<AIBudsDeviceEqualizerAPI>)self.device;
    if ([eqDevice conformsToProtocol:@protocol(AIBudsDeviceEqualizerAPI)]) {
        // 创建一个新的均衡器设置，使用更新后的增益值
        NSInteger mode = 0x21;
        AIBudsEQSettingModel *updatedSetting = [[AIBudsEQSettingModel alloc] initWithMode:mode gains:gains];
        
        __weak typeof(self) weakSelf = self;
        [eqDevice setEqualizer:updatedSetting withCompletion:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{ 
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                if (success) {
                    strongSelf.statusLabel.text = NSLocalizedString(@"LocKey.EQSettingUpdatedSuccess", comment:@"EQ setting updated successfully");
                    [strongSelf hideStatusLabelAfterDelay];
                } else {
                    strongSelf.statusLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
                    strongSelf.statusLabel.textColor = [UIColor systemRedColor];
                    [strongSelf hideStatusLabelAfterDelay];
                }
            });
        }];
    }
}

@end
