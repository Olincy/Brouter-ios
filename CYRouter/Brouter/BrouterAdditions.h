//
//  BrouterAdditions.h
//  CYRouter
//
//  Created by candy on 2019/3/20.
//  Copyright © 2019 lincy. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BR_UNICHAR(s)  [(s) br_unichar]

@interface NSArray (Brouter)
- (id)br_objectAtIndex:(NSInteger)index;
@end

@interface NSString (Brouter)
- (unichar)br_characterAtIndex:(NSInteger)index;
- (unichar)br_unichar;
- (NSString *)br_substringToIndex:(NSInteger)index;
- (NSString *)br_stringByDeletingLastPathComponent;
- (BOOL)br_paramNameValid;
@end

@interface NSError (Brouter)
+ (NSError *)br_error:(NSString *)reason;
@end
