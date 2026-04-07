//
//  AISummaryDemoController.m
//  AIBudsSDK-Demo
//
//  Created by pcjbird on 2026-04-05.
//  Copyright © 2026 Zero Status. All rights reserved.
//

#import "AISummaryDemoController.h"

@interface AISummaryDemoController ()

@property (nonatomic, strong) UITextView *inputTextView;
@property (nonatomic, strong) UIButton *summaryButton;
@property (nonatomic, strong) UITextView *resultTextView;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UILabel *inputTitleLabel;
@property (nonatomic, strong) UILabel *resultTitleLabel;

@end

@implementation AISummaryDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"LocKey.AISummaryDemoTitle", comment:@"AI Summary");
    
    // Input Title Label
    self.inputTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.inputTitleLabel.text = NSLocalizedString(@"LocKey.TextToSummarizeTitle", comment:@"Text to be summarized label");
    self.inputTitleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.inputTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.inputTitleLabel];
    
    // Input TextView
    self.inputTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.inputTextView.text = NSLocalizedString(@"LocKey.AISummaryDemoText", comment:@"Default summary input text");
    self.inputTextView.font = [UIFont systemFontOfSize:16];
    self.inputTextView.layer.borderWidth = 1.0;
    self.inputTextView.layer.borderColor = [UIColor systemGrayColor].CGColor;
    self.inputTextView.layer.cornerRadius = 8.0;
    self.inputTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.inputTextView];
    
    // Summary Button
    self.summaryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.summaryButton setTitle:NSLocalizedString(@"LocKey.GenerateSummaryButtonTitle", comment:@"Generate summary button") forState:UIControlStateNormal];
    self.summaryButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    [self.summaryButton setBackgroundColor:[UIColor systemBlueColor]];
    [self.summaryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.summaryButton.layer.cornerRadius = 25.0;
    self.summaryButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.summaryButton addTarget:self action:@selector(generateSummary) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.summaryButton];
    
    // Error Label
    self.errorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.errorLabel.text = @"";
    self.errorLabel.textColor = [UIColor systemRedColor];
    self.errorLabel.font = [UIFont systemFontOfSize:14];
    self.errorLabel.textAlignment = NSTextAlignmentCenter;
    self.errorLabel.numberOfLines = 0;
    self.errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.errorLabel];
    
    // Result Title Label
    self.resultTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.resultTitleLabel.text = NSLocalizedString(@"LocKey.SummaryResultTitle", comment:@"Summary result label");
    self.resultTitleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.resultTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.resultTitleLabel];
    
    // Result TextView
    self.resultTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.resultTextView.text = NSLocalizedString(@"LocKey.SummaryResultWillAppearHereTips", comment:@"Result placeholder");
    self.resultTextView.font = [UIFont systemFontOfSize:16];
    self.resultTextView.editable = NO;
    self.resultTextView.layer.borderWidth = 1.0;
    self.resultTextView.layer.borderColor = [UIColor systemGrayColor].CGColor;
    self.resultTextView.layer.cornerRadius = 8.0;
    self.resultTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.resultTextView];
    
    // Layout Constraints
    [NSLayoutConstraint activateConstraints:@[
        // Input Title Label
        [self.inputTitleLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.inputTitleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        
        // Input TextView
        [self.inputTextView.topAnchor constraintEqualToAnchor:self.inputTitleLabel.bottomAnchor constant:10],
        [self.inputTextView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.inputTextView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.inputTextView.heightAnchor constraintEqualToConstant:200],
        
        // Summary Button
        [self.summaryButton.topAnchor constraintEqualToAnchor:self.inputTextView.bottomAnchor constant:30],
        [self.summaryButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.summaryButton.widthAnchor constraintEqualToConstant:200],
        [self.summaryButton.heightAnchor constraintEqualToConstant:50],
        
        // Error Label
        [self.errorLabel.topAnchor constraintEqualToAnchor:self.summaryButton.bottomAnchor constant:20],
        [self.errorLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.errorLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        // Result Title Label
        [self.resultTitleLabel.topAnchor constraintEqualToAnchor:self.errorLabel.bottomAnchor constant:20],
        [self.resultTitleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        
        // Result TextView
        [self.resultTextView.topAnchor constraintEqualToAnchor:self.resultTitleLabel.bottomAnchor constant:10],
        [self.resultTextView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.resultTextView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.resultTextView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
    ]];
}

- (void)generateSummary {
    NSString *text = self.inputTextView.text;
    if (!text || text.length == 0) {
        self.errorLabel.text = NSLocalizedString(@"LocKey.PleaseEnterTextToSummarizeTips", comment:@"Error message");
        return;
    }
    
    self.errorLabel.text = @"";
    self.resultTextView.text = NSLocalizedString(@"LocKey.Processing", comment:@"Processing message");
    
    // Generate summary
    [AIBudsAISDK summaryWithText:text streamResultHandler:^(BOOL isFinal, NSString * _Nullable transcript, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{ 
            if (error) {
                self.errorLabel.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
                self.resultTextView.text = NSLocalizedString(@"LocKey.SummaryFailed", comment:@"Failed message");
            } else if (transcript) {
                self.resultTextView.text = transcript;
            }
        });
    }];
}

@end
