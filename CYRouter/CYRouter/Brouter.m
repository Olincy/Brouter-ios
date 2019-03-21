//
//  Brouter.m
//  CYRouter
//
//  Created by candy on 2019/3/20.
//  Copyright © 2019 lincy. All rights reserved.
//

#import "Brouter.h"

@implementation Brouter

- (BrouterCore *)routerCore {
    if (_routerCore == nil) {
        _routerCore = [BrouterCore new];
    }
    return _routerCore;
}

#pragma mark - Class
static Brouter *_instance;
+ (instancetype)defaultRouter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
    });
    return _instance;
}


+ (BOOL)route:(NSString *)routeTpl toHandler:(BrouterHandler)handler {
    return NO;
}


+ (BOOL)inScheme:(NSString *)scheme path2handlers:(NSArray<BroutePath2Handler *> *)path2handlers {
    return NO;
}


+ (BOOL)route:(NSString *)routeTpl toVC:(NSString *)vcName {
    return NO;
}

+ (BOOL)canOpenUrl:(NSString *)urlStr {
    return NO;
}

+ (BOOL)openUrl:urlStr {
    return NO;
}


@end
