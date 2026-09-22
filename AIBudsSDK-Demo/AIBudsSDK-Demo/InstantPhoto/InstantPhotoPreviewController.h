//
//  InstantPhotoPreviewController.h
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-09-18.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InstantPhotoPreviewController : UIViewController

- (instancetype)initWithImage:(UIImage *)image photoData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
