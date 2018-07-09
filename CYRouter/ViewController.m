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

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *names2Vcs;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self tableView];
    self.names2Vcs = @[
                        @{
                            @"name":@"routes test",
                            @"vc":[TestRoutesController class]
                         },
                        @{
                            @"name":@"register test",
                             @"vc":[RegisterRoutesController class]
                        }
                        ];
}

#pragma mark - TableView Datasource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.names2Vcs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSString *title = [[self.names2Vcs objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.textLabel.text = title;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Class vcClass = [[self.names2Vcs objectAtIndex:indexPath.row] objectForKey:@"vc"];
    [self.navigationController pushViewController:([vcClass new]) animated:YES];
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
