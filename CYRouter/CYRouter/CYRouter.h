//
//  CYRouter.h
//  CYRouter
//
//  Created by lincy on 2018/7/9.
//  Copyright © 2018年 lincy. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (Safe)
- (id)safeObjectAtIndex:(NSUInteger)index;
@end

typedef void (^CYRouterCallback)(NSDictionary *params);
@interface TCRouteParser : NSObject
@property (nonatomic, strong) NSString *path;
@property (nonatomic, copy) CYRouterCallback callback;
@property (nonatomic, copy) NSDictionary *params;
@end

@interface TCRouteRegister : NSObject
@property (nonatomic, strong) NSString *path;
@property (nonatomic, copy) CYRouterCallback callback;
@end



@interface CYRouter : NSObject

+ (instancetype)share;
+ (void)addRoute:(NSString *)route paramRegexs:(NSDictionary *)paramRegexs callback:(CYRouterCallback)callback;
+ (BOOL)open:(NSString *)url;
+ (BOOL)open:(NSString *)url params:(NSDictionary *)params;

- (void)addRoute:(NSString *)route paramRegexs:(NSDictionary *)paramRegexs callback:(CYRouterCallback)callback;

@end
