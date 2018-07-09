//
//  CYRouter.m
//  CYRouter
//
//  Created by lincy on 2018/7/9.
//  Copyright © 2018年 lincy. All rights reserved.
//

#import "CYRouter.h"

@implementation NSArray (Safe)
- (id)safeObjectAtIndex:(NSUInteger)index
{
    if (index < self.count) {
        return [self objectAtIndex:index];
    }
    return nil;
}
@end

@implementation TCRouteRegister
- (instancetype)initWithPath:(NSString *)path callback:(CYRouterCallback)callback {
    if (self = [super init]) {
        self.path = path;
        self.callback = callback;
    }
    return self;
}
@end

@implementation TCRouteParser
- (instancetype)initWithPath:(NSString *)path callback:(CYRouterCallback)callback params:(NSDictionary *)params {
    if (self = [super init]) {
        self.path = path;
        self.callback = callback;
        self.params = params;
    }
    return self;
}
@end



@interface CYRouter ()
@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSArray<NSString *> *aliases;
@property (nonatomic, strong) NSMutableDictionary <NSString*,NSMutableDictionary*> *schemes;
@end
@implementation CYRouter

static CYRouter *instance = nil;

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}


- (void)addRoute:(NSString *)route paramRegexs:(NSDictionary *)paramRegexs callback:(CYRouterCallback)callback {
    NSURL *url = [NSURL URLWithString:route];
    NSString *scheme = [url scheme];
    NSString *path = route;
    if (!scheme) {
        if (![route hasPrefix:@"/"]) {
            path = [NSString stringWithFormat:@"/%@",route];
        }
        path = [self getPathFromRoute:path];
        scheme = @"http";
    } else {
        path = [NSString stringWithFormat:@"/%@",[route substringFromIndex:scheme.length+3]];
        if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
            if (![self containHost:[url host]]) {
                NSLog(@"不能注册外部url");return;
            }
            path = [self getPathFromRoute:path];
            scheme = @"http";
        }
    }
    [self addRoute:path inScheme:scheme paramRegexs:paramRegexs callback:callback];
}

- (void)addRoute:(NSString *)route inScheme:(NSString *)scheme paramRegexs:(NSDictionary *)paramRegexs callback:(CYRouterCallback)callback{
    if (!route || !callback) { NSLog(@"不能为空");return;}
    if (!scheme) {scheme = @"http";}
    if ([scheme hasSuffix:@"://"]) {scheme = [scheme substringToIndex:scheme.length-3];}
    if ([scheme isEqualToString:@"https"]) {scheme = @"http";}
    if (![route hasPrefix:@"/"]) {route = [NSString stringWithFormat:@"/%@",route];}
    
    NSString *stringByDeletingLastPathComponent =route.stringByDeletingLastPathComponent;
    if ([[stringByDeletingLastPathComponent substringFromIndex:stringByDeletingLastPathComponent.length-1]isEqualToString:@"/"]) {
        route = [NSString stringWithFormat:@"%@%@",stringByDeletingLastPathComponent,route.lastPathComponent];
    } else {
        route = [NSString stringWithFormat:@"%@/%@",stringByDeletingLastPathComponent,route.lastPathComponent];
    }
    
    NSString *routeKey = route;
    if ([route rangeOfString:@"/:"].location != NSNotFound) { //有参数
        NSArray<NSString *> *components = [route componentsSeparatedByString:@"/"];
        for (NSString *component in components) {
            if (![component hasPrefix:@":"]) {
                continue;
            }
            if (component.length < 2) { // 只有“：”， 没有参数名
                NSLog(@"url参数格式不对");
                return;
            }
            NSString *paramName = [component substringFromIndex:1];
            NSString *regex = @"(\\d+)";
            if (paramRegexs && paramRegexs[paramName]) {
                regex = paramRegexs[paramName];
            }
            routeKey = [route stringByReplacingOccurrencesOfString:component withString:regex];
        }
    }
    
    NSMutableDictionary *urlMap = self.schemes[scheme];
    if (urlMap) {
        if (urlMap[[NSString stringWithFormat:@"^%@$",routeKey]]) {
            NSLog(@"勿重复注册路由:%@",route);
            return;
        }
        [urlMap setObject:[[TCRouteRegister alloc] initWithPath:route callback:callback] forKey:[NSString stringWithFormat:@"^%@$",routeKey]];
    } else {
        NSMutableDictionary *urlMap = [NSMutableDictionary dictionary];
        [urlMap setObject:[[TCRouteRegister alloc] initWithPath:route callback:callback] forKey:[NSString stringWithFormat:@"^%@$",routeKey]];
        [self.schemes setObject:urlMap forKey:scheme];
    }
}


- (TCRouteParser *)prase:(NSString *)urlStr {
    if (!urlStr) {
        return nil;
    }
    // get scheme
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSString *scheme = [url scheme];
    if (!scheme) {
        NSLog(@"错误的链接");
        return nil;
    }
    
    
    // get url map
    NSDictionary *urlMap = self.schemes[scheme];
    
    // get query
    NSMutableDictionary *params = nil;
    NSString *path = [NSString stringWithFormat:@"/%@",[urlStr substringFromIndex:scheme.length+3]];
    
    NSRange queryRange = [path rangeOfString:@"?"];
    if (queryRange.location != NSNotFound) { //带query参数
        NSString *queryStr = [path substringFromIndex:queryRange.location+1];
        path = [path substringToIndex:queryRange.location];
        NSDictionary *queryParams = [self queryParametersFromUrlString:queryStr];
        if (queryParams.count) {
            params = [NSMutableDictionary dictionaryWithDictionary:queryParams];
        }
    }
    
    //去除最后的"/"
    NSString *stringByDeletingLastPathComponent =path.stringByDeletingLastPathComponent;
    if ([[stringByDeletingLastPathComponent substringFromIndex:stringByDeletingLastPathComponent.length-1]isEqualToString:@"/"]) {
        path = [NSString stringWithFormat:@"%@%@",path.stringByDeletingLastPathComponent,path.lastPathComponent];
    } else {
        path = [NSString stringWithFormat:@"%@/%@",path.stringByDeletingLastPathComponent,path.lastPathComponent];
    }
    
    // 处理http(s)
    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
        if ([self containHost:[url host]]) {
            path = [self getPathFromRoute:path];
        } else {
            NSLog(@"外部的url");
            return [[TCRouteParser alloc]initWithPath:urlStr  callback:nil params:nil];
        }
    }
    
    NSString *pattern =[self matchPatternFromUrlString:path withUrlMap:urlMap];
    if (!pattern) {
        NSLog(@"未匹配到");
        return nil;
    }
    
    //    NSLog(@"匹配到%@",pattern);
    
    
    TCRouteRegister *routeRegister = urlMap[pattern];
    NSString *route = [routeRegister path];
    if ([route rangeOfString:@"/:"].location != NSNotFound) { //有参数
        params =  params ? : [NSMutableDictionary dictionary];
        NSArray<NSString *> *pathComponents = [route componentsSeparatedByString:@"/"];
        NSArray<NSString *> *urlComponents = [path componentsSeparatedByString:@"/"];
        for (NSInteger i =0 ; i < pathComponents.count; i++) {
            NSString *pathComponent = pathComponents[i];
            if (![pathComponent hasPrefix:@":"] || pathComponent.length < 2) {
                continue;
            }
            
            NSString *paramName = [pathComponent substringFromIndex:1];
            NSString *urlComponent = [urlComponents safeObjectAtIndex:i];
            if (urlComponent) {
                NSString *value = urlComponent;
                [params setObject:value forKey:paramName];
            }
        }
    }
    
    return [[TCRouteParser alloc] initWithPath:urlStr callback:routeRegister.callback params:params];
}

- (NSDictionary *)queryParametersFromUrlString:(NSString *)urlString {
    if (urlString.length <= 0) {
        return nil;
    }
    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [urlString componentsSeparatedByString:@"&"];
    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        
        [queryStringDictionary setObject:value forKey:key];
    }
    return queryStringDictionary;
}

- (NSString *)matchPatternFromUrlString:(NSString *)urlStr withUrlMap:(NSDictionary *)urlMap {
    __block NSString *pattern = nil;
    [urlMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:key
                                      options:NSRegularExpressionCaseInsensitive
                                      error:&error];
        NSTextCheckingResult *result = [regex firstMatchInString:urlStr options:0 range:NSMakeRange(0, [urlStr length])];
        if (result) { //匹配
            pattern = key;
            *stop = YES;
        }
    }];
    
    return pattern;
}

- (BOOL)containHost:(NSString *)host {
    if ([self.host isEqualToString:host]) {
        return YES;
    }
    for (NSString *alias in self.aliases) {
        if ([alias isEqualToString:host]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)getPathFromRoute:(NSString *)route {
    NSString *host = [NSString stringWithFormat:@"/%@",self.host];
    if ([route hasPrefix:host]) {
        return route;
    }
    for (NSString *alias in self.aliases) {
        NSString *host = [NSString stringWithFormat:@"/%@",alias];
        if ([route hasPrefix:host]) {
            route = [route stringByReplacingOccurrencesOfString:alias withString:self.host];
            return route;
        }
    }
    NSString *path = [NSString stringWithFormat:@"%@%@",self.host,route];
    if (![path hasPrefix:@"/"]) {path = [NSString stringWithFormat:@"/%@",path];}
    return path;
}

- (NSMutableDictionary<NSString *,NSMutableDictionary *> *)schemes {
    if (_schemes == nil) {
        _schemes = [NSMutableDictionary dictionary];
    }
    return _schemes;
}

//urlEncode编码
-(NSString *)urlEncodeStr:(NSString *)input{
    NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    NSString *upSign = [input stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    return upSign;
}

//urlEncode解码
- (NSString *)decoderUrlEncodeStr: (NSString *) input{
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+" withString:@"" options:NSLiteralSearch range:NSMakeRange(0,[outputStr length])];
    return [outputStr stringByRemovingPercentEncoding];
}

@end


