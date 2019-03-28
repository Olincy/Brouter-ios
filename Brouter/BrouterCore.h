//
//  BrouterCore.h
//  Brouter
//
//  Created by lincy on 2018/7/9.
//  Copyright © 2018年 lincy. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 BrouterRoutePath returned after a route registerd successfully.
 */
@interface BrouterRoutePath : NSObject
// origin route template.
@property (readonly) NSString *routeTamplate;

// route regular express pattern after compiled.
@property (readonly) NSString *routePattern;
@end



/**
 BrouterResponse returned after an url parsed.
 */
@interface BrouterResponse : NSObject

// error will be generated if an url not registered or cannot be parsed, otherwise error will be nil.
@property (nonatomic, strong) NSError *error;

// the url queries and url parameters
@property (nonatomic, copy) NSDictionary *params;

// user handler object registered
@property (nonatomic, strong) id routeHandler;
@end


@interface BrouterCore : NSObject


/**
 Map a route template to a handler object.

 @param routeTemplate : Route template, like scheme://foo/bar , scheme://foo/{bar:[0-9]+}
 注意：注册的route需要符合 RFC 3986 标准，尽管注册的方法检查不严格，但是[parseUrl:]方法用NSURLComponents检查合法性，不能生成NSURLComponents对象的url视为费非法的url。
    url匹配优先级：不带url参数>带url参数（如果两个注册的带参数url范围重合，会优先匹配最近注册的url）
 @param handler : A object, which will return back when an url parsing success.
 
 @return BrouterRoutePath object.return nil if register failed.
 注册失败将返回nil。
 */
- (BrouterRoutePath *)mapRouteTamplate:(NSString *)routeTemplate toHandler:(id)handler;


/**
 Parse an url string.

 @param urlStr : url string
 @return BrouterResponse object, BrouterResponse.error will be generated if an url not registered or cannot be parsed, otherwise error will be nil. 如果url解析失败或者url没有注册，会返回BrouterResponse.error，否则BrouterResponse.error 是nil的。
 */
- (BrouterResponse *)parseUrl:(NSString *)urlStr;

@end
