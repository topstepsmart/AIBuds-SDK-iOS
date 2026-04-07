//
//  DeviceFeatureModel.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-03-02.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "DeviceFeatureModel.h"

@implementation DeviceFeatureModel

+(instancetype)modelWithIcon:(NSString*)icon name:(NSString*)name classNameOfDemoVC:(NSString* _Nullable)classNameOfDemoVC
{
    DeviceFeatureModel* model = [[DeviceFeatureModel alloc] init];
    model.icon = icon;
    model.name = name;
    model.valueText = nil;
    model.classNameOfDemoVC = classNameOfDemoVC;
    model.handler = nil;
    return model;
}

+(instancetype)modelWithIcon:(NSString*)icon name:(NSString*)name handler:(void(^ _Nullable)(void))handler
{
    DeviceFeatureModel* model = [[DeviceFeatureModel alloc] init];
    model.icon = icon;
    model.name = name;
    model.valueText = nil;
    model.classNameOfDemoVC = nil;
    model.handler = handler;
    
    return model;
}

@end
