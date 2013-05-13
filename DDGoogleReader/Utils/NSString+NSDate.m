//
//  NSString+NSDate.m
//  ReaderFlower
//
//  Created by dudu Shang on 1/26/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "NSString+NSDate.h"

@implementation NSString (NSDate)

- (NSDate *)dateSince1970
{
  
    NSTimeInterval timeIntervel = [self doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeIntervel];
    return date;
}
@end
