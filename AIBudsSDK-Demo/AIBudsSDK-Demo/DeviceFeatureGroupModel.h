//
//  DeviceFeatureGroupModel.h
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-03-02.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceFeatureModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceFeatureGroupModel : NSObject

@property(nonatomic, strong) NSString *icon;

@property(nonatomic, strong) NSString *name;

@property(nonatomic, strong) NSArray<DeviceFeatureModel *> *features;

+ (instancetype)modelWithIcon:(NSString *)icon name:(NSString *)name features:(NSArray<DeviceFeatureModel *> *)features;

@end

NS_ASSUME_NONNULL_END
