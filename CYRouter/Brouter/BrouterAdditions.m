//
//  BrouterAdditions.m
//  CYRouter
//
//  Created by candy on 2019/3/20.
//  Copyright © 2019 lincy. All rights reserved.
//

#import "BrouterAdditions.h"

@implementation NSArray (Brouter)
- (id)safeObjectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return self[index];
    }
    return nil;
}
@end
