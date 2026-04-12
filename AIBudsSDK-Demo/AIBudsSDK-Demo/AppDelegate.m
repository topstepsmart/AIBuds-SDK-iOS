//
//  AppDelegate.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-02-13.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "AppDelegate.h"
#import <Reachability/Reachability.h>
#import <objc/runtime.h>

@interface AppDelegate ()<AIBudsSDKDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    Reachability* reachability = [Reachability reachabilityForLocalWiFi];
    reachability.reachableBlock = ^(Reachability *reachability) {
      NSLog(@"%@", @"网络可用");
    };
    reachability.unreachableBlock = ^(Reachability *reachability) {
      NSLog(@"%@", @"网络不可用");
    };
    [reachability startNotifier];
    //AIBudsLogConfiguration* sdkLogConfiguration = [AIBudsLogConfiguration shared];
    //sdkLogConfiguration.destination = AIBudsLogDestinationFile;
    [AIBudsLogSDK setXLFacilityPlugin:[AIBudsXLFacilitySDK shared]];
    /*iOSLogBrowserOption* option = [iOSLogBrowserOption defaultOption];
    option.minLogLevel = SDKLOGLEVEL_VERBOSE;
    option.suspendInBackground = YES;
    option.showQueueNameInBrowser = YES;
    option.consoleLoggerFormatString = @"[%x] %d %P[%p:%r] [%q] %m";
    [iOSLogBrowserSDK startWithOption:option];*/
    AIBudsSDKConfiguration* sdkConfiguration = [AIBudsSDKConfiguration defaultConfiguration];
    sdkConfiguration.logLevel = AIBudsLogLevelVerbose;
    BOOL success = [AIBudsSDK initWithBleSDKs:@[[ABMateSDK shared]]
                                               configuration:sdkConfiguration
                                                    delegate:self];
    if(!success) {
        XLOG_ERROR(@"%@", APP_LOG_STRING(@"%@", @"AIBudsSDK initialize failed."));
    }
    [AIBudsSDK setStarBurstAIPlugin:[AIBudsStarBurstAuthPlugin shared]];
    [AIBudsSDK setMltCloudAIPlugin:[AIBudsMltCloudAuthPlugin shared]];
    [AIBudsSDK setOnDeviceVoiceAssistantPlugin:[AIBudsOnDeviceVoiceAssistantPlugin shared]];
    
    success = [AIBudsAISDK initWithAISDKs:@[[AIBudsStarBurstSDK shared],
                                            [AIBudsMagicHelperSDK shared]]];
    if(!success) {
        XLOG_ERROR(@"%@", APP_LOG_STRING(@"%@", @"AIBudsAISDK initialize failed."));
    }
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


#pragma mark - AIBudsSDKDelegate

/// Called when the Bluetooth scanning status changes
/// - Parameters:
///   - isScanning: A boolean value indicating whether the device is currently scanning for Bluetooth devices
///     - `true`: Scanning is in progress
///     - `false`: Scanning has stopped
- (void)onScanningStatusChanged:(BOOL)isScanning {
    XLOG_VERBOSE(@"%@", APP_LOG_STRING(@"onScanningStatusChanged: %@", isScanning ? @".scanningStarted" : @".scanningStopped"));
}

@end
