//
//  DeviceFeatureModel.h
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-03-02.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceFeatureModel : NSObject

@property(nonatomic, strong) NSString *icon;

@property(nonatomic, strong) NSString *name;

@property(nonatomic, strong, nullable) NSString *valueText;

@property(nonatomic, strong, nullable) NSString *classNameOfDemoVC;

@property(nonatomic, copy, nullable) void (^handler)(void);

+ (instancetype)modelWithIcon:(NSString *)icon
                         name:(NSString *)name
            classNameOfDemoVC:(NSString *_Nullable)classNameOfDemoVC;

+ (instancetype)modelWithIcon:(NSString *)icon
                         name:(NSString *)name
                      handler:(void (^_Nullable)(void))handler;

@end

NS_ASSUME_NONNULL_END
