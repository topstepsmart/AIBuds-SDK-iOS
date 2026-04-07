//
//  FeatureDemoBaseController.h
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-03-02.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FeatureDemoBaseController : UIViewController

@property (nonatomic, strong) id<AIBudsDeviceConvertible> device;

-(instancetype) initWithDevice:(id<AIBudsDeviceConvertible>)device;

@end

NS_ASSUME_NONNULL_END
