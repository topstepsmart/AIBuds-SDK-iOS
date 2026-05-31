//
//  CrashReporterDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-05-14.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "CrashReporterDemoController.h"
#import <objc/runtime.h>


typedef NS_ENUM(NSInteger, CrashType) {
    CrashTypeArrayOutOfBounds = 0,
    CrashTypeNullPointer,
    CrashTypeUnrecognizedSelector,
    CrashTypeAssertion,
    CrashTypeDivideByZero,
    CrashTypeStackOverflow,
    CrashTypeBusError
};

typedef NS_ENUM(NSInteger, CrashReporterSection) {
    CrashReporterSectionTrigger = 0,
    CrashReporterSectionFileList = 1
};

@interface CrashReporterDemoController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *crashFiles;
@property (nonatomic, strong) NSArray *crashTypes;

@end

@implementation CrashReporterDemoController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"LocKey.CrashReporterDemoTitle", @"Crash Reporter");
    self.view.backgroundColor = [UIColor colorWithRed:248/255.0 green:249/255.0 blue:250/255.0 alpha:1.0];

    self.crashTypes = @[
        @{@"type": @(CrashTypeArrayOutOfBounds), @"title": NSLocalizedString(@"LocKey.CrashReporterCrashTypeArrayOutOfBounds", @"Array Out of Bounds")},
        @{@"type": @(CrashTypeUnrecognizedSelector), @"title": NSLocalizedString(@"LocKey.CrashReporterCrashTypeUnrecognizedSelector", @"Unrecognized Selector")},
        @{@"type": @(CrashTypeAssertion), @"title": NSLocalizedString(@"LocKey.CrashReporterCrashTypeAssertion", @"Assertion Failure")},
        @{@"type": @(CrashTypeStackOverflow), @"title": NSLocalizedString(@"LocKey.CrashReporterCrashTypeStackOverflow", @"Stack Overflow")},
        @{@"type": @(CrashTypeBusError), @"title": NSLocalizedString(@"LocKey.CrashReporterCrashTypeBusError", @"Bus Error")}
    ];

    [self setupNavigationBar];
    [self setupTableView];
    [self loadCrashFiles];
}

- (void)setupNavigationBar {
    UIBarButtonItem *deleteAllItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LocKey.CrashReporterDeleteAllAction", @"Delete All")
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(deleteAllCrashFiles)];
    deleteAllItem.tintColor = [UIColor systemRedColor];
    self.navigationItem.rightBarButtonItem = deleteAllItem;
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor colorWithRed:248/255.0 green:249/255.0 blue:250/255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 68;
    [self.view addSubview:self.tableView];
}

- (void)loadCrashFiles {
    NSArray<NSString *> *filePaths = [AIBudsCrashReporterSDK allCrashReportPaths];

    NSMutableArray *files = [NSMutableArray array];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    for (NSString *filePath in filePaths) {
        NSDictionary *attrs = [fileManager attributesOfItemAtPath:filePath error:nil];
        NSString *fileName = [filePath lastPathComponent];

        [files addObject:@{
            @"name": fileName,
            @"path": filePath,
            @"size": attrs[NSFileSize] ?: @(0),
            @"date": attrs[NSFileModificationDate] ?: [NSDate date]
        }];
    }

    self.crashFiles = files;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == CrashReporterSectionTrigger) {
        return self.crashTypes.count;
    } else {
        return MAX(1, self.crashFiles.count);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == CrashReporterSectionTrigger) {
        static NSString *triggerCellId = @"TriggerCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:triggerCellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:triggerCellId];
            cell.backgroundColor = [UIColor whiteColor];
            cell.layer.cornerRadius = 12;
            cell.layer.masksToBounds = YES;

            UIView *selectedBgView = [[UIView alloc] init];
            selectedBgView.backgroundColor = [UIColor colorWithRed:59/255.0 green:130/255.0 blue:246/255.0 alpha:0.1];
            selectedBgView.layer.cornerRadius = 12;
            cell.selectedBackgroundView = selectedBgView;

            UIView *containerView = [[UIView alloc] init];
            containerView.tag = 100;
            containerView.backgroundColor = [UIColor whiteColor];
            containerView.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:containerView];

            [NSLayoutConstraint activateConstraints:@[
                [containerView.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:4],
                [containerView.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:16],
                [containerView.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-16],
                [containerView.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-4],
                [containerView.heightAnchor constraintEqualToConstant:48]
            ]];

            UIImageView *iconView = [[UIImageView alloc] init];
            iconView.tag = 101;
            iconView.tintColor = [UIColor colorWithRed:239/255.0 green:68/255.0 blue:68/255.0 alpha:1.0];
            iconView.contentMode = UIViewContentModeScaleAspectFit;
            iconView.translatesAutoresizingMaskIntoConstraints = NO;
            [containerView addSubview:iconView];

            UILabel *titleLabel = [[UILabel alloc] init];
            titleLabel.tag = 102;
            titleLabel.font = [UIFont systemFontOfSize:15];
            titleLabel.textColor = [UIColor colorWithRed:31/255.0 green:31/255.0 blue:31/255.0 alpha:1.0];
            titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [containerView addSubview:titleLabel];

            UIImageView *arrowView = [[UIImageView alloc] init];
            arrowView.tag = 103;
            arrowView.image = [UIImage systemImageNamed:@"chevron.right"];
            arrowView.tintColor = [UIColor colorWithRed:209/255.0 green:213/255.0 blue:219/255.0 alpha:1.0];
            arrowView.contentMode = UIViewContentModeScaleAspectFit;
            arrowView.translatesAutoresizingMaskIntoConstraints = NO;
            [containerView addSubview:arrowView];

            [NSLayoutConstraint activateConstraints:@[
                [iconView.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:12],
                [iconView.centerYAnchor constraintEqualToAnchor:containerView.centerYAnchor],
                [iconView.widthAnchor constraintEqualToConstant:24],
                [iconView.heightAnchor constraintEqualToConstant:24],

                [titleLabel.leadingAnchor constraintEqualToAnchor:iconView.trailingAnchor constant:12],
                [titleLabel.centerYAnchor constraintEqualToAnchor:containerView.centerYAnchor],

                [arrowView.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-12],
                [arrowView.centerYAnchor constraintEqualToAnchor:containerView.centerYAnchor],
                [arrowView.widthAnchor constraintEqualToConstant:12],
                [arrowView.heightAnchor constraintEqualToConstant:12],

                [titleLabel.trailingAnchor constraintEqualToAnchor:arrowView.leadingAnchor constant:-8]
            ]];
        }

        NSDictionary *crashType = self.crashTypes[indexPath.row];
        UILabel *titleLabel = [[cell.contentView viewWithTag:100] viewWithTag:102];
        UIImageView *iconView = [[cell.contentView viewWithTag:100] viewWithTag:101];

        titleLabel.text = crashType[@"title"];
        iconView.image = [UIImage systemImageNamed:@"exclamationmark.triangle.fill"];

        return cell;

    } else {
        static NSString *fileCellId = @"FileCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:fileCellId];

        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:fileCellId];
            cell.backgroundColor = [UIColor whiteColor];
            cell.layer.cornerRadius = 12;
            cell.layer.masksToBounds = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            UIView *containerView = [[UIView alloc] init];
            containerView.tag = 200;
            containerView.backgroundColor = [UIColor colorWithRed:249/255.0 green:250/255.0 blue:251/255.0 alpha:1.0];
            containerView.layer.cornerRadius = 8;
            containerView.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:containerView];

            UIImageView *iconView = [[UIImageView alloc] init];
            iconView.tag = 201;
            iconView.image = [UIImage systemImageNamed:@"doc.text.fill"];
            iconView.tintColor = [UIColor colorWithRed:239/255.0 green:68/255.0 blue:68/255.0 alpha:1.0];
            iconView.contentMode = UIViewContentModeScaleAspectFit;
            iconView.translatesAutoresizingMaskIntoConstraints = NO;
            [containerView addSubview:iconView];

            UILabel *fileNameLabel = [[UILabel alloc] init];
            fileNameLabel.tag = 202;
            fileNameLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
            fileNameLabel.textColor = [UIColor colorWithRed:31/255.0 green:31/255.0 blue:31/255.0 alpha:1.0];
            fileNameLabel.numberOfLines = 2;
            fileNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
            fileNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [containerView addSubview:fileNameLabel];

            UILabel *detailLabel = [[UILabel alloc] init];
            detailLabel.tag = 203;
            detailLabel.font = [UIFont systemFontOfSize:12];
            detailLabel.textColor = [UIColor colorWithRed:156/255.0 green:163/255.0 blue:175/255.0 alpha:1.0];
            detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [containerView addSubview:detailLabel];

            [NSLayoutConstraint activateConstraints:@[
                [containerView.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:4],
                [containerView.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:16],
                [containerView.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-16],
                [containerView.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-4],

                [iconView.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:12],
                [iconView.centerYAnchor constraintEqualToAnchor:containerView.centerYAnchor],
                [iconView.widthAnchor constraintEqualToConstant:32],
                [iconView.heightAnchor constraintEqualToConstant:32],

                [fileNameLabel.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:10],
                [fileNameLabel.leadingAnchor constraintEqualToAnchor:iconView.trailingAnchor constant:12],
                [fileNameLabel.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-12],

                [detailLabel.topAnchor constraintEqualToAnchor:fileNameLabel.bottomAnchor constant:4],
                [detailLabel.leadingAnchor constraintEqualToAnchor:iconView.trailingAnchor constant:12],
                [detailLabel.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-12],
                [detailLabel.bottomAnchor constraintLessThanOrEqualToAnchor:containerView.bottomAnchor constant:-10]
            ]];
        }

        UIView *containerView = [cell.contentView viewWithTag:200];
        UILabel *fileNameLabel = [containerView viewWithTag:202];
        UILabel *detailLabel = [containerView viewWithTag:203];
        UIImageView *iconView = [containerView viewWithTag:201];

        if (self.crashFiles.count == 0) {
            containerView.hidden = YES;
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            containerView.hidden = NO;
            NSDictionary *fileInfo = self.crashFiles[indexPath.row];
            fileNameLabel.text = fileInfo[@"name"];

            NSNumber *sizeNum = fileInfo[@"size"];
            NSString *sizeStr;
            if ([sizeNum longLongValue] < 1024 * 1024) {
                sizeStr = [NSString stringWithFormat:NSLocalizedString(@"LocKey.CrashReporterFileSizeFormat", @"%.2f KB"), [sizeNum floatValue] / 1024.0];
            } else {
                sizeStr = [NSString stringWithFormat:NSLocalizedString(@"LocKey.CrashReporterFileSizeLargeFormat", @"%.2f MB"), [sizeNum floatValue] / (1024.0 * 1024.0)];
            }

            NSDate *date = fileInfo[@"date"];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *dateStr = [formatter stringFromDate:date];

            detailLabel.text = [NSString stringWithFormat:@"%@ · %@", sizeStr, dateStr];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }

        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor colorWithRed:156/255.0 green:163/255.0 blue:175/255.0 alpha:1.0];
    [headerView addSubview:titleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:32],
        [titleLabel.centerYAnchor constraintEqualToAnchor:headerView.centerYAnchor]
    ]];

    if (section == CrashReporterSectionTrigger) {
        titleLabel.text = [NSLocalizedString(@"LocKey.CrashReporterCrashTriggerTitle", @"TRIGGER CRASH") uppercaseString];
    } else {
        titleLabel.text = [NSLocalizedString(@"LocKey.CrashReporterFileListTitle", @"CRASH FILES") uppercaseString];
    }

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 8;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor clearColor];
    return footerView;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == CrashReporterSectionTrigger) {
        NSDictionary *crashType = self.crashTypes[indexPath.row];
        [self triggerCrashWithType:(CrashType)[crashType[@"type"] integerValue] title:crashType[@"title"]];
    } else {
        if (self.crashFiles.count > 0) {
            NSDictionary *fileInfo = self.crashFiles[indexPath.row];
            [self showFileDetail:fileInfo];
        }
    }
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != CrashReporterSectionFileList || self.crashFiles.count == 0) {
        return nil;
    }

    UITableViewRowAction *shareAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"LocKey.CrashReporterShareAction", @"Share") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSDictionary *fileInfo = self.crashFiles[indexPath.row];
        [self shareFile:fileInfo];
    }];
    shareAction.backgroundColor = [UIColor systemBlueColor];

    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"LocKey.CrashReporterDeleteAction", @"Delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSDictionary *fileInfo = self.crashFiles[indexPath.row];
        [self deleteCrashFile:fileInfo atIndex:indexPath.row];
    }];

    return @[deleteAction, shareAction];
}

#pragma mark - Actions

- (void)triggerCrashWithType:(CrashType)type title:(NSString *)title {
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"LocKey.CrashReporterCrashConfirmMessage", @"Are you sure you want to trigger a crash?\n\n%@"), title];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ConfirmLocKey", @"Confirm") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self performCrashWithType:type];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CancelLocKey", @"Cancel") style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)performCrashWithType:(CrashType)type {
    switch (type) {
        case CrashTypeArrayOutOfBounds: {
            NSArray *array = @[@1];
            id obj = array[100];
            NSLog(@"%@", obj);
            break;
        }
        case CrashTypeUnrecognizedSelector: {
            NSObject *obj = [[NSObject alloc] init];
            [obj performSelector:@selector(nonExistentMethod)];
            break;
        }
        case CrashTypeAssertion: {
            NSAssert(NO, @"Assertion failure");
            break;
        }
        case CrashTypeStackOverflow: {
            [self recursiveCall];
            break;
        }
        case CrashTypeBusError: {
            char *ptr = (char *)0x1;
            *ptr = 'a';
            break;
        }
    }
}

- (void)recursiveCall {
    [self recursiveCall];
}

- (void)showFileDetail:(NSDictionary *)fileInfo {
    NSString *filePath = fileInfo[@"path"];
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];

    if (error) {
        content = NSLocalizedString(@"LocKey.CrashReporterShareFailed", @"Failed to read file");
    }

    UIViewController *detailVC = [[UIViewController alloc] init];
    detailVC.view.backgroundColor = [UIColor whiteColor];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = fileInfo[@"name"];
    titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [detailVC.view addSubview:titleLabel];

    UITextView *textView = [[UITextView alloc] init];
    textView.text = content;
    textView.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    textView.editable = NO;
    textView.backgroundColor = [UIColor colorWithRed:249/255.0 green:250/255.0 blue:251/255.0 alpha:1.0];
    textView.textColor = [UIColor darkTextColor];
    textView.layer.cornerRadius = 12;
    textView.textContainerInset = UIEdgeInsetsMake(12, 12, 12, 12);
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    [detailVC.view addSubview:textView];

    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [shareButton setTitle:NSLocalizedString(@"LocKey.CrashReporterShareAction", @"Share") forState:UIControlStateNormal];
    shareButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    shareButton.backgroundColor = [UIColor colorWithRed:59/255.0 green:130/255.0 blue:246/255.0 alpha:1.0];
    [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    shareButton.layer.cornerRadius = 12;
    shareButton.translatesAutoresizingMaskIntoConstraints = NO;
    [shareButton addTarget:self action:@selector(shareFileFromSheet:) forControlEvents:UIControlEventTouchUpInside];
    objc_setAssociatedObject(shareButton, "fileInfo", fileInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [detailVC.view addSubview:shareButton];

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:detailVC.view.safeAreaLayoutGuide.topAnchor constant:16],
        [titleLabel.leadingAnchor constraintEqualToAnchor:detailVC.view.leadingAnchor constant:16],
        [titleLabel.trailingAnchor constraintEqualToAnchor:detailVC.view.trailingAnchor constant:-16],

        [shareButton.bottomAnchor constraintEqualToAnchor:detailVC.view.safeAreaLayoutGuide.bottomAnchor constant:-16],
        [shareButton.leadingAnchor constraintEqualToAnchor:detailVC.view.leadingAnchor constant:16],
        [shareButton.trailingAnchor constraintEqualToAnchor:detailVC.view.trailingAnchor constant:-16],
        [shareButton.heightAnchor constraintEqualToConstant:48],

        [textView.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:16],
        [textView.leadingAnchor constraintEqualToAnchor:detailVC.view.leadingAnchor constant:16],
        [textView.trailingAnchor constraintEqualToAnchor:detailVC.view.trailingAnchor constant:-16],
        [textView.bottomAnchor constraintEqualToAnchor:shareButton.topAnchor constant:-16]
    ]];

    if (@available(iOS 15.0, *)) {
        detailVC.modalPresentationStyle = UIModalPresentationPageSheet;
        UISheetPresentationController *sheet = (UISheetPresentationController *)detailVC.presentationController;
        sheet.detents = @[[UISheetPresentationControllerDetent largeDetent]];
        sheet.prefersGrabberVisible = YES;
        sheet.preferredCornerRadius = 20;
        [self presentViewController:detailVC animated:YES completion:nil];
    } else {
        detailVC.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:detailVC animated:YES completion:nil];
    }
}

- (void)shareFileFromSheet:(UIButton *)sender {
    NSDictionary *fileInfo = objc_getAssociatedObject(sender, "fileInfo");
    [self dismissViewControllerAnimated:YES completion:^{
        [self shareFile:fileInfo];
    }];
}

- (void)shareFile:(NSDictionary *)fileInfo {
    NSString *filePath = fileInfo[@"path"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];

    activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        if (!completed || activityError) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"LocKey.CrashReporterShareFailed", @"Share Failed") preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OKLocKey", @"OK") style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    };

    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)deleteCrashFile:(NSDictionary *)fileInfo atIndex:(NSInteger)index {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL success = [fileManager removeItemAtPath:fileInfo[@"path"] error:&error];

    if (success) {
        NSMutableArray *mutableFiles = [self.crashFiles mutableCopy];
        [mutableFiles removeObjectAtIndex:index];
        self.crashFiles = mutableFiles;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:CrashReporterSectionFileList] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"LocKey.CrashReporterDeleteFailed", @"Delete Failed") preferredStyle:UIAlertControllerStyleAlert];
        [errorAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OKLocKey", @"OK") style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:errorAlert animated:YES completion:nil];
    }
}

- (void)deleteAllCrashFiles {
    if (self.crashFiles.count == 0) {
        return;
    }

    NSString *message = NSLocalizedString(@"LocKey.CrashReporterDeleteAllConfirmMessage", @"Are you sure you want to delete all crash files?");

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"LocKey.CrashReporterDeleteConfirmTitle", @"Confirm Delete") message:message preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"CancelLocKey", @"Cancel") style:UIAlertActionStyleCancel handler:nil]];

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"LocKey.CrashReporterDeleteAllAction", @"Delete All") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSFileManager *fileManager = [NSFileManager defaultManager];

        for (NSDictionary *fileInfo in self.crashFiles) {
            [fileManager removeItemAtPath:fileInfo[@"path"] error:nil];
        }

        self.crashFiles = @[];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:CrashReporterSectionFileList] withRowAnimation:UITableViewRowAnimationAutomatic];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

@end
