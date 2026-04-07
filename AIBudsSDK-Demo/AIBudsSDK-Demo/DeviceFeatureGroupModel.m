//
//  DeviceFeatureGroupModel.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-03-02.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "DeviceFeatureGroupModel.h"

@implementation DeviceFeatureGroupModel

+(instancetype)modelWithIcon:(NSString*)icon name:(NSString*)name features:(NSArray<DeviceFeatureModel*>*)features
{
    DeviceFeatureGroupModel* model = [[DeviceFeatureGroupModel alloc] init];
    model.icon = icon;
    model.name = name;
    model.features = features;
    return model;
}
@end
