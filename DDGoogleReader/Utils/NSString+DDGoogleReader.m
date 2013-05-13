//
//  NSString+DDGoogleReader.m
//  ReaderFlower
//
//  Created by dudu Shang on 1/31/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "NSString+DDGoogleReader.h"

@implementation NSString (DDGoogleReader)

- (NSString *)getLabelContentFromCategoriesId
{
    NSRange range = [self rangeOfString:@"label/"];
    if(range.length != 0)
        return [self substringFromIndex:range.location + range.length];
    else if (range.length == 0)
        return self;
    return nil;
}


- (DDSubscriptionType)getSubscriptionType
{
    DDSubscriptionType type = DDSubscriptionNone;
    // Type: 
    // 1) user/XXXXX/state/com.google
    // 2) feed/http:/xxxxx
    // 3) user/XXXXX/label/x
    
    NSRange rangeFeed      = [self rangeOfString:@"feed/"];
    NSRange rangeComGoogle = [self rangeOfString:@"/state/com.google/"];
    NSRange rangeLabel     = [self rangeOfString:@"/label/"];
    
    if(rangeFeed.length > 0 && rangeFeed.location == 0)
        type = DDSubscriptionFeed;
    else if(rangeComGoogle.length > 0 && rangeComGoogle.location != 0)
        type = DDSubscriptionComGoogle;
    else if (rangeLabel.length > 0 && rangeLabel.location != 0)
        type = DDSubscriptionLabel;
    
    return type;
}
@end
