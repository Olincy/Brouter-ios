//
//  BrouterCore.h
//  Brouter
//
//  Created by lincy on 2018/7/9.
//  Copyright © 2018年 lincy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BrouterRouteTamplate : NSObject
@property (nonatomic, copy) NSString *scheme;
@property (nonatomic, copy) NSString *routeKey;
@end

@interface BrouterRoutePath : NSObject
@property (nonatomic, strong) NSRegularExpression *pathRegex; // path regex expression
@property (nonatomic, copy) NSString *routeTamplate;
@property (nonatomic, strong) id routeHandler;
@end


@interface BrouterResponse : NSObject
@property (nonatomic, strong) NSError *error;
@property (nonatomic, copy) NSDictionary *params;
@property (nonatomic, strong) id routeHandler;
@end


@interface BrouterCore : NSObject


- (BrouterRoutePath *)route:(NSString *)routeTpl toHandler:(id)handler;
- (BrouterResponse *)parse:(NSString *)urlStr;

@end
