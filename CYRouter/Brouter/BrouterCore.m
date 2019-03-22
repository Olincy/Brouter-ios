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


@implementation BrouteParamRegex
@end


@implementation BrouterRouteTamplate


@end

#pragma mark - BroutePath
@interface BrouterRoutePath ()

@end

@implementation BrouterRoutePath

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        BrouterRoutePath *bPath = (BrouterRoutePath *)object;
        if ([self.routeTamplate.path isEqual:bPath.routeTamplate.path]) {
            return YES;
        }
        if ([self.pathRegex.pattern isEqual:bPath.pathRegex.pattern]) {
            return YES;
        }
    }
    return NO;
}

@end


#pragma mark - BrouteScheme
@interface BrouteScheme ()
@property (nonatomic, strong) NSMutableDictionary <NSString *, BrouterRoutePath *> *pathsMap;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableSet<BrouterRoutePath *> *> *regexRoutesMap;
@end
@implementation BrouteScheme

- (instancetype)initWithScheme:(NSString *)scheme {
    if (self = [super init]) {
        _scheme = scheme;
    }
    return self;
}



@end



#pragma mark - BrouterCore
@interface BrouterCore ()
@property (nonatomic, copy) NSString *baseScheme;
@property (nonatomic, copy) NSString *baseHost;
@property (nonatomic, strong) NSMutableDictionary <NSString *, BrouterRoutePath *> *pathsMap;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableSet<BrouterRoutePath *> *> *regexRoutesMap;
@end
@implementation BrouterCore

static BrouterCore *instance = nil;


- (NSMutableArray<BrouteScheme *> *)schemes {
    if (_schemes == nil) {
        _schemes = [NSMutableArray arrayWithCapacity:1];
    }
    return _schemes;
}

- (NSMutableDictionary<NSString *,BrouterRoutePath *> *)pathsMap {
    if (_pathsMap == nil) {
        _pathsMap = [NSMutableDictionary dictionary];
    }
    return _pathsMap;
}


- (NSMutableDictionary<NSString *,NSMutableSet<BrouterRoutePath *> *> *)regexRoutesMap {
    if (_regexRoutesMap == nil) {
        _regexRoutesMap = [NSMutableDictionary dictionary];
    }
    return _regexRoutesMap;
}


- (BrouterRoutePath *)route:(NSString *)routeTpl toHandler:(BrouterHandler)handler {
    if (handler == nil || routeTpl.length == 0) {
        NSLog(@"trying register an empty path or handler");
        return nil;
    }
    
    BrouterRouteTamplate *tamplate = [self parseRouteTamplate:routeTpl];
    if (tamplate == nil || tamplate.scheme.length <= 0) {
        NSLog(@"invalid route tamplate:%@",routeTpl);
        return nil;
    }
    
    
    //trying find registered scheme from map


    BrouterRoutePath *bPath = nil;
    if (tamplate.paramRegexs.count) { // with params
        NSRegularExpression *compiledRegex = [self compileRegex:routeTpl params:tamplate.paramRegexs];
        BrouteParamRegex *firstParam = [tamplate.paramRegexs safeObjectAtIndex:0];
        NSString *regexRouteKey = @"/";
        if (firstParam.start > 0) {
            regexRouteKey = [routeTpl substringToIndex:firstParam.start];
            if ([regexRouteKey hasSuffix:@"/"]) {
                regexRouteKey = [regexRouteKey substringToIndex:regexRouteKey.length-1];
            }
        }
        NSMutableSet<BrouterRoutePath *> *routeRegexes = [self.regexRoutesMap objectForKey:regexRouteKey];
        bPath = [BrouterRoutePath new];
        bPath.pathRegex = compiledRegex;
        bPath.handler = handler;
        bPath.routeTamplate = tamplate;
        if (routeRegexes == nil) {
            routeRegexes = [NSMutableSet set];
            [self.regexRoutesMap setObject:routeRegexes forKey:regexRouteKey];
        }
        [routeRegexes addObject:bPath];
    } else { // without params
        NSString *routeKey = routeTpl;
        if ([routeKey hasSuffix:@"/"]) {
            routeKey = [routeKey substringToIndex:routeKey.length-1];
        }
        
        bPath = [self.pathsMap objectForKey:routeKey];
        if (bPath == nil) {
            bPath = [BrouterRoutePath new];
            [self.pathsMap setValue:bPath forKey:routeKey];
        }
        bPath.handler = handler;
        
    }
    
    return bPath;
}

- (BrouterRouteTamplate *)parseRouteTamplate:(NSString *)routeTpl {
    //scheme ":" [ "//" ] [ username ":" password "@" ] host [ ":" port ] [ "/" ] [ path ] [ "?" query ]
    
    NSInteger idx= 0;
    NSInteger brace = 0;
    NSInteger lastSlashIdx = -1;
    NSMutableArray *idxs = [NSMutableArray arrayWithCapacity:2];
    NSMutableArray<BrouteParamRegex *> *paramRegexs = [NSMutableArray arrayWithCapacity:1];
    NSMutableSet *nameSet = [NSMutableSet set];
    BrouterRouteTamplate *tamplate = [BrouterRouteTamplate new];
    
    NSString *defaultParamRegex = @"[^/]+"; // match any characters except '/'
    for (NSInteger i=0; i < routeTpl.length; i++) {
        unichar ch = [routeTpl characterAtIndex:i];
        NSLog(@"%hu",ch);
        
        switch (ch) {
            case 0x007b: // '{'
                if (tamplate.scheme == nil) {
                    NSLog(@"invalid route tamplate: %@",routeTpl);
                    return nil;
                }
                brace++;
                if (brace==1) {
                    idx = i;
                } else {
                    NSLog(@"unbalanced braces in %@",routeTpl);
                    return nil;
                }
                break;
            case 0x007d: // '}'
                if (tamplate.scheme == nil) {
                    NSLog(@"invalid route tamplate: %@",routeTpl);
                    return nil;
                }
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
                if (i>0 && lastSlashIdx<0 && tamplate.scheme.length==0) {
                    tamplate.scheme = [routeTpl substringToIndex:NSMaxRange([routeTpl rangeOfComposedCharacterSequenceAtIndex:i])];
                }
                break;
            case 0x002f: // '/'
                lastSlashIdx = i;
                if (brace != 0) {
                    return nil; 
                }
                break;
                
//            case 0x003f: // '?'
//                return nil;
                
            default:
                break;
        }
    }
    if (brace != 0) {
        NSLog(@"unbalanced braces in %@",routeTpl);
        return nil;
    }
    tamplate.paramRegexs = paramRegexs;
    
    return  tamplate;
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


- (NSDictionary *)matchRoute:(BrouterRoutePath *)bRoute withUrlStr:(NSString *)urlStr {
    if (bRoute.pathRegex == nil) {return nil;}
    
    NSArray* matches = [bRoute.pathRegex matchesInString:urlStr options:0 range: NSMakeRange(0, urlStr.length)];
    if (matches.count) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSTextCheckingResult* match = matches.firstObject;
        for (NSInteger i=0; i<match.numberOfRanges; i++) {
            NSRange capRange = [match rangeAtIndex:i];
            NSString *capStr = [urlStr substringWithRange:capRange];
            if (i > 0) {
                BrouteParamRegex *pRegex = [bRoute.routeTamplate.paramRegexs safeObjectAtIndex:i-1];
                if (pRegex != nil) {
                    [params setObject:capStr forKey:pRegex.name];
                }
            }
        }
        return params;
    }
    
    return nil;
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
    
    BrouterRoutePath *path = [self.pathsMap objectForKey:routeStr];
    if (path == nil) {
        // try from regex map
        
        NSString *routeKey = routeStr.stringByDeletingLastPathComponent;
        while (routeKey.length) {
            NSMutableSet<BrouterRoutePath *> *routeRegexSet = [self.regexRoutesMap objectForKey:routeKey];
            if (routeRegexSet.count) {
                for (BrouterRoutePath *regexPath in routeRegexSet) {
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



@end


