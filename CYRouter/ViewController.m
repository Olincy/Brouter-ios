//
//  ViewController.m
//  CYRouter
//
//  Created by lincy on 2018/7/9.
//  Copyright © 2018年 lincy. All rights reserved.
//

#import "ViewController.h"
#import "Common.h"
#import "RegisterRoutesController.h"
#import "TestRoutesController.h"
#import "BrouterCore.h"


@interface ViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *names2Vcs;
@property (nonatomic, strong) NSArray *goodUrls;
@property (nonatomic, strong) NSArray *badUrls;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self tableView];
    
//    [[BrouterCore share] inScheme:@"brouter" path2handlers:@[
//        [BrouteMaker path:@"/path/to/1" toHandler:^(NSDictionary *params) {
//            NSLog(@"jump to 1");
//        }],
//        [BrouteMaker path:@"/path/to/2" toHandler:^(NSDictionary *params) {
//            NSLog(@"jump to 2");
//        }],
//        [BrouteMaker path:@"/path/to/3" toHandler:^(NSDictionary *params) {
//            NSLog(@"jump to 3");
//        }],
//        [BrouteMaker path:@"/path/to1/{id:\\d+}" toHandler:^(NSDictionary *params) {
//            NSLog(@"jump to 4");
//        }],
//
////        [BrouteMaker path:@"/path/to1/{id:[0-9]+}/{id}" toHandler:^(NSDictionary *params) {
////        // should get error: duplicate param name
////        }],
//        [BrouteMaker path:@"/path/to2/{pv1}" toHandler:^(NSDictionary *params) {
//            NSLog(@"jump to 5");
//        }],
//        [BrouteMaker path:@"brouter://{id:[0-9]+}" toHandler:^(NSDictionary *params) {
//            NSLog(@"jump to 6");
//        }],
//
////        [BrouteMaker path:@"brouter://" toHandler:^(NSDictionary *params) {
////            NSLog(@"jump to 6");
////        }],
//        [BrouteMaker path:@"brout://{id:[0-9]+}" toHandler:^(NSDictionary *params) {
//            NSLog(@"jump to 6");
//        }],
//    ]];
    
    self.goodUrls =@[
                     @"brouter://path/to/1",
                     @"brouter://path/to1/250",
                     @"path/to/3",
                     @"/path/to/3",
                     @"path/to2/hello",
                     @"brouter://301",
                     @"http://223.255.255.254"];
    
    self.badUrls =@[
                    @"http://www.sample.com/article/{postId}",
                        @"http://.",
                       ];
    
    BrouterCore *brouter = [BrouterCore new];
    BrouterRoutePath *path = [brouter route:nil toHandler:^(NSDictionary *params) {
    }];
    
    
    path = [brouter route:@"/foo" toHandler:nil];
    
    
    path = [brouter route:@"/foo" toHandler:^(NSDictionary *params) {
    }];
    
    
    path = [brouter route:@"broute://foo?p=20" toHandler:^(NSDictionary *params) {
    }];
    path = [brouter route:@"broute://foo/{id}" toHandler:^(NSDictionary *params) {
    }];
    path = [brouter route:@"broute://foo/{bar:[0-9]+}" toHandler:^(NSDictionary *params) {
    }];
    
    
    
}

#pragma mark - TableView Datasource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        return self.goodUrls.count;
    } else {
        return self.badUrls.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSString *title = nil;
    if (indexPath.section==0) {
        title = self.goodUrls[indexPath.row];
    } else {
        title = self.badUrls[indexPath.row];
    }
    
    cell.textLabel.text = title;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BrouterCore *router = [BrouterCore new];
    NSString *url = nil;
    if (indexPath.section == 0) {
        url = self.goodUrls[indexPath.row];
    } else {
        url = self.badUrls[indexPath.row];
    }
    
//    [router inScheme:@"brouter" addPath:url toHandler:^(NSDictionary *params) {
//    }];
//    [[BrouterCore share]push:url];
    
}


- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenW, self.view.bounds.size.height)];
        [self.view addSubview:_tableView];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

@end
