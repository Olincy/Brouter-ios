//
//  Brouter.h
//  CYRouter
//
//  Created by candy on 2019/3/20.
//  Copyright © 2019 lincy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BrouterCore.h"

NS_ASSUME_NONNULL_BEGIN

@interface Brouter : NSObject
@property (nonatomic, strong) BrouterCore *routerCore;
+ (instancetype)defaultRouter;


+ (BOOL)route:(NSString *)routeTpl toHandler:(BrouterHandler)handler;
+ (BOOL)route:(NSString *)routeTpl toVC:(NSString *)vcName;
+ (BOOL)canOpenUrl:(NSString *)urlStr;
+ (BOOL)openUrl:urlStr;
@end

NS_ASSUME_NONNULL_END
