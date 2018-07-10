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
@property (nonatomic, strong) NSString *hostName;
@property (nonatomic, strong) NSArray<NSString *> *hostAliases;
+ (instancetype)share;
- (void)addRoute:(NSString *)route paramRegexs:(NSDictionary *)paramRegexs callback:(CYRouterCallback)callback;
- (BOOL)open:(NSString *)url;
@end
