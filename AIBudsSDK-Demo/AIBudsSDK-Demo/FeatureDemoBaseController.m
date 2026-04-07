//
//  FeatureDemoBaseController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-03-02.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "FeatureDemoBaseController.h"

@interface FeatureDemoBaseController ()

@end

@implementation FeatureDemoBaseController

-(instancetype) initWithDevice:(id<AIBudsDeviceConvertible>)device
{
    self = [super init];
    if (self) {
        self.device = device;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
