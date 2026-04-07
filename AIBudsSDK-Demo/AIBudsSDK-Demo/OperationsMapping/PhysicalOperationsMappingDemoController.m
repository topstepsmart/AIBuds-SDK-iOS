//
//  PhysicalOperationsMappingDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-07.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "PhysicalOperationsMappingDemoController.h"

@interface PhysicalOperationsMappingDemoController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *operationsMapping;

@end

@implementation PhysicalOperationsMappingDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupOperationsMapping];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"LocKey.PhysicalOperationsMapping", comment:@"Physical Operations Mapping");
    
    // Table View
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
    
    // Layout Constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
    ]];
}

- (void)setupOperationsMapping {
    self.operationsMapping = [NSMutableArray new];
    
    if (!self.device) {
        return;
    }
    
    // Get physical operations mapping from device
    NSDictionary<NSNumber *, NSNumber *> *mapping = [(id<AIBudsDevicePhysicalOperationsAPI>)self.device physicalOperationsMapping];
    
    // Create array of operations with their functions
    for (NSNumber *operationNumber in mapping.allKeys) {
        NSNumber *functionNumber = mapping[operationNumber];
        [self.operationsMapping addObject:@{@"operation": operationNumber, @"function": functionNumber}];
    }
    
    // Sort by operation value
    [self.operationsMapping sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        NSNumber *op1 = obj1[@"operation"];
        NSNumber *op2 = obj2[@"operation"];
        return [op1 compare:op2];
    }];
}

- (NSString *)operationNameForValue:(NSInteger)value {
    AIBudsDeviceOperation operation = (AIBudsDeviceOperation)value;
    switch (operation) {
        case AIBudsDeviceOperationUnknown:
            return NSLocalizedString(@"LocKey.OperationUnknown", comment:@"Unknown");
        case AIBudsDeviceOperationLeftSingleClick:
            return NSLocalizedString(@"LocKey.OperationLeftSingleClick", comment:@"Left Single Click");
        case AIBudsDeviceOperationRightSingleClick:
            return NSLocalizedString(@"LocKey.OperationRightSingleClick", comment:@"Right Single Click");
        case AIBudsDeviceOperationLeftDoubleClick:
            return NSLocalizedString(@"LocKey.OperationLeftDoubleClick", comment:@"Left Double Click");
        case AIBudsDeviceOperationRightDoubleClick:
            return NSLocalizedString(@"LocKey.OperationRightDoubleClick", comment:@"Right Double Click");
        case AIBudsDeviceOperationLeftTripleClick:
            return NSLocalizedString(@"LocKey.OperationLeftTripleClick", comment:@"Left Triple Click");
        case AIBudsDeviceOperationRightTripleClick:
            return NSLocalizedString(@"LocKey.OperationRightTripleClick", comment:@"Right Triple Click");
        case AIBudsDeviceOperationLeftLongPress:
            return NSLocalizedString(@"LocKey.OperationLeftLongPress", comment:@"Left Long Press");
        case AIBudsDeviceOperationRightLongPress:
            return NSLocalizedString(@"LocKey.OperationRightLongPress", comment:@"Right Long Press");
        case AIBudsDeviceOperationLeftTouchSingleClick:
            return NSLocalizedString(@"LocKey.OperationLeftTouchSingleClick", comment:@"Left Touch Single Click");
        case AIBudsDeviceOperationRightTouchSingleClick:
            return NSLocalizedString(@"LocKey.OperationRightTouchSingleClick", comment:@"Right Touch Single Click");
        case AIBudsDeviceOperationLeftTouchDoubleClick:
            return NSLocalizedString(@"LocKey.OperationLeftTouchDoubleClick", comment:@"Left Touch Double Click");
        case AIBudsDeviceOperationRightTouchDoubleClick:
            return NSLocalizedString(@"LocKey.OperationRightTouchDoubleClick", comment:@"Right Touch Double Click");
        case AIBudsDeviceOperationLeftTouchLongPress:
            return NSLocalizedString(@"LocKey.OperationLeftTouchLongPress", comment:@"Left Touch Long Press");
        case AIBudsDeviceOperationRightTouchLongPress:
            return NSLocalizedString(@"LocKey.OperationRightTouchLongPress", comment:@"Right Touch Long Press");
        case AIBudsDeviceOperationLeftButton1SingleClick:
            return NSLocalizedString(@"LocKey.OperationLeftButton1SingleClick", comment:@"Left Button 1 Single Click");
        case AIBudsDeviceOperationRightButton1SingleClick:
            return NSLocalizedString(@"LocKey.OperationRightButton1SingleClick", comment:@"Right Button 1 Single Click");
        case AIBudsDeviceOperationLeftButton1DoubleClick:
            return NSLocalizedString(@"LocKey.OperationLeftButton1DoubleClick", comment:@"Left Button 1 Double Click");
        case AIBudsDeviceOperationRightButton1DoubleClick:
            return NSLocalizedString(@"LocKey.OperationRightButton1DoubleClick", comment:@"Right Button 1 Double Click");
        case AIBudsDeviceOperationLeftButton1LongPress:
            return NSLocalizedString(@"LocKey.OperationLeftButton1LongPress", comment:@"Left Button 1 Long Press");
        case AIBudsDeviceOperationRightButton1LongPress:
            return NSLocalizedString(@"LocKey.OperationRightButton1LongPress", comment:@"Right Button 1 Long Press");
        case AIBudsDeviceOperationLeftButton2SingleClick:
            return NSLocalizedString(@"LocKey.OperationLeftButton2SingleClick", comment:@"Left Button 2 Single Click");
        case AIBudsDeviceOperationRightButton2SingleClick:
            return NSLocalizedString(@"LocKey.OperationRightButton2SingleClick", comment:@"Right Button 2 Single Click");
        case AIBudsDeviceOperationLeftButton2DoubleClick:
            return NSLocalizedString(@"LocKey.OperationLeftButton2DoubleClick", comment:@"Left Button 2 Double Click");
        case AIBudsDeviceOperationRightButton2DoubleClick:
            return NSLocalizedString(@"LocKey.OperationRightButton2DoubleClick", comment:@"Right Button 2 Double Click");
        case AIBudsDeviceOperationLeftButton2LongPress:
            return NSLocalizedString(@"LocKey.OperationLeftButton2LongPress", comment:@"Left Button 2 Long Press");
        case AIBudsDeviceOperationRightButton2LongPress:
            return NSLocalizedString(@"LocKey.OperationRightButton2LongPress", comment:@"Right Button 2 Long Press");
        case AIBudsDeviceOperationTouchSlideBackwardToForward:
            return NSLocalizedString(@"LocKey.OperationTouchSlideBackwardToForward", comment:@"Touch Slide Backward To Forward");
        case AIBudsDeviceOperationTouchSlideForwardToBackward:
            return NSLocalizedString(@"LocKey.OperationTouchSlideForwardToBackward", comment:@"Touch Slide Forward To Backward");
        default:
            return NSLocalizedString(@"LocKey.OperationUnknown", comment:@"Unknown");
    }
}

- (NSString *)functionNameForValue:(NSInteger)value {
    AIBudsDeviceFunction function = (AIBudsDeviceFunction)value;
    switch (function) {
        case AIBudsDeviceFunctionNone:
            return NSLocalizedString(@"LocKey.FunctionNone", comment:@"None");
        case AIBudsDeviceFunctionRedial:
            return NSLocalizedString(@"LocKey.FunctionRedial", comment:@"Redial");
        case AIBudsDeviceFunctionVoiceAssistant:
            return NSLocalizedString(@"LocKey.FunctionVoiceAssistant", comment:@"Voice Assistant");
        case AIBudsDeviceFunctionPreviousTrack:
            return NSLocalizedString(@"LocKey.FunctionPreviousTrack", comment:@"Previous Track");
        case AIBudsDeviceFunctionNextTrack:
            return NSLocalizedString(@"LocKey.FunctionNextTrack", comment:@"Next Track");
        case AIBudsDeviceFunctionVolumeUp:
            return NSLocalizedString(@"LocKey.FunctionVolumeUp", comment:@"Volume Up");
        case AIBudsDeviceFunctionVolumeDown:
            return NSLocalizedString(@"LocKey.FunctionVolumeDown", comment:@"Volume Down");
        case AIBudsDeviceFunctionPlayPause:
            return NSLocalizedString(@"LocKey.FunctionPlayPause", comment:@"Play / Pause");
        case AIBudsDeviceFunctionGameMode:
            return NSLocalizedString(@"LocKey.FunctionGameMode", comment:@"Game Mode");
        case AIBudsDeviceFunctionNoiseReduction:
            return NSLocalizedString(@"LocKey.FunctionNoiseReduction", comment:@"Noise Reduction");
        case AIBudsDeviceFunctionTakePhoto:
            return NSLocalizedString(@"LocKey.FunctionTakePhoto", comment:@"Take Photo");
        case AIBudsDeviceFunctionContinuousShooting:
            return NSLocalizedString(@"LocKey.FunctionContinuousShooting", comment:@"Continuous Shooting");
        case AIBudsDeviceFunctionVideoRecordToggle:
            return NSLocalizedString(@"LocKey.FunctionVideoRecordToggle", comment:@"Video Record Toggle");
        case AIBudsDeviceFunctionAudioRecordToggle:
            return NSLocalizedString(@"LocKey.FunctionAudioRecordToggle", comment:@"Audio Record Toggle");
        case AIBudsDeviceFunctionLocalBluetoothToggle:
            return NSLocalizedString(@"LocKey.FunctionLocalBluetoothToggle", comment:@"Local / Bluetooth Toggle");
        default:
            return NSLocalizedString(@"LocKey.FunctionUnknown", comment:@"Unknown");
    }
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.operationsMapping.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"OperationsMappingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *mapping = self.operationsMapping[indexPath.row];
    NSNumber *operationNumber = mapping[@"operation"];
    NSNumber *functionNumber = mapping[@"function"];
    
    cell.textLabel.text = [self operationNameForValue:operationNumber.integerValue];
    cell.detailTextLabel.text = [self functionNameForValue:functionNumber.integerValue];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

@end
