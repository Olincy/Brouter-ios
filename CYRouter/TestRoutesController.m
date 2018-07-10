//
//  TestRoutesController.m
//  CYRouter
//
//  Created by lincy on 2018/7/9.
//  Copyright © 2018年 lincy. All rights reserved.
//

#import "TestRoutesController.h"
#import "CYRouter.h"

@interface TestRoutesController () <UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation TestRoutesController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Test routes";
    [self webView];
    
    NSURL *baseURL = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"html"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
    [self.webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlStr = request.URL.absoluteString;
    if ([[CYRouter share]open:urlStr]) {
        return NO;
    }
    return YES;
}

- (UIWebView *)webView {
    if (_webView == nil) {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.delegate = self;
     
        _webView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_webView];
    }
    return _webView;
}

@end
