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

#pragma mark - BrouteParamPattern

@interface BrouteParamPattern : NSObject
@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger end;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *regex;
@end
@implementation BrouteParamPattern
@end

#pragma mark - BrouterRouteTamplate
@interface BrouterRouteTamplate ()
@property (nonatomic, strong) NSRegularExpression *compiledRegex;
@property (nonatomic, copy) NSArray<BrouteParamPattern *> *paramPatterns;
@end
@implementation BrouterRouteTamplate
@end

#pragma mark - BroutePath
@interface BrouterRoutePath ()
@property (nonatomic, strong) BrouterRouteTamplate *compiledTamplate;
@end

@implementation BrouterRoutePath

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        BrouterRoutePath *bPath = (BrouterRoutePath *)object;
        if ([self.pathRegex.pattern isEqual:bPath.pathRegex.pattern]) {
            return YES;
        }
    }
    return NO;
}

@end

@implementation BrouterResponse


@end

#pragma mark - BrouterCore
@interface BrouterCore ()
@property (nonatomic, strong) NSMutableDictionary <NSString *, BrouterRoutePath *> *normalRoutesMap;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableOrderedSet<BrouterRoutePath *> *> *regexRoutesMap;
@end
@implementation BrouterCore

#pragma mark Public Methods
- (BrouterRoutePath *)route:(NSString *)routeTpl toHandler:(id)handler {
    if (handler == nil || routeTpl.length == 0) {
        NSLog(@"trying register an empty path or handler");
        return nil;
    }
    
    BrouterRouteTamplate *tamplate = [self resolveRouteTamplate:routeTpl];
    if (tamplate == nil || tamplate.scheme.length <= 0) {
        NSLog(@"invalid route tamplate:%@",routeTpl);
        return nil;
    }
    
    
    //trying find registered scheme from map
    BrouterRoutePath *bPath = nil;
    if (tamplate.paramPatterns.count) { // with params
        NSRegularExpression *compiledRegex = [self compileRegex:routeTpl params:tamplate.paramPatterns];
        
        NSMutableOrderedSet<BrouterRoutePath *> *routeRegexes = [self.regexRoutesMap objectForKey:tamplate.routeKey];
        bPath = [BrouterRoutePath new];
        bPath.pathRegex = compiledRegex;
        bPath.routeHandler = handler;
        bPath.compiledTamplate = tamplate;
        if (routeRegexes == nil) {
            routeRegexes = [NSMutableOrderedSet orderedSet];
            [self.regexRoutesMap setObject:routeRegexes forKey:tamplate.routeKey];
        }
        [routeRegexes addObject:bPath];
    } else { // without params
        NSString *routeKey = routeTpl;
        if ([routeKey hasSuffix:@"/"]) {
            routeKey = [routeKey substringToIndex:routeKey.length-1];
        }
        
        bPath = [self.normalRoutesMap objectForKey:routeKey];
        if (bPath == nil) {
            bPath = [BrouterRoutePath new];
            [self.normalRoutesMap setValue:bPath forKey:routeKey];
        }
        
        
        bPath.routeHandler = handler;
    }
    
    return bPath;
}

- (BrouterResponse *)parse:(NSString *)urlStr {
    BrouterResponse *bResponse = [BrouterResponse new];
    if (urlStr.length == 0) {
        bResponse.error = [NSError br_error:@"empty url string."];
        return bResponse;
    }
    
    
    // get query string
    NSURLComponents *urlComp = [NSURLComponents componentsWithString:urlStr];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (urlComp == nil) {
        bResponse.error = [NSError br_error:@"invalid url string."];
        return bResponse;
    }
    for (NSURLQueryItem *item in urlComp.queryItems) {
        [params setValue:item.value forKey:item.name];
    }
    
    urlComp.query = nil;
    NSString *absoluteUrlStr = urlComp.string;
    BrouterRoutePath *path = [self.normalRoutesMap objectForKey:absoluteUrlStr];
    if (path == nil) {
        // match from regex map
        NSString *routeKey = [absoluteUrlStr br_stringByDeletingLastPathComponent];
        while (routeKey.length) {
            NSMutableOrderedSet<BrouterRoutePath *> *routeRegexSet = [self.regexRoutesMap objectForKey:routeKey];
            if (routeRegexSet.count) {
                for (NSInteger i = routeRegexSet.count-1; i>=0; i--) {
                    BrouterRoutePath *regexPath = [routeRegexSet objectAtIndex:i];
                    NSDictionary *urlParams = [self matchRoute:regexPath withUrlStr:absoluteUrlStr];
                    if (urlParams.count) {
                        // matched
                        [params addEntriesFromDictionary:urlParams];
                        bResponse.params = params;
                        bResponse.routeHandler = regexPath.routeHandler;
                        return bResponse;
                    }
                }
            }
            if ([routeKey isEqualToString:@"/"]) {
                break;
            }
            routeKey = [routeKey br_stringByDeletingLastPathComponent];
        }
        
    } else {
        bResponse.routeHandler = path.routeHandler;
    }
    
    if (bResponse.routeHandler == nil) { // not matched
        bResponse.error = [NSError br_error:@"no matched url string."];
    }
    
    return bResponse;
}


#pragma mark Private Methods


- (BrouterRouteTamplate *)resolveRouteTamplate:(NSString *)routeTpl {
    //scheme ":" [ "//" ] [ username ":" password "@" ] host [ ":" port ] [ "/" ] [ path ] [ "?" query ]
    
    NSInteger braceStart= 0;
    NSInteger braceTag = 0;
    NSInteger lastSlashIdx = -1;
    NSMutableArray *idxs = [NSMutableArray arrayWithCapacity:2];
    NSMutableArray<BrouteParamPattern *> *paramPatterns = [NSMutableArray arrayWithCapacity:1];
    NSMutableSet *nameSet = [NSMutableSet set];
    BrouterRouteTamplate *tamplate = [BrouterRouteTamplate new];
    NSString *routeKey = nil;
    
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
                braceTag++;
                if (braceTag==1) {
                    braceStart = i;
                } else {
                    NSLog(@"unbalanced braces in %@",routeTpl);
                    return nil;
                }
                if (routeKey.length == 0) {
                    routeKey = @"/";
                }
                break;
            case 0x007d: // '}'
                braceTag--;
                if (braceTag == 0) {
                    [idxs addObjectsFromArray:@[@(braceStart),@(i)]];
                    NSString *paramTpl = [routeTpl substringWithRange:NSMakeRange(braceStart+1, i-braceStart-1)];
                    
                    NSArray<NSString *> *pComps = [paramTpl componentsSeparatedByString:@":"];
                    NSString *name = pComps[0];
                    NSString *regex = defaultParamRegex;
                    if (pComps.count==2) {
                        regex = pComps[1];
                    }
                    if (name.length==0 || regex.length==0 || ![name br_paramNameValid]) {
                        NSLog(@"missing param name or pattern in %@",routeTpl);
                        return nil;
                    }
                    if ([nameSet containsObject:name]) {
                        NSLog(@"duplicate param name in %@",routeTpl);
                        return nil;
                    }
                    [nameSet addObject:name];
                    BrouteParamPattern *bParamReg = [BrouteParamPattern new];
                    bParamReg.start = braceStart;
                    bParamReg.end = i;
                    bParamReg.name = name;
                    bParamReg.regex = regex;
                    [paramPatterns addObject:bParamReg];
                } else {
                    NSLog(@"unbalanced braces in %@",routeTpl);
                    return nil;
                }
                break;
            case 0x003A: // ':'
                if (tamplate.scheme.length==0) {
                    tamplate.scheme = [routeTpl br_substringToIndex:i];
                }
                if (tamplate.scheme.length==0) {
                    NSLog(@"missing scheme route tamplate: %@",routeTpl);
                    return nil;
                }
                break;
            case 0x002f: // '/'
                lastSlashIdx = i;
                if (tamplate.scheme.length==0) {
                    NSLog(@"missing scheme route tamplate: %@",routeTpl);
                    return nil;
                }
                if (braceTag != 0) {
                    NSLog(@"invalid route tamplate: %@",routeTpl);
                    return nil; 
                }
                if (braceStart == 0) {
                    routeKey = [routeTpl substringToIndex:i];
                }
                break;
                
            case 0x003f: // '?'
                NSLog(@"trying with queries in route tamplate: %@",routeTpl);
                return nil;
                
            default:
                break;
        }
    }
    if (braceTag != 0) {
        NSLog(@"unbalanced braces in %@",routeTpl);
        return nil;
    }
    tamplate.paramPatterns = paramPatterns;
    tamplate.routeKey = routeKey?:routeTpl;
    tamplate.compiledRegex = [self compileRegex:routeTpl params:tamplate.paramPatterns];
    
    return  tamplate;
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
                BrouteParamPattern *pRegex = [bRoute.compiledTamplate.paramPatterns br_objectAtIndex:i-1];
                if (pRegex != nil) {
                    [params setObject:capStr forKey:pRegex.name];
                }
            }
        }
        return params;
    }
    
    return nil;
}



- (NSRegularExpression *)compileRegex:(NSString *)routeTpl params:(NSArray<BrouteParamPattern *> *)params {
    NSMutableString *regexStr = [NSMutableString stringWithString:routeTpl];
    
    // remove slash at begin&end
    [regexStr replaceOccurrencesOfString:@"/" withString:@"" options:NSBackwardsSearch range:NSMakeRange(0, 1)];
    [regexStr replaceOccurrencesOfString:@"/" withString:@"" options:NSBackwardsSearch range:NSMakeRange(regexStr.length-1, 1)];
    for (NSInteger i = 0; i < params.count; i++) {
        BrouteParamPattern *bParam = params[i];
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


#pragma mark Getter / Setter

- (NSMutableDictionary<NSString *,BrouterRoutePath *> *)normalRoutesMap {
    if (_normalRoutesMap == nil) {
        _normalRoutesMap = [NSMutableDictionary dictionary];
    }
    return _normalRoutesMap;
}


- (NSMutableDictionary<NSString *,NSMutableOrderedSet<BrouterRoutePath *> *> *)regexRoutesMap {
    if (_regexRoutesMap == nil) {
        _regexRoutesMap = [NSMutableDictionary dictionary];
    }
    return _regexRoutesMap;
}


@end




