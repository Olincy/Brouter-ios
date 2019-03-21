//
//  BrouterCore.m
//  Brouter
//
//  Created by lincy on 2018/7/9.
//  Copyright © 2018年 lincy. All rights reserved.
//

#import "BrouterCore.h"
#import "BrouterAdditions.h"

#define BROUTER_NIL_HOST        (@"broute-nil")
#define BROUTER_NIL_PATH        (@"/")

#pragma mark - BrouteParamRegex
@interface BrouteParamRegex : NSObject
@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger end;
@property (nonatomic, copy) NSString *occurrenceStr; //Occurrence string
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *regex;
@end

@implementation BrouteParamRegex
@end

#pragma mark - BroutePath
@interface BroutePath ()
@property (nonatomic, strong) NSArray<BrouteParamRegex *> *paramRegexes;
@end

@implementation BroutePath

- (instancetype)initWithPath:(NSString *)path {
    if (self = [super init]) {
        _path = path;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        BroutePath *bPath = (BroutePath *)object;
        if ([self.path isEqual:[bPath path]]) {
            return YES;
        }
        if ([self.pathRegex.pattern isEqual:bPath.pathRegex.pattern]) {
            return YES;
        }
    }
    return NO;
}

@end


@implementation BroutePath2Handler

@end

@implementation BrouteMaker

+ (BroutePath2Handler *)path:(NSString *)path toHandler:(BrouterHandler)handler {
    BroutePath2Handler *path2handler = [[BroutePath2Handler alloc]init];
    path2handler.path = path;
    path2handler.handler = handler;
    return path2handler;
}

@end

#pragma mark - BrouteScheme
@interface BrouteScheme ()
@property (nonatomic, strong) NSMutableDictionary <NSString *, BroutePath *> *pathsMap;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableSet<BroutePath *> *> *regexRoutesMap;
@property (nonatomic, strong) NSMutableArray <NSString *> *routeRegexes;
@end
@implementation BrouteScheme

- (instancetype)initWithScheme:(NSString *)scheme {
    if (self = [super init]) {
        _scheme = scheme;
    }
    return self;
}

- (NSMutableDictionary<NSString *,BroutePath *> *)pathsMap {
    if (_pathsMap == nil) {
        _pathsMap = [NSMutableDictionary dictionary];
    }
    return _pathsMap;
}

- (NSMutableArray<NSString *> *)routeRegexes {
    if (_routeRegexes == nil) {
        _routeRegexes = [NSMutableArray array];
    }
    return _routeRegexes;
}

- (NSMutableDictionary<NSString *,NSMutableSet<BroutePath *> *> *)regexRoutesMap {
    if (_regexRoutesMap == nil) {
        _regexRoutesMap = [NSMutableDictionary dictionary];
    }
    return _regexRoutesMap;
}

@end



#pragma mark - BrouterCore
@interface BrouterCore ()
@property (nonatomic, copy) NSString *baseScheme;
@property (nonatomic, copy) NSString *baseHost;
@property (nonatomic, strong) NSMutableDictionary <NSString *, BrouteScheme *> *schemesMap;
@end
@implementation BrouterCore

static BrouterCore *instance = nil;

- (void)setBaseUrl:(NSString *)baseUrl {
    if (baseUrl == nil) {return;}
    _baseUrl = baseUrl;
    NSURL *url = [NSURL URLWithString:baseUrl];
    if (url && url.scheme) {
        _baseScheme = [NSString stringWithFormat:@"%@://",url.scheme];
    }
}

- (instancetype)initWithScheme:(NSString *)scheme
                          host:(NSString *)host
                          path:(NSString *)path
                       handler:(BrouterHandler)handler {
    if (self = [super init]) {
        BrouteScheme *bScheme = [self.schemesMap objectForKey:scheme];
        if (bScheme == nil) {
            bScheme = [[BrouteScheme alloc]initWithScheme:scheme];
        }
    }
    return self;
}

- (NSMutableArray<BrouteScheme *> *)schemes {
    if (_schemes == nil) {
        _schemes = [NSMutableArray arrayWithCapacity:1];
    }
    return _schemes;
}

- (NSMutableDictionary<NSString *,BrouteScheme *> *)schemesMap {
    if (_schemesMap == nil) {
        _schemesMap = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return _schemesMap;
}

- (BOOL)inScheme:(NSString *)scheme path2handlers:(NSArray<BroutePath2Handler *> *)path2handlers {
    if (scheme.length == 0 || path2handlers.count == 0) {return NO;}
    
    // checking scheme
    NSString *schemeStr = scheme;
    NSURL *schemeUrl = [NSURL URLWithString:scheme];
    if (![schemeStr hasSuffix:@"://"]) {
        schemeStr = [NSString stringWithFormat:@"%@://",schemeStr];
        schemeUrl = [NSURL URLWithString:schemeStr];
    }
    if (schemeUrl == nil || ![[NSString stringWithFormat:@"%@://",schemeUrl.scheme] isEqualToString:schemeStr]) {
        NSLog(@"bad scheme.");
        return NO;
    }
    
    
    
    //trying find registered scheme from map
    BrouteScheme *bScheme = [self.schemesMap objectForKey:schemeStr];
    if (bScheme == nil) {
        bScheme = [[BrouteScheme alloc]init];
        [self.schemesMap setValue:bScheme forKey:schemeStr];
    }
    
    for (BroutePath2Handler *path2handler in path2handlers) {
        if (path2handler.handler == nil || path2handler.path.length == 0) {
            NSLog(@"trying register an empty path or handler");
            return NO;
        }
        NSRange range = [path2handler.path rangeOfString:@"://"];
        if (range.length) {
            NSString *pathScheme = [path2handler.path substringToIndex:range.location+3];
            if (![pathScheme isEqualToString:schemeStr]) {
                NSLog(@"trying register a difference scheme: %@",pathScheme);
                return NO;
            }
            path2handler.path = [path2handler.path substringFromIndex:range.location+3];
            if (path2handler.path.length == 0) {
                NSLog(@"trying register an empty path");
                return NO;
            }
        }
        
        if ([path2handler.path containsString:@"{"]) { //with regular expresses
            NSArray<BrouteParamRegex *> *bParams = [self parsingParams:path2handler.path];
            if (bParams.count == 0) {
                return NO;
            }
            NSLog(@"%@",bParams);
            NSRegularExpression *compiledRegex = [self compileRegex:path2handler.path params:bParams];
            BrouteParamRegex *firstParam = bParams[0];
            NSString *regexRouteKey = @"/";
            if (firstParam.start > 0) {
                regexRouteKey = [path2handler.path substringToIndex:firstParam.start];
                if ([regexRouteKey hasSuffix:@"/"]) {
                    regexRouteKey = [regexRouteKey substringToIndex:regexRouteKey.length-1];
                }
            }
            NSMutableSet<BroutePath *> *routeRegexes = [bScheme.regexRoutesMap objectForKey:regexRouteKey];
            BroutePath *bPath = [BroutePath new];
            bPath.pathRegex = compiledRegex;
            bPath.handler = path2handler.handler;
            bPath.paramRegexes = bParams;
            if (routeRegexes == nil) {
                routeRegexes = [NSMutableSet set];
                [bScheme.regexRoutesMap setObject:routeRegexes forKey:regexRouteKey];
            }
            [routeRegexes addObject:bPath];
            
        } else { // without regular expresses
            NSString *routeKey = path2handler.path;
            NSURL *routeUrl = [NSURL URLWithString:routeKey];
            if (routeUrl == nil) {
                NSLog(@"bad url");
                return NO;
            }
            if (![routeKey hasPrefix:@"/"]) {
                routeKey = [NSString stringWithFormat:@"/%@",routeKey];
            }
            if ([routeKey hasSuffix:@"/"]) {
                routeKey = [routeKey substringToIndex:routeKey.length-1];
            }
            BroutePath *bPath = [bScheme.pathsMap objectForKey:routeKey];
            if (bPath == nil) {
                bPath = [[BroutePath alloc]init];
                [bScheme.pathsMap setValue:bPath forKey:routeKey];
            }
            bPath.handler = path2handler.handler;
        }
        
        
    }
    
    return  YES;
}

- (NSRegularExpression *)compileRegex:(NSString *)routeTpl params:(NSArray<BrouteParamRegex *> *)params {
    NSMutableString *regexStr = [NSMutableString stringWithString:routeTpl];
    
    // remove slash at begin&end
    [regexStr replaceOccurrencesOfString:@"/" withString:@"" options:NSBackwardsSearch range:NSMakeRange(0, 1)];
    [regexStr replaceOccurrencesOfString:@"/" withString:@"" options:NSBackwardsSearch range:NSMakeRange(regexStr.length-1, 1)];
    for (NSInteger i = 0; i < params.count; i++) {
        BrouteParamRegex *bParam = params[i];
        NSString *occString = [routeTpl substringWithRange:NSMakeRange(bParam.start, bParam.end-bParam.start+1)];
        [regexStr replaceOccurrencesOfString:occString withString:[NSString stringWithFormat:@"(%@)",bParam.regex] options:NSBackwardsSearch range:NSMakeRange(0, regexStr.length)];
    }
    NSError *error;
    NSRegularExpression *regexObj = [NSRegularExpression
                                  regularExpressionWithPattern:[NSString stringWithFormat:@"^[/]?%@[/]?$",regexStr]
                                  options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines
                                  error:&error];
    return regexObj;
}


// case1: http://www.sample.com/path/to/position
// case2: www.sample.com/path/to/positon
// case1: path/to/position
// case4: /path/to/position
// case5: path/to/positon/
- (BOOL)push:(NSString *)urlStr {
    NSURL *url = [NSURL URLWithString:urlStr];
    if (url == nil) {
        NSLog(@"bad url.");
        return NO;
    }
    
    NSString *schemeStr;
    NSString *routeStr = urlStr;
    if (url.scheme.length) { //with scheme
        if (url.host.length==0 && url.path.length==0) { return NO;}
        routeStr = [urlStr substringFromIndex:url.scheme.length+2];
        if (routeStr.length==0) {
            return NO;
        }
        schemeStr = [NSString stringWithFormat:@"%@://",url.scheme];
    } else { // without scheme
        if (self.baseUrl==nil) {
            NSLog(@"no specific base url for path.");
            return NO;
        }
        schemeStr = self.baseScheme;
        if (![urlStr hasPrefix:@"/"]) {
            routeStr = [NSString stringWithFormat:@"/%@",urlStr];
        }
    }
    BrouteScheme *bScheme = [self.schemesMap objectForKey:schemeStr];
    if (bScheme == nil) {
        NSLog(@"unregistered scheme.");
        return NO;
    }
    BroutePath *path = [bScheme.pathsMap objectForKey:routeStr];
    if (path == nil) {
        // try from regex map
        
        NSString *routeKey = routeStr.stringByDeletingLastPathComponent;
        while (routeKey.length) {
            NSMutableSet<BroutePath *> *routeRegexSet = [bScheme.regexRoutesMap objectForKey:routeKey];
            if (routeRegexSet.count) {
                for (BroutePath *regexPath in routeRegexSet) {
                    NSDictionary *params = [self matchRoute:regexPath withUrlStr:routeStr ];
                    if (params == nil) {
                        return NO;
                    }
                    
                }
            }
            if ([routeKey isEqualToString:@"/"]) {
                break;
            }
            routeKey = routeKey.stringByDeletingLastPathComponent;
        }
        
        
    }
    
    if (path.handler) {
        path.handler(nil);
    }
    
    
    return YES;
}



- (BOOL)inScheme:(NSString *)scheme host:(NSString *)host addPath:(NSString *)pathTpl toHandler:(BrouterHandler)handler {
    return YES;
}
//
//- (void)setBaseUrl:(NSString *)baseUrl {
//    NSURL *url = [NSURL URLWithString:baseUrl];
//    if (url.scheme == nil || url.host == nil) {
//        NSLog(@"invalid base url.");
//        return;
//    }
//    _baseUrl = baseUrl;
//}

- (NSDictionary *)matchRoute:(BroutePath *)bRoute withUrlStr:(NSString *)urlStr {
    if (bRoute.pathRegex == nil) {return nil;}
    
    NSArray* matches = [bRoute.pathRegex matchesInString:urlStr options:0 range: NSMakeRange(0, urlStr.length)];
    if (matches.count) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSTextCheckingResult* match = matches.firstObject;
        for (NSInteger i=0; i<match.numberOfRanges; i++) {
            NSRange capRange = [match rangeAtIndex:i];
            NSString *capStr = [urlStr substringWithRange:capRange];
            if (i > 0) {
                BrouteParamRegex *pRegex = [bRoute.paramRegexes safeObjectAtIndex:i-1];
                if (pRegex != nil) {
                    [params setObject:capStr forKey:pRegex.name];
                }
            }
        }
        return params;
    }
    
    return nil;
}

- (BroutePath *)route:(NSString *)routeTpl toHandler:(BrouterHandler)handler {
    return nil;
}


- (NSMutableArray<BrouteParamRegex *> *)parsingParams:(NSString *)routeTpl {
    //scheme ":" [ "//" ] [ username ":" password "@" ] host [ ":" port ] [ "/" ] [ path ] [ "?" query ]
    
    //    urlString.stringByStandardizingPath
    
    NSInteger idx= 0;
    NSInteger brace = 0;
    NSMutableArray *idxs = [NSMutableArray arrayWithCapacity:2];
    NSMutableArray<BrouteParamRegex *> *paramRegexs = [NSMutableArray arrayWithCapacity:1];
    NSMutableSet *nameSet = [NSMutableSet set];
    
    NSString *defaultParamRegex = @"[^/]+"; // match any characters except '/'
    for (NSInteger i=0; i < routeTpl.length; i++) {
        //        NSString *ch = [urlString substringWithRange:NSMakeRange(i, 1)];
        unichar ch = [routeTpl characterAtIndex:i];
        NSLog(@"%hu",ch);
        
        switch (ch) {
            case 0x007b: // '{'
                brace++;
                if (brace==1) {
                    idx = i;
                } else {
                    NSLog(@"unbalanced braces in %@",routeTpl);
                    return nil;
                }
                break;
            case 0x007d: // '}'
                brace--;
                if (brace == 0) {
                    [idxs addObjectsFromArray:@[@(idx),@(i)]];
                    NSString *paramTpl = [routeTpl substringWithRange:NSMakeRange(idx+1, i-idx-1)];
                    
                    NSArray<NSString *> *pComps = [paramTpl componentsSeparatedByString:@":"];
                    NSString *name = pComps[0];
                    NSString *regex = defaultParamRegex;
                    if (pComps.count==2) {
                        regex = pComps[1];
                    }
                    if (name.length==0 || regex.length==0) {
                        NSLog(@"missing param name or pattern in %@",routeTpl);
                        return nil;
                    }
                    if ([nameSet containsObject:name]) {
                        NSLog(@"duplicate param name in %@",routeTpl);
                        return nil;
                    }
                    [nameSet addObject:name];
                    BrouteParamRegex *bParamReg = [BrouteParamRegex new];
                    bParamReg.start = idx;
                    bParamReg.end = i;
                    bParamReg.name = name;
                    bParamReg.regex = regex;
                    [paramRegexs addObject:bParamReg];
                } else {
                    NSLog(@"unbalanced braces in %@",routeTpl);
                    return nil;
                }
                break;
            case 0x003A: // ':'
                break;
            case 0x002f: // '/'
                break;
                
            default:
                break;
        }
    }
    if (brace != 0) {
        NSLog(@"unbalanced braces in %@",routeTpl);
        return nil;
    }
    
    
    return  paramRegexs;
}

@end


