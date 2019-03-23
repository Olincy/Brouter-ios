//
//  BrouterAdditions.m
//  CYRouter
//
//  Created by candy on 2019/3/20.
//  Copyright © 2019 lincy. All rights reserved.
//

#import "BrouterAdditions.h"

@implementation NSArray (Brouter)
- (id)br_objectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return self[index];
    }
    return nil;
}
@end


@implementation NSString (Brouter)

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
