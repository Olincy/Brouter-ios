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
@property (nonatomic, copy) NSString *viewControllerName;
@end

@implementation BrouterHandler
@end

@implementation BrouterContext
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
    BrouterRoutePath *path = [[[self defaultRouter] routerCore] mapRouteTamplate:routeTpl toHandler:handlerObj];
    
    return path != nil;
}

+ (BOOL)route:(NSString *)routeTpl toViewController:(NSString *)vcName {
    BrouterHandler *handlerObj = [BrouterHandler new];
    handlerObj.viewControllerName = vcName;
    BrouterRoutePath *path = [[[self defaultRouter] routerCore] mapRouteTamplate:routeTpl toHandler:handlerObj];
    
    return path != nil;
}


+ (BOOL)canOpenUrl:(NSString *)urlStr {
    BrouterResponse *response = [[[self defaultRouter] routerCore] parseUrl: urlStr];
    return response.error != nil;
}

+ (BOOL)openUrl:urlStr {
    BrouterResponse *response = [[[self defaultRouter] routerCore] parseUrl: urlStr];
    if (response.error) {
        return NO;
    }
    BrouterHandler *handlerObj = response.routeHandler;
    if ( handlerObj.handlerBlk ) {
        BrouterContext *ctx = [BrouterContext new];
        
        ctx.urlString = urlStr;
        ctx.params = response.params;
        handlerObj.handlerBlk(ctx);
    }
    return YES;
}



@end


@implementation UIViewController (Brouter)

- (Class)viewControllerClassWithUrl:(NSString *)urlStr {
    BrouterResponse *response = [[[Brouter defaultRouter] routerCore] parseUrl: urlStr];
    if (response.error) {
        return nil;
    }
    BrouterHandler *handlerObj = response.routeHandler;
    Class vcClass = NSClassFromString(handlerObj.viewControllerName);
    if (!vcClass || ![vcClass isSubclassOfClass:[UIViewController class]]) {
        return nil;
    }
    return vcClass;
}


- (BOOL)pushUrl:(NSString *)urlStr {
    Class vcClass = [self viewControllerClassWithUrl:urlStr];
    if (!vcClass) {
        return NO;
    }
    UIViewController *vc = [vcClass new];
    [self.navigationController pushViewController:vc animated:YES];
    return YES;
}

- (BOOL)presentUrl:(NSString *)urlStr {
    Class vcClass = [self viewControllerClassWithUrl:urlStr];
    if (!vcClass) {
        return NO;
    }
    UIViewController *vc = [vcClass new];
    [self presentViewController:vc animated:YES completion:nil];
    return YES;
}

@end
