//
//  AssignPhysicalOperationsDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-07.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "AssignPhysicalOperationsDemoController.h"

@interface AssignPhysicalOperationsDemoController () <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *operationsMapping;
@property (nonatomic, strong) UIPickerView *functionPicker;
@property (nonatomic, strong) UIView *pickerContainer;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, assign) NSInteger selectedRow;
@property (nonatomic, strong) NSArray *availableFunctions;

@end

@implementation AssignPhysicalOperationsDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupOperationsMapping];
    [self setupAvailableFunctions];
    [self setupFunctionPicker];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"LocKey.AssignPhysicalOperations", comment:@"Assign Physical Operations");
    
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

- (void)setupAvailableFunctions {
    // Create array of available functions
    self.availableFunctions = @[
        @{@"value": @(AIBudsDeviceFunctionNone), @"name": NSLocalizedString(@"LocKey.FunctionNone", comment:@"None")},
        @{@"value": @(AIBudsDeviceFunctionRedial), @"name": NSLocalizedString(@"LocKey.FunctionRedial", comment:@"Redial")},
        @{@"value": @(AIBudsDeviceFunctionVoiceAssistant), @"name": NSLocalizedString(@"LocKey.FunctionVoiceAssistant", comment:@"Voice Assistant")},
        @{@"value": @(AIBudsDeviceFunctionPreviousTrack), @"name": NSLocalizedString(@"LocKey.FunctionPreviousTrack", comment:@"Previous Track")},
        @{@"value": @(AIBudsDeviceFunctionNextTrack), @"name": NSLocalizedString(@"LocKey.FunctionNextTrack", comment:@"Next Track")},
        @{@"value": @(AIBudsDeviceFunctionVolumeUp), @"name": NSLocalizedString(@"LocKey.FunctionVolumeUp", comment:@"Volume Up")},
        @{@"value": @(AIBudsDeviceFunctionVolumeDown), @"name": NSLocalizedString(@"LocKey.FunctionVolumeDown", comment:@"Volume Down")},
        @{@"value": @(AIBudsDeviceFunctionPlayPause), @"name": NSLocalizedString(@"LocKey.FunctionPlayPause", comment:@"Play / Pause")},
        @{@"value": @(AIBudsDeviceFunctionGameMode), @"name": NSLocalizedString(@"LocKey.FunctionGameMode", comment:@"Game Mode")},
        @{@"value": @(AIBudsDeviceFunctionNoiseReduction), @"name": NSLocalizedString(@"LocKey.FunctionNoiseReduction", comment:@"Noise Reduction")},
        @{@"value": @(AIBudsDeviceFunctionTakePhoto), @"name": NSLocalizedString(@"LocKey.FunctionTakePhoto", comment:@"Take Photo")},
        @{@"value": @(AIBudsDeviceFunctionContinuousShooting), @"name": NSLocalizedString(@"LocKey.FunctionContinuousShooting", comment:@"Continuous Shooting")},
        @{@"value": @(AIBudsDeviceFunctionVideoRecordToggle), @"name": NSLocalizedString(@"LocKey.FunctionVideoRecordToggle", comment:@"Video Record Toggle")},
        @{@"value": @(AIBudsDeviceFunctionAudioRecordToggle), @"name": NSLocalizedString(@"LocKey.FunctionAudioRecordToggle", comment:@"Audio Record Toggle")},
        @{@"value": @(AIBudsDeviceFunctionLocalBluetoothToggle), @"name": NSLocalizedString(@"LocKey.FunctionLocalBluetoothToggle", comment:@"Local / Bluetooth Toggle")},
    ];
}

- (void)setupFunctionPicker {
    // Picker Container
    self.pickerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 250)];
    self.pickerContainer.backgroundColor = [UIColor whiteColor];
    self.pickerContainer.layer.cornerRadius = 10.0;
    self.pickerContainer.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    [self.view addSubview:self.pickerContainer];
    
    // Function Picker
    self.functionPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, self.view.bounds.size.width, 180)];
    self.functionPicker.delegate = self;
    self.functionPicker.dataSource = self;
    [self.pickerContainer addSubview:self.functionPicker];
    
    // Button Container
    UIView *buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    buttonContainer.backgroundColor = [UIColor systemGray6Color];
    [self.pickerContainer addSubview:buttonContainer];
    
    // Cancel Button
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.cancelButton setTitle:NSLocalizedString(@"CancelLocKey", comment:@"Cancel") forState:UIControlStateNormal];
    self.cancelButton.frame = CGRectMake(20, 5, 80, 30);
    [self.cancelButton addTarget:self action:@selector(cancelFunctionSelection) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainer addSubview:self.cancelButton];
    
    // Confirm Button
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.confirmButton setTitle:NSLocalizedString(@"ConfirmLocKey", comment:@"Confirm") forState:UIControlStateNormal];
    self.confirmButton.frame = CGRectMake(self.view.bounds.size.width - 100, 5, 80, 30);
    [self.confirmButton addTarget:self action:@selector(confirmFunctionSelection) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainer addSubview:self.confirmButton];
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
    for (NSDictionary *function in self.availableFunctions) {
        if ([function[@"value"] integerValue] == value) {
            return function[@"name"];
        }
    }
    return NSLocalizedString(@"LocKey.FunctionUnknown", comment:@"Unknown");
}

- (void)showFunctionPickerForRow:(NSInteger)row {
    self.selectedRow = row;
    
    // Get current function for the selected operation
    NSDictionary *mapping = self.operationsMapping[row];
    NSNumber *functionNumber = mapping[@"function"];
    
    // Select the current function in the picker
    for (NSInteger i = 0; i < self.availableFunctions.count; i++) {
        if ([self.availableFunctions[i][@"value"] isEqual: functionNumber]) {
            [self.functionPicker selectRow:i inComponent:0 animated:NO];
            break;
        }
    }
    
    // Show picker with animation
    [UIView animateWithDuration:0.3 animations:^{        
        self.pickerContainer.frame = CGRectMake(0, self.view.bounds.size.height - 250, self.view.bounds.size.width, 250);
    }];
}

- (void)hideFunctionPicker {
    [UIView animateWithDuration:0.3 animations:^{        
        self.pickerContainer.frame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 250);
    }];
}

- (void)cancelFunctionSelection {
    [self hideFunctionPicker];
}

- (void)confirmFunctionSelection {
    // Get selected function
    NSInteger selectedFunctionIndex = [self.functionPicker selectedRowInComponent:0];
    NSDictionary *selectedFunction = self.availableFunctions[selectedFunctionIndex];
    NSNumber *functionValue = selectedFunction[@"value"];
    
    // Update the mapping
    NSDictionary *mapping = self.operationsMapping[self.selectedRow];
    NSNumber *operationValue = mapping[@"operation"];
    
    // Assign function to operation
    id<AIBudsDevicePhysicalOperationsAPI> device = (id<AIBudsDevicePhysicalOperationsAPI>)self.device;
    if([device conformsToProtocol:@protocol(AIBudsDevicePhysicalOperationsAPI)]) {
        [device assignFunction:(AIBudsDeviceFunction)functionValue.integerValue forPhysicalOperation:(AIBudsDeviceOperation)operationValue.integerValue completion:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{ 
                if (success) {
                    // Update the local mapping
                    self.operationsMapping[self.selectedRow] = @{@"operation": operationValue, @"function": functionValue};
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.selectedRow inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self hideFunctionPicker];
                } else {
                    // Show error message
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", comment:@"Error") message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", comment:@"OK") style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            });
        }];
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self showFunctionPickerForRow:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

#pragma mark - UIPickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.availableFunctions.count;
}

#pragma mark - UIPickerView Delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.availableFunctions[row][@"name"];
}

@end
