//
//  InstantPhotoPreviewController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-09-18.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "InstantPhotoPreviewController.h"

@interface InstantPhotoPreviewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSData *photoData;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIToolbar *bottomToolbar;
@property (nonatomic, strong) UIBarButtonItem *saveButton;
@property (nonatomic, strong) UIBarButtonItem *shareButton;
@property (nonatomic, strong) UIBarButtonItem *closeButton;

@end

@implementation InstantPhotoPreviewController

- (instancetype)initWithImage:(UIImage *)image photoData:(NSData *)data {
    self = [super init];
    if (self) {
        _image = image;
        _photoData = data;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBarHidden = NO;

    _scrollView = [[UIScrollView alloc] init];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.delegate = self;
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.maximumZoomScale = 4.0;
    _scrollView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_scrollView];

    _imageView = [[UIImageView alloc] initWithImage:self.image];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_imageView];

    _bottomToolbar = [[UIToolbar alloc] init];
    _bottomToolbar.translatesAutoresizingMaskIntoConstraints = NO;
    _bottomToolbar.barStyle = UIBarStyleBlack;
    [self.view addSubview:_bottomToolbar];

    _saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LocKey.InstantPhotoSaveToAlbum", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveToAlbum)];
    _shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sharePhoto)];
    _closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemClose target:self action:@selector(closePreview)];

    _bottomToolbar.items = @[
        _closeButton,
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
        _shareButton,
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
        _saveButton,
    ];

    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.bottomToolbar.topAnchor],

        [self.imageView.centerXAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.centerXAnchor],
        [self.imageView.centerYAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.centerYAnchor],
        [self.imageView.widthAnchor constraintEqualToAnchor:self.scrollView.frameLayoutGuide.widthAnchor],
        [self.imageView.heightAnchor constraintEqualToAnchor:self.scrollView.frameLayoutGuide.heightAnchor],

        [self.bottomToolbar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.bottomToolbar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.bottomToolbar.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [self.bottomToolbar.heightAnchor constraintEqualToConstant:44],
    ]];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

#pragma mark - Actions

- (void)saveToAlbum {
    UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        if (error) {
            alert.message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"LocKey.InstantPhotoSaveFailed", nil), error.localizedDescription];
        } else {
            alert.message = NSLocalizedString(@"LocKey.InstantPhotoSaved", nil);
        }
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"LocKey.OK", nil) style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)sharePhoto {
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.image] applicationActivities:nil];
    activityVC.popoverPresentationController.barButtonItem = self.shareButton;
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)closePreview {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
