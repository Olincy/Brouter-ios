//
//  BrouterAdditions.h
//  CYRouter
//
//  Created by candy on 2019/3/20.
//  Copyright © 2019 lincy. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (Brouter)
- (id)br_objectAtIndex:(NSUInteger)index;
@end

@interface NSString (Brouter)
- (NSString *)br_stringByDeletingLastPathComponent;
- (BOOL)br_paramNameValid;
@end
