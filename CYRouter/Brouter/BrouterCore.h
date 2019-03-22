//
//  BrouterCore.h
//  Brouter
//
//  Created by lincy on 2018/7/9.
//  Copyright © 2018年 lincy. All rights reserved.
//

#import <Foundation/Foundation.h>


#define BROUTER_DEFAULT_SCHEME        (@"broute://")
#define BROUTER_DEFAULT_HOST        (@"default.com")

typedef void (^BrouterHandler)(NSDictionary *params);


@interface BroutePath : NSObject
@property (nonatomic, copy) NSString *scheme;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *path; // path string
@property (nonatomic, strong) NSRegularExpression *pathRegex; // path regex expression
@property (nonatomic, copy) BrouterHandler handler;
@end


// decoded url result or resource
@interface BrouterRes : NSObject
@property (nonatomic, copy) NSDictionary *params;
@property (nonatomic, strong) BroutePath *path; //matched registered path
@end

@interface BrouteScheme : NSObject
@property (nonatomic, copy) NSString *scheme;
@end


@interface BrouterCore : NSObject

// www.example.com OR {subdomain:[a-z]+}.example.com
@property (nonatomic, copy) NSString *baseUrl; // like http://www.example.com OR your_scheme://your_host_name
@property (nonatomic, assign) BOOL strictSlash; // "/"是否严格
@property (nonatomic, strong) NSMutableArray<BrouteScheme *> *schemes;



// /post/create
// /posts/{key:[a-zA-Z]+}
// /posts/{category}/
// /posts/{category}/{id:[0-9]+}


- (BroutePath *)route:(NSString *)routeTpl toHandler:(BrouterHandler)handler;
- (BOOL)push:(NSString *)url;
@end
