//
//  HomeTableViewController.m
//  Brouter-iosDemo
//
//  Created by candy on 2019/3/27.
//  Copyright © 2019 Brouter. All rights reserved.
//

#import "HomeTableViewController.h"
#import "Brouter.h"

@interface HandlerType : NSObject
@property(class, readonly) NSString *Block;
@property(class, readonly) NSString *Push2VC;
@property(class, readonly) NSString *Present2VC;
@end
@implementation HandlerType
+ (NSString *)Block {return @"Block";}
+ (NSString *)Push2VC {return @"Push2VC";}
+ (NSString *)Present2VC {return @"Present2VC";}
@end



@interface HomeTableViewController ()
@property (nonatomic, strong) NSArray *regUrls;
@end

@implementation HomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Brouter Demo";
    self.regUrls =@[
                    @{@"reg":@{@"template":@"brouter://foo/bar",
                               @"type":HandlerType.Block
                               },
                      @"test":@[
                              @{@"testUrl":@"brouter://foo/bar?p=hello",
                                @"testDes":@"url+query",
                                },
                              ]
                      },
                    @{@"reg":@{@"template":@"test://foo/{id}",
                               @"type":HandlerType.Block
                               },
                      @"test":@[]
                      },
                    @{@"reg":@{@"template":@"test://foo/{bar:[0-9]+}",
                               @"type":HandlerType.Block
                               },
                      @"test":@[
                              @{@"testUrl":@"test://foo/999?q=000",
                                @"testDes":@"带参url+query",
                                },

                              @{@"testUrl":@"test://foo/bar?p=hello",
                                @"testDes":@"绝对url+query",
                                @"testRes":@"弹出：参数p=hello"
                                },
                              ]
                      },
                    @{@"reg":@{@"template":@"abc://foo/bar{bar}",
                               @"type":HandlerType.Block
                      },
                      @"test":@[
                              @{@"testUrl":@"abc://foo/barsubfix",
                                @"testDes":@"带参url+query",
                                @"testRes":@"弹出：参数bar=subfix"
                                },
                              ]
                      },
                   

                    ];
    
    [self registrRoutes];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"UITableViewHeaderFooterView"];
}

- (void)registrRoutes {
    for (NSDictionary *regItem in self.regUrls) {
        NSDictionary *regTemplate = regItem[@"reg"];
        if ([regTemplate[@"type"]isEqualToString:HandlerType.Block]) {
            __weak typeof(self) wself = self;
            [Brouter route:regTemplate[@"template"] toHandler:^(BrouterContext * _Nonnull context) {
                NSMutableString *queries = [NSMutableString stringWithString:@"queries:"];
                [context.params enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                    [queries appendFormat:@"\n%@=%@",key,obj];
                }];
                
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"open url: %@",context.urlString] message:queries preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                [wself presentViewController:alert animated:YES completion:nil];
            }];
        } else if ([regTemplate[@"type"]isEqualToString:HandlerType.Push2VC]) {
            // TODO
        } else {
            // TODO
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.regUrls.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *testUrlGroup = [self.regUrls objectAtIndex:section];
    NSArray *testUlrs = [testUrlGroup objectForKey:@"test"];
    return testUlrs.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    NSDictionary *testUrlGroup = [self.regUrls objectAtIndex:indexPath.section];
    NSArray *testUlrs = [testUrlGroup objectForKey:@"test"];
    NSDictionary *testUrl = [testUlrs objectAtIndex:indexPath.row];
    cell.textLabel.text = testUrl[@"testUrl"];
    cell.detailTextLabel.text = testUrl[@"testUrl"];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"UITableViewHeaderFooterView"];
    NSDictionary *testUrlGroup = [self.regUrls objectAtIndex:section];
    NSDictionary *regTemplate = testUrlGroup[@"reg"];
    header.textLabel.text = [NSString stringWithFormat:@"注册：%@", regTemplate[@"template"]];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *testUrlGroup = [self.regUrls objectAtIndex:indexPath.section];
    NSArray *testUlrs = [testUrlGroup objectForKey:@"test"];
    NSDictionary *testUrl = [testUlrs objectAtIndex:indexPath.row];
    
    [Brouter openUrl:testUrl[@"testUrl"]];
}

@end
