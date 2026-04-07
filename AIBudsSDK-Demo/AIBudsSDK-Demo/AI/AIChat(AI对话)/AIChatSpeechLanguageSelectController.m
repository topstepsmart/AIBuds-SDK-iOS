//
//  AIChatSpeechLanguageSelectController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-03-24.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "AIChatSpeechLanguageSelectController.h"
#import "AILanguageUtils.h"

@interface AIChatSpeechLanguageSelectController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray<NSString *> *supportedLanguages;
@property (nonatomic, copy) NSString *defaultLanguage;
@property (nonatomic, copy) void (^completion)(NSString *);
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation AIChatSpeechLanguageSelectController

- (instancetype)initWithSupportedLanguages:(NSArray<NSString *> *)supportedLanguages defaultLanguage:(NSString *)defaultLanguage completion:(void (^)(NSString *))completion {
    self = [super init];
    if (self) {
        _supportedLanguages = supportedLanguages;
        _defaultLanguage = defaultLanguage;
        _completion = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置标题
    self.title = NSLocalizedString(@"LocKey.SelectLanguage", nil);
    
    // 初始化 UI
    [self setupUI];
}

- (void)setupUI {
    // 创建表格视图
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.supportedLanguages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"LanguageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSString *languageCode = self.supportedLanguages[indexPath.row];
    // 解析语言代码，格式为 ISO 639-1 + ISO 3166-1，例如 "zh-CN"
    NSArray *components = [languageCode componentsSeparatedByString:@"-"];
    NSString *iso6391 = components.firstObject;
    NSString *iso3166 = components.count > 1 ? components[1] : nil;
    
    // 获取本地化显示名称
    NSString *displayName = [AILanguageUtils localizedDisplayNameForLanguageCode:languageCode iso6391:iso6391 iso3166:iso3166];
    
    cell.textLabel.text = displayName;
    cell.detailTextLabel.text = languageCode;
    
    // 标记默认选中的语言
    if ([languageCode isEqualToString:self.defaultLanguage]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *selectedLanguage = self.supportedLanguages[indexPath.row];
    
    // 更新选中状态
    for (UITableViewCell *cell in tableView.visibleCells) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    // 回调选中的语言
    if (self.completion) {
        self.completion(selectedLanguage);
    }
    
    // 返回上一页
    [self.navigationController popViewControllerAnimated:YES];
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
