//
//  Brouter.m
//  CYRouter
//
//  Created by candy on 2019/3/20.
//  Copyright © 2019 lincy. All rights reserved.
//

#import "Brouter.h"

@interface BrouterHandler : NSObject
@property (nonatomic, copy) BrouterHandlerBlk handlerBlk;
@end

@implementation BrouterHandler
@end

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


+ (BOOL)route:(NSString *)routeTpl toHandler:(BrouterHandlerBlk)handler {
    BrouterHandler *handlerObj = [BrouterHandler new];
    handlerObj.handlerBlk = handler;
    BrouterRoutePath *path = [[[self defaultRouter] routerCore] route:routeTpl toHandler:handlerObj];
    
    return path != nil;
}


+ (BOOL)canOpenUrl:(NSString *)urlStr {
    BrouterResponse *response = [[[self defaultRouter] routerCore] parse: urlStr];
    return response.error != nil;
}

+ (BOOL)openUrl:urlStr {
    BrouterResponse *response = [[[self defaultRouter] routerCore] parse: urlStr];
    if (response.error) {
        return NO;
    }
    BrouterHandler *handlerObj = response.routeHandler;
    if ( handlerObj.handlerBlk ) {
        handlerObj.handlerBlk(response.params);
    }
    return YES;
}


@end
