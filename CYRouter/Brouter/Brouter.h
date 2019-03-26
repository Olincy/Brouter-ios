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

#pragma mark - BrouterContext
@interface BrouterContext : NSObject
@property (nonatomic, copy) NSString *routeTemplate;
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, strong) NSDictionary *params;
@end

#pragma mark - BrouterHandlerBlk
typedef void (^BrouterHandlerBlk)(BrouterContext *context);

#pragma mark - Brouter
@interface Brouter : NSObject
@property (nonatomic, strong) BrouterCore *routerCore;
+ (instancetype)defaultRouter;
+ (BOOL)route:(NSString *)routeTpl toHandler:(BrouterHandlerBlk)handler;
+ (BOOL)canOpenUrl:(NSString *)urlStr;
+ (BOOL)openUrl:urlStr;
@end

NS_ASSUME_NONNULL_END
