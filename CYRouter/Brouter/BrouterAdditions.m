//
//  BrouterAdditions.m
//  CYRouter
//
//  Created by candy on 2019/3/20.
//  Copyright © 2019 lincy. All rights reserved.
//

#import "BrouterAdditions.h"

@implementation NSArray (Brouter)
- (id)br_objectAtIndex:(NSInteger)index {
    if (index >= 0 && index < self.count) {
        return self[index];
    }
    return nil;
}
@end


@implementation NSString (Brouter)

- (unichar)br_characterAtIndex:(NSInteger)index {
    if (index >= 0 && index < self.length) {
        return [self characterAtIndex:index];
    }
    return 0;
}

- (unichar)br_unichar {
    return [self br_characterAtIndex:0];
}

- (NSString *)br_substringToIndex:(NSInteger)index {
    if (index >= 0 && index < self.length) {
        return [self substringToIndex:NSMaxRange([self rangeOfComposedCharacterSequenceAtIndex:index])];
    }
    return nil;
}

- (NSString *)br_stringByDeletingLastPathComponent {
    if (self.length == 0) {
        return @"/";
    }
    NSInteger idx = self.length-1;
    while (idx > 0) {
        unichar ch = [self characterAtIndex:idx];
        switch (ch) {
            case 0x002f: // '/'
                return [self substringToIndex:idx];
                break;
            default:
                break;
        }
        idx--;
    }
    return @"/";
}

- (BOOL)br_paramNameValid {
    NSRegularExpression *regex = [NSRegularExpression
                                     regularExpressionWithPattern:@"^[a-zA-Z_][\\w]*$"
                                     options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines
                                     error:nil];
    NSArray* matches = [regex matchesInString:self options:0 range: NSMakeRange(0, self.length)];
    return (matches.count>0);
}

@end


@implementation NSError (Brouter)
NSString * const BROUTER_ERROR_DOMAIN = @"Brouter_Error_Domain";
+ (NSError *)br_error:(NSString *)reason {
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : reason };
    NSError *err = [NSError errorWithDomain:BROUTER_ERROR_DOMAIN code:-1 userInfo:userInfo];
    return err;
}

@end
