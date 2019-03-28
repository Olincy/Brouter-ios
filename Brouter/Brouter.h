//
//  Brouter.h
//  CYRouter
//
//  Created by candy on 2019/3/20.
//  Copyright © 2019 lincy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BrouterCore.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - BrouterContext
@interface BrouterContext : NSObject
/// route template registered
@property (nonatomic, copy) NSString *routeTemplate;
/// url string trying to open
@property (nonatomic, copy) NSString *urlString;
/// url parameters and queries
@property (nonatomic, strong) NSDictionary *params;
@end

#pragma mark - BrouterHandlerBlk
typedef void (^BrouterHandlerBlk)(BrouterContext *context);

#pragma mark - Brouter
@interface Brouter : NSObject

/**
 Register a route

 @param routeTamplate : router template like scheme://foo/bar , scheme://foo/{bar:[0-9]+}
 注意：注册的route需要符合 RFC 3986 标准，尽管注册的方法检查不严格，但是[parseUrl:]方法用NSURLComponents检查合法性，不能生成NSURLComponents对象的url视为费非法的url。
 url匹配优先级：不带url参数>带url参数（如果两个注册的带参数url范围重合，会优先匹配最近注册的url）
 @param handler : Handler block
 @return YES if register success, NO if not
 */
+ (BOOL)route:(NSString *)routeTamplate toHandler:(BrouterHandlerBlk)handler;


/**
 Check if an url can be opened

 @param urlStr : url string try to open
 @return YES if url string can be opened, NO if not
 */
+ (BOOL)canOpenUrl:(NSString *)urlStr;


/**
 Try to open an url string

 @return YES if open success, NO if not
 */
+ (BOOL)openUrl:urlStr;
@end

NS_ASSUME_NONNULL_END
