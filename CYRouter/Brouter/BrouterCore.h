//
//  BrouterCore.h
//  Brouter
//
//  Created by lincy on 2018/7/9.
//  Copyright © 2018年 lincy. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef void (^BrouterHandlerBlk)(NSDictionary *params);


@interface BrouterRouteTamplate : NSObject
@property (nonatomic, copy) NSString *scheme;
@property (nonatomic, copy) NSString *routeKey;
@end

@interface BrouterHandler : NSObject
@property (nonatomic, copy) BrouterHandlerBlk handlerBlk;
@end

@interface BrouterRoutePath : NSObject
@property (nonatomic, strong) NSRegularExpression *pathRegex; // path regex expression
@property (nonatomic, strong) BrouterRouteTamplate *routeTamplate;
@property (nonatomic, strong) BrouterHandler *handler;
@end


@interface BrouterResponse : NSObject
@property (nonatomic, strong) NSError *error;
@property (nonatomic, copy) NSDictionary *params;
@property (nonatomic, strong) BrouterHandler *handler;
@end


@interface BrouterCore : NSObject


- (BrouterRoutePath *)route:(NSString *)routeTpl toHandler:(BrouterHandlerBlk)handler;
- (BrouterResponse *)parse:(NSString *)urlStr;

@end
