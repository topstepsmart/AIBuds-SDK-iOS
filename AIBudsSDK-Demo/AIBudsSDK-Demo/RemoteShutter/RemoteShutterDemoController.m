//
//  RemoteShutterDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-09.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "RemoteShutterDemoController.h"
#import <AVFoundation/AVFoundation.h>

@interface RemoteShutterDemoController () <AVCapturePhotoCaptureDelegate>

@property (nonatomic, strong) UIView *mainContainerView;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *instructionLabel;
@property (nonatomic, strong) UIImage *capturedImage;

// 相机相关
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *captureInput;
@property (nonatomic, strong) AVCapturePhotoOutput *photoOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation RemoteShutterDemoController



- (void)dealloc {
    // 注销通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";//NSLocalizedString(@"LocKey.PhotoTakingTitle", comment:@"Photo Taking");
    [self setupUI];
    [self requestCameraPermission];
}

- (void)registerNotifications {
    // 注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRemoteShutterExit:) name:@"RemoteShutterExit" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRemoteShutterCapture:) name:@"RemoteShutterCapture" object:nil];
}

- (void)handleRemoteShutterExit:(NSNotification *)notification {
    // 处理 RemoteShutterExit 通知
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleRemoteShutterCapture:(NSNotification *)notification {
    // 处理 RemoteShutterCapture 通知
    [self deviceTriggeredCapture];
}



- (void)requestCameraPermission {
    // 请求相机权限
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{            
            if (granted) {
                [self setupCamera];
            } else {
                self.statusLabel.text = NSLocalizedString(@"LocKey.CameraPermissionDenied", comment:@"Camera permission denied");
                self.statusLabel.textColor = [UIColor systemRedColor];
                id<AIBudsDeviceRemoteShutterAPI> remoteShutterDevice = (id<AIBudsDeviceRemoteShutterAPI>)self.device;
                if (![remoteShutterDevice conformsToProtocol:@protocol(AIBudsDeviceRemoteShutterAPI)]) return;
                [remoteShutterDevice syncRemoteShutterStateToDevice:AIBudsRemoteShutterStateExitedOrUnableToEnter completion:^(BOOL success, NSError * _Nullable error) {
                    
                }];
            }
        });
    }];
}

- (void)setupCamera {
    // 创建捕获会话
    self.captureSession = [[AVCaptureSession alloc] init];
    
    // 配置输入设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    self.captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (error) {
        self.statusLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"LocKey.CameraError", comment:@"Camera error"), error.localizedDescription];
        self.statusLabel.textColor = [UIColor systemRedColor];
        return;
    }
    
    if ([self.captureSession canAddInput:self.captureInput]) {
        [self.captureSession addInput:self.captureInput];
    }
    
    // 配置输出
    self.photoOutput = [[AVCapturePhotoOutput alloc] init];
    if ([self.captureSession canAddOutput:self.photoOutput]) {
        [self.captureSession addOutput:self.photoOutput];
    }
    
    // 设置预览层
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = self.previewImageView.bounds;
    [self.previewImageView.layer addSublayer:self.previewLayer];
    
    // 开始捕获会话（在后台线程中）
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{        
        [self.captureSession startRunning];
        // 回到主线程更新 UI
        dispatch_async(dispatch_get_main_queue(), ^{            
            self.statusLabel.text = NSLocalizedString(@"LocKey.CameraReady", comment:@"Camera ready");
            self.statusLabel.textColor = [UIColor systemGreenColor];
        });
    });
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    id<AIBudsDeviceRemoteShutterAPI> remoteShutterDevice = (id<AIBudsDeviceRemoteShutterAPI>)self.device;
    if (![remoteShutterDevice conformsToProtocol:@protocol(AIBudsDeviceRemoteShutterAPI)]) return;
    [remoteShutterDevice syncRemoteShutterStateToDevice:AIBudsRemoteShutterStateEnteredPhotoMode completion:^(BOOL success, NSError * _Nullable error) {
        
    }];
    [self resetUI];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor blackColor];
    
    // 创建主容器视图
    self.mainContainerView = [[UIView alloc] init];
    self.mainContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.mainContainerView];
    
    // 预览图像视图
    self.previewImageView = [[UIImageView alloc] init];
    self.previewImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.previewImageView.backgroundColor = [UIColor blackColor];
    self.previewImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mainContainerView addSubview:self.previewImageView];
    
    // 创建半透明覆盖层，用于显示文本信息
    UIView *overlayView = [[UIView alloc] init];
    overlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.01];
    overlayView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mainContainerView addSubview:overlayView];
    
    // 状态标签 - 只保留最重要的状态信息
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = NSLocalizedString(@"LocKey.RemoteShutterReady", comment:@"Ready for remote capture");
    self.statusLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    self.statusLabel.textColor = [UIColor whiteColor];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [overlayView addSubview:self.statusLabel];
    
    // 拍照按钮
    self.captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.captureButton setImage:[self createCaptureButtonImage] forState:UIControlStateNormal];
    [self.captureButton addTarget:self action:@selector(captureButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.captureButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mainContainerView addSubview:self.captureButton];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [self.mainContainerView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.mainContainerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.mainContainerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.mainContainerView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        // 预览图像视图全屏显示
        [self.previewImageView.topAnchor constraintEqualToAnchor:self.mainContainerView.topAnchor],
        [self.previewImageView.leadingAnchor constraintEqualToAnchor:self.mainContainerView.leadingAnchor],
        [self.previewImageView.trailingAnchor constraintEqualToAnchor:self.mainContainerView.trailingAnchor],
        [self.previewImageView.bottomAnchor constraintEqualToAnchor:self.mainContainerView.bottomAnchor],
        
        // 覆盖层约束
        [overlayView.topAnchor constraintEqualToAnchor:self.mainContainerView.topAnchor],
        [overlayView.leadingAnchor constraintEqualToAnchor:self.mainContainerView.leadingAnchor],
        [overlayView.trailingAnchor constraintEqualToAnchor:self.mainContainerView.trailingAnchor],
        [overlayView.bottomAnchor constraintEqualToAnchor:self.mainContainerView.bottomAnchor],
        
        // 状态标签约束 - 放在拍照按钮上方
        [self.statusLabel.centerXAnchor constraintEqualToAnchor:overlayView.centerXAnchor],
        [self.statusLabel.bottomAnchor constraintEqualToAnchor:self.captureButton.topAnchor constant:-20],
        [self.statusLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:overlayView.leadingAnchor constant:20],
        [self.statusLabel.trailingAnchor constraintLessThanOrEqualToAnchor:overlayView.trailingAnchor constant:-20],
        
        // 拍照按钮约束
        [self.captureButton.centerXAnchor constraintEqualToAnchor:self.mainContainerView.centerXAnchor],
        [self.captureButton.bottomAnchor constraintEqualToAnchor:self.mainContainerView.bottomAnchor constant:-60],
        [self.captureButton.widthAnchor constraintEqualToConstant:80],
        [self.captureButton.heightAnchor constraintEqualToConstant:80]
    ]];
    

}

- (UIImage *)createCaptureButtonImage {
    // 创建拍照按钮图像
    CGRect rect = CGRectMake(0, 0, 80, 80);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 绘制按钮外圈
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillEllipseInRect(context, rect);
    
    // 绘制按钮内圈
    CGRect innerRect = CGRectInset(rect, 10, 10);
    CGContextSetFillColorWithColor(context, [UIColor systemRedColor].CGColor);
    CGContextFillEllipseInRect(context, innerRect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)resetUI {
    if (!self.capturedImage) {
        // 只在没有拍摄照片时重置状态
        self.statusLabel.text = NSLocalizedString(@"LocKey.RemoteShutterReady", comment:@"Ready for remote capture");
        self.statusLabel.textColor = [UIColor whiteColor];
    }
    self.capturedImage = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    id<AIBudsDeviceRemoteShutterAPI> remoteShutterDevice = (id<AIBudsDeviceRemoteShutterAPI>)self.device;
    if (![remoteShutterDevice conformsToProtocol:@protocol(AIBudsDeviceRemoteShutterAPI)]) return;
    [remoteShutterDevice syncRemoteShutterStateToDevice:AIBudsRemoteShutterStateExitedOrUnableToEnter completion:^(BOOL success, NSError * _Nullable error) {
        
    }];
    
    // 停止相机会话（在后台线程中）
    if ([self.captureSession isRunning]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.captureSession stopRunning];
        });
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // 调整预览层大小
    if (self.previewLayer) {
        self.previewLayer.frame = self.previewImageView.bounds;
    }
}

- (void)captureButtonTapped {
    [self simulateRemoteCapture];
}

- (void)simulateRemoteCapture {
    // 实际拍照过程
    self.statusLabel.text = NSLocalizedString(@"LocKey.RemoteShutterCapturing", comment:@"Capturing...");
    self.statusLabel.textColor = [UIColor systemYellowColor];
    
    // 配置拍照设置
    AVCapturePhotoSettings *photoSettings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey: AVVideoCodecTypeJPEG}];
    
    // 开始拍照
    [self.photoOutput capturePhotoWithSettings:photoSettings delegate:self];
}

// AVCapturePhotoCaptureDelegate 方法
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{        
        if (error) {
            self.statusLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"LocKey.RemoteShutterCaptureFailed", comment:@"Capture failed"), error.localizedDescription];
            self.statusLabel.textColor = [UIColor systemRedColor];
            id<AIBudsDeviceRemoteShutterAPI> remoteShutterDevice = (id<AIBudsDeviceRemoteShutterAPI>)self.device;
            if (![remoteShutterDevice conformsToProtocol:@protocol(AIBudsDeviceRemoteShutterAPI)]) return;
            [remoteShutterDevice syncRemoteShutterStateToDevice:AIBudsRemoteShutterStatePhotoFailed completion:^(BOOL success, NSError * _Nullable error) {
                
            }];
            return;
        }
        
        // 处理拍摄的照片
        NSData *imageData = [photo fileDataRepresentation];
        UIImage *capturedImage = [UIImage imageWithData:imageData];
        
        self.capturedImage = capturedImage;
        self.previewImageView.image = capturedImage;
        self.statusLabel.text = NSLocalizedString(@"LocKey.RemoteShutterCaptureSuccess", comment:@"Capture successful!");
        self.statusLabel.textColor = [UIColor systemGreenColor];
        
        id<AIBudsDeviceRemoteShutterAPI> remoteShutterDevice = (id<AIBudsDeviceRemoteShutterAPI>)self.device;
        if (![remoteShutterDevice conformsToProtocol:@protocol(AIBudsDeviceRemoteShutterAPI)]) return;
        [remoteShutterDevice syncRemoteShutterStateToDevice:AIBudsRemoteShutterStatePhotoSuccess completion:^(BOOL success, NSError * _Nullable error) {
            
        }];
    });
}



// 设备端触发拍照的接口
- (void)deviceTriggeredCapture {
    // 当设备端发送拍照指令时，调用此方法
    [self simulateRemoteCapture];
}

@end
