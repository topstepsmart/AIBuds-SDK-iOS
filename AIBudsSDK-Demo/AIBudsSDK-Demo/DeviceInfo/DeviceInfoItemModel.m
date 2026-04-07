//
//  DeviceInfoItemModel.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-06.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "DeviceInfoItemModel.h"

@implementation DeviceInfoItemModel

+ (instancetype)modelWithName:(NSString *)name
                          detailsInfo:(NSString *)detailsInfo
                            isComplex:(BOOL)isComplex {
    DeviceInfoItemModel* model = [DeviceInfoItemModel new];
    model.name = name;
    model.detailsInfo = detailsInfo;
    model.isComplex = isComplex;
    model.icon = nil;
    model.isIcon = NO;
    return model;
}

+ (instancetype)modelWithName:(NSString *)name
                  detailsInfo:(NSString *)detailsInfo
                    isComplex:(BOOL)isComplex
                          icon:(UIImage *)icon
                        isIcon:(BOOL)isIcon {
    DeviceInfoItemModel* model = [DeviceInfoItemModel new];
    model.name = name;
    model.detailsInfo = detailsInfo;
    model.isComplex = isComplex;
    model.icon = icon;
    model.isIcon = isIcon;
    return model;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"";
        self.detailsInfo = @"";
        self.isComplex = NO;
        self.icon = nil;
        self.isIcon = NO;
    }
    return self;
}

@end
