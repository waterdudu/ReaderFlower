//
//  NSString+DDUtil.m
//  ReaderFlower
//
//  Created by dudu Shang on 2/25/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "NSString+DDUtil.h"

@implementation NSString (DDUtil)

- (BOOL)contains:(NSString *)substring
{
    NSRange range = [self rangeOfString:substring];
    return range.length > 0 ? YES : NO;
}
@end
