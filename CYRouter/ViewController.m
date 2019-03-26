//
//  ViewController.m
//  CYRouter
//
//  Created by lincy on 2018/7/9.
//  Copyright © 2018年 lincy. All rights reserved.
//

#import "ViewController.h"
#import "Brouter/Brouter.h"


@interface ViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *names2Vcs;
@property (nonatomic, strong) NSArray *regUrls;
@property (nonatomic, strong) NSArray *openUrls;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self tableView];
    
    __weak typeof(self) wself = self;
    BrouterHandlerBlk handler = ^(BrouterContext *ctx) {
        NSMutableString *queries = [NSMutableString stringWithString:@"queries:"];
        [ctx.params enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [queries appendFormat:@"\n%@=%@",key,obj];
        }];
        
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"open url: %@",ctx.urlString] message:queries preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [wself presentViewController:alert animated:YES completion:nil];
        
    };
    
    self.regUrls =@[
                     @"brouter://foo/bar",
                     @"broute://foo/{id}",
                     @"broute://foo/{bar:[0-9]+}",
                     @"broute://{foo:[0-9]+}",
                     @"abc://foo/bar{bar}",
                     @"brouter://301",
                     @"http://223.255.255.254",
                     @"http://www.sample.com:8888",
                     @"abc://{foo:[0-9]+}/{bar}"];
    
    self.openUrls =@[
                     @"brouter://foo/bar?p=hello",
                     @"broute://foo/999?q=000",
                     @"broute://foo/12fuasdf",
                     @"broute://12345",
                     @"abc://foo/barsubfix",
                     @"brouter://301",
                     @"http://223.255.255.254",
                     @"http://www.sample.com:8888",
                     @"abc://123/hello",
                     @"xxx://foo/bar",
                       ];
    
    
    for (NSString *url in self.regUrls) {
        [Brouter route:url toHandler:handler];
    }
   
}

#pragma mark - TableView Datasource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.openUrls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSString *title = self.openUrls[indexPath.row];
    
    cell.textLabel.text = title;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *url = self.openUrls[indexPath.row];
    if ([Brouter openUrl:url]) {
        NSLog(@"open:%@",url);
    } else {
        NSLog(@"cannot open:%@",url);
    }
}


- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.view.bounds.size.height)];
        [self.view addSubview:_tableView];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

@end
