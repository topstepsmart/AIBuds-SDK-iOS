//
//  SimultaneousInterpretationContext.h
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-05-25.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SimultaneousInterpretationContext : NSObject

@property(nonatomic, weak) id<AIBudsSimultaneousInterpretationSessionConvertible> currentSession;

+ (instancetype)sharedInstance;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
