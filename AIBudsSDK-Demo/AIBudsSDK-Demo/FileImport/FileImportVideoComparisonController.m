#import "FileImportVideoComparisonController.h"
#import <AVFoundation/AVFoundation.h>

static UIColor *FileImportComparisonColor(NSInteger red, NSInteger green, NSInteger blue) {
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1.0];
}

@interface ImportComparisonVideoView : UIView
@property(nonatomic, readonly) AVPlayerLayer *playerLayer;
@end
@implementation ImportComparisonVideoView
+ (Class)layerClass { return AVPlayerLayer.class; }
- (AVPlayerLayer *)playerLayer { return (AVPlayerLayer *)self.layer; }
@end

@interface FileImportVideoComparisonController ()
@property(nonatomic, strong) AVPlayer *originalPlayer;
@property(nonatomic, strong) AVPlayer *stabilizedPlayer;
@property(nonatomic, strong) UIStackView *videoStack;
@property(nonatomic, strong) UIButton *playButton;
@property(nonatomic, strong) UISlider *timeline;
@property(nonatomic, strong) UILabel *timeLabel;
@property(nonatomic, strong) UILabel *syncLabel;
@property(nonatomic, strong) id timeObserver;
@property(nonatomic) NSTimeInterval duration;
@property(nonatomic) BOOL playing;
@property(nonatomic) BOOL preparing;
@property(nonatomic) BOOL scrubbing;
@property(nonatomic) CFTimeInterval lastCorrection;
@end

@implementation FileImportVideoComparisonController

- (instancetype)initWithOriginalURL:(NSURL *)originalURL stabilizedURL:(NSURL *)stabilizedURL {
    self = [super initWithNibName:nil bundle:nil];
    if (!self) return nil;
    AVPlayerItem *originalItem = [AVPlayerItem playerItemWithURL:originalURL];
    AVPlayerItem *stabilizedItem = [AVPlayerItem playerItemWithURL:stabilizedURL];
    // Two bounded decode queues are much safer than retaining full-resolution
    // surfaces for every comparison frame, while remaining above phone UI size.
    originalItem.preferredMaximumResolution = CGSizeMake(1280, 960);
    stabilizedItem.preferredMaximumResolution = CGSizeMake(1280, 960);
    originalItem.preferredForwardBufferDuration = 1;
    stabilizedItem.preferredForwardBufferDuration = 1;
    _originalPlayer = [AVPlayer playerWithPlayerItem:originalItem];
    _stabilizedPlayer = [AVPlayer playerWithPlayerItem:stabilizedItem];
    _originalPlayer.automaticallyWaitsToMinimizeStalling = NO;
    _stabilizedPlayer.automaticallyWaitsToMinimizeStalling = NO;
    _stabilizedPlayer.muted = YES;
    _duration = CMTimeGetSeconds(originalItem.asset.duration);
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"LocKey.FileImportComparisonTitle", nil);
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;

    UILabel *kicker = [UILabel new];
    kicker.translatesAutoresizingMaskIntoConstraints = NO;
    kicker.text = NSLocalizedString(@"LocKey.FileImportComparisonEyebrow", nil);
    kicker.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
    kicker.textColor = FileImportComparisonColor(72, 86, 220);

    UIStackView *root = [UIStackView new];
    root.translatesAutoresizingMaskIntoConstraints = NO;
    root.axis = UILayoutConstraintAxisVertical;
    root.spacing = 10;
    [self.view addSubview:root];
    [root addArrangedSubview:kicker];
    [NSLayoutConstraint activateConstraints:@[
        [root.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10],
        [root.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:14],
        [root.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-14],
        [root.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-14]
    ]];

    self.videoStack = [UIStackView new];
    self.videoStack.axis = UILayoutConstraintAxisVertical;
    self.videoStack.distribution = UIStackViewDistributionFillEqually;
    self.videoStack.spacing = 12;
    [root addArrangedSubview:self.videoStack];
    [self.videoStack setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
    [self.videoStack addArrangedSubview:[self panelWithTitle:NSLocalizedString(@"LocKey.FileImportComparisonOriginal", nil) stabilized:NO player:self.originalPlayer]];
    [self.videoStack addArrangedSubview:[self panelWithTitle:NSLocalizedString(@"LocKey.FileImportComparisonStabilized", nil) stabilized:YES player:self.stabilizedPlayer]];

    UIView *controlDock = [UIView new];
    controlDock.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
    controlDock.layer.cornerRadius = 18;
    controlDock.layer.shadowColor = UIColor.blackColor.CGColor;
    controlDock.layer.shadowOpacity = 0.04;
    controlDock.layer.shadowRadius = 8;
    controlDock.layer.shadowOffset = CGSizeMake(0, 3);
    UIStackView *dockStack = [UIStackView new]; dockStack.translatesAutoresizingMaskIntoConstraints = NO; dockStack.axis = UILayoutConstraintAxisVertical; dockStack.spacing = 8; [controlDock addSubview:dockStack];
    [NSLayoutConstraint activateConstraints:@[[dockStack.topAnchor constraintEqualToAnchor:controlDock.topAnchor constant:12], [dockStack.bottomAnchor constraintEqualToAnchor:controlDock.bottomAnchor constant:-11], [dockStack.leadingAnchor constraintEqualToAnchor:controlDock.leadingAnchor constant:14], [dockStack.trailingAnchor constraintEqualToAnchor:controlDock.trailingAnchor constant:-14]]];

    self.timeline = [UISlider new]; self.timeline.minimumTrackTintColor = FileImportComparisonColor(72, 86, 220); self.timeline.maximumTrackTintColor = UIColor.tertiarySystemFillColor; self.timeline.thumbTintColor = FileImportComparisonColor(72, 86, 220);
    [self.timeline addTarget:self action:@selector(scrubBegan) forControlEvents:UIControlEventTouchDown];
    [self.timeline addTarget:self action:@selector(scrubChanged) forControlEvents:UIControlEventValueChanged];
    [self.timeline addTarget:self action:@selector(scrubEnded) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
    [dockStack addArrangedSubview:self.timeline];

    UIStackView *controls = [UIStackView new];
    controls.axis = UILayoutConstraintAxisHorizontal;
    controls.alignment = UIStackViewAlignmentCenter;
    controls.spacing = 14;
    self.playButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.playButton.backgroundColor = FileImportComparisonColor(72, 86, 220);
    self.playButton.tintColor = UIColor.whiteColor;
    self.playButton.layer.cornerRadius = 20;
    [self.playButton setImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal];
    [self.playButton.widthAnchor constraintEqualToConstant:40].active = YES; [self.playButton.heightAnchor constraintEqualToConstant:40].active = YES;
    [self.playButton addTarget:self action:@selector(togglePlayback) forControlEvents:UIControlEventTouchUpInside];
    self.timeLabel = [UILabel new];
    self.timeLabel.font = [UIFont monospacedDigitSystemFontOfSize:13 weight:UIFontWeightSemibold]; self.timeLabel.textColor = UIColor.labelColor;
    self.timeLabel.text = [self timeText:0];
    [controls addArrangedSubview:self.playButton];
    [controls addArrangedSubview:self.timeLabel];
    [dockStack addArrangedSubview:controls];
    self.syncLabel = [UILabel new];
    self.syncLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    self.syncLabel.textColor = UIColor.secondaryLabelColor;
    self.syncLabel.text = NSLocalizedString(@"LocKey.FileImportComparisonReady", nil);
    [dockStack addArrangedSubview:self.syncLabel];
    [root addArrangedSubview:controlDock];

    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.originalPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(.1, 600) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        [weakSelf updateTime:time];
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackEnded) name:AVPlayerItemDidPlayToEndTimeNotification object:self.originalPlayer.currentItem];
}

- (UIView *)panelWithTitle:(NSString *)title stabilized:(BOOL)stabilized player:(AVPlayer *)player {
    UIView *card = [UIView new];
    card.backgroundColor = UIColor.blackColor;
    card.layer.cornerRadius = 18;
    card.layer.masksToBounds = YES;
    ImportComparisonVideoView *video = [ImportComparisonVideoView new];
    video.translatesAutoresizingMaskIntoConstraints = NO;
    video.backgroundColor = UIColor.blackColor;
    video.playerLayer.player = player;
    video.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [card addSubview:video];
    UILabel *badge = [UILabel new];
    badge.translatesAutoresizingMaskIntoConstraints = NO;
    badge.text = [NSString stringWithFormat:@"  %@%@  ", stabilized ? @"●  " : @"○  ", [title uppercaseString]];
    badge.textColor = UIColor.whiteColor;
    badge.backgroundColor = stabilized ? [FileImportComparisonColor(72, 86, 220) colorWithAlphaComponent:.94] : [UIColor colorWithWhite:0 alpha:.68];
    badge.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
    badge.layer.cornerRadius = 7;
    badge.layer.masksToBounds = YES;
    [card addSubview:badge];
    UILabel *info = [UILabel new];
    info.translatesAutoresizingMaskIntoConstraints = NO;
    info.text = [self mediaInfo:player.currentItem.asset];
    info.textColor = UIColor.whiteColor;
    info.backgroundColor = [UIColor colorWithRed:.045 green:.05 blue:.065 alpha:.86];
    info.font = [UIFont monospacedDigitSystemFontOfSize:10 weight:UIFontWeightMedium];
    info.numberOfLines = 2;
    info.layer.cornerRadius = 6;
    info.layer.masksToBounds = YES;
    [card addSubview:info];
    [NSLayoutConstraint activateConstraints:@[
        [video.topAnchor constraintEqualToAnchor:card.topAnchor], [video.leadingAnchor constraintEqualToAnchor:card.leadingAnchor],
        [video.trailingAnchor constraintEqualToAnchor:card.trailingAnchor], [video.bottomAnchor constraintEqualToAnchor:card.bottomAnchor],
        [card.heightAnchor constraintGreaterThanOrEqualToConstant:140],
        [badge.topAnchor constraintEqualToAnchor:card.topAnchor constant:10], [badge.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:10],
        [info.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:10], [info.trailingAnchor constraintLessThanOrEqualToAnchor:card.trailingAnchor constant:-10],
        [info.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-10]
    ]];
    return card;
}

- (NSString *)mediaInfo:(AVAsset *)asset {
    AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    CGSize size = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
    NSURL *URL = [(AVURLAsset *)asset URL]; NSNumber *bytes = nil;
    [URL getResourceValue:&bytes forKey:NSURLFileSizeKey error:nil];
    return [NSString stringWithFormat:NSLocalizedString(@"LocKey.FileImportComparisonMediaInfoFormat", nil), fabs(size.width), fabs(size.height), track.nominalFrameRate, CMTimeGetSeconds(asset.duration), [NSByteCountFormatter stringFromByteCount:bytes.longLongValue countStyle:NSByteCountFormatterCountStyleFile]];
}

- (void)viewWillLayoutSubviews { [super viewWillLayoutSubviews]; self.videoStack.axis = self.view.bounds.size.width > self.view.bounds.size.height ? UILayoutConstraintAxisHorizontal : UILayoutConstraintAxisVertical; }
- (void)viewDidDisappear:(BOOL)animated { [super viewDidDisappear:animated]; [self.originalPlayer pause]; [self.stabilizedPlayer pause]; self.playing = NO; }
- (void)dealloc { if (self.timeObserver) [self.originalPlayer removeTimeObserver:self.timeObserver]; [[NSNotificationCenter defaultCenter] removeObserver:self]; }

- (void)togglePlayback {
    if (self.preparing) return;
    if (self.playing) { [self.originalPlayer pause]; [self.stabilizedPlayer pause]; self.playing = NO; [self.playButton setImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal]; self.syncLabel.text = NSLocalizedString(@"LocKey.FileImportComparisonPaused", nil); return; }
    [self startAtTime:self.originalPlayer.currentTime];
}
- (void)startAtTime:(CMTime)time {
    if (self.originalPlayer.currentItem.status != AVPlayerItemStatusReadyToPlay || self.stabilizedPlayer.currentItem.status != AVPlayerItemStatusReadyToPlay) {
        self.preparing = YES; self.playButton.enabled = NO; self.syncLabel.text = NSLocalizedString(@"LocKey.FileImportComparisonPreparing", nil);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ self.preparing = NO; [self startAtTime:time]; }); return;
    }
    dispatch_group_t group = dispatch_group_create();
    for (AVPlayer *player in @[self.originalPlayer, self.stabilizedPlayer]) { dispatch_group_enter(group); [player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(__unused BOOL done){ dispatch_group_leave(group); }]; }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        CMTime host = CMTimeAdd(CMClockGetTime(CMClockGetHostTimeClock()), CMTimeMakeWithSeconds(.2, NSEC_PER_SEC));
        [self.originalPlayer setRate:1 time:time atHostTime:host]; [self.stabilizedPlayer setRate:1 time:time atHostTime:host];
        self.preparing = NO; self.playing = YES; self.playButton.enabled = YES; [self.playButton setImage:[UIImage systemImageNamed:@"pause.fill"] forState:UIControlStateNormal];
    });
}
- (void)scrubBegan { self.scrubbing = YES; self.playing = NO; [self.originalPlayer pause]; [self.stabilizedPlayer pause]; }
- (void)scrubChanged { self.timeLabel.text = [self timeText:self.duration * self.timeline.value]; }
- (void)scrubEnded { CMTime time = CMTimeMakeWithSeconds(self.duration * self.timeline.value, 600); [self.originalPlayer seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero]; [self.stabilizedPlayer seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero]; self.scrubbing = NO; [self.playButton setImage:[UIImage systemImageNamed:@"play.fill"] forState:UIControlStateNormal]; }
- (void)updateTime:(CMTime)time {
    if (self.scrubbing || self.duration <= 0) return; double seconds = CMTimeGetSeconds(time); if (!isfinite(seconds)) return;
    self.timeline.value = seconds / self.duration; self.timeLabel.text = [self timeText:seconds];
    double drift = fabs(CMTimeGetSeconds(self.stabilizedPlayer.currentTime) - seconds);
    if (self.playing) { self.syncLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LocKey.FileImportComparisonSynchronizedFormat", nil), drift * 1000]; if (drift > .08 && CACurrentMediaTime() - self.lastCorrection > .5) { self.lastCorrection = CACurrentMediaTime(); [self.stabilizedPlayer setRate:1 time:time atHostTime:CMClockGetTime(CMClockGetHostTimeClock())]; } }
}
- (void)playbackEnded { self.playing = NO; [self.playButton setImage:[UIImage systemImageNamed:@"arrow.counterclockwise"] forState:UIControlStateNormal]; }
- (NSString *)timeText:(NSTimeInterval)value { NSInteger now = MAX(0, (NSInteger)value), total = MAX(0, (NSInteger)self.duration); return [NSString stringWithFormat:@"%02ld:%02ld / %02ld:%02ld", (long)now/60, (long)now%60, (long)total/60, (long)total%60]; }
@end
