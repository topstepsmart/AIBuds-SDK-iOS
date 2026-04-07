//
//  DeviceInfoItemModel.h
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-06.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceInfoItemModel : NSObject

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *detailsInfo;
@property(nonatomic, assign) BOOL isComplex;
@property(nonatomic, assign) BOOL isIcon;
@property(nonatomic, strong) UIImage *icon;

+ (instancetype)modelWithName:(NSString *)name
                  detailsInfo:(NSString *)detailsInfo
                    isComplex:(BOOL)isComplex;

+ (instancetype)modelWithName:(NSString *)name
                  detailsInfo:(NSString *)detailsInfo
                    isComplex:(BOOL)isComplex
                         icon:(UIImage *)icon
                       isIcon:(BOOL)isIcon;

@end

NS_ASSUME_NONNULL_END
