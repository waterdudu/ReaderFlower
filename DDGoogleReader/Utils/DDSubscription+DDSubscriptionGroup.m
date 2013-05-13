//
//  DDSubscription+DDSubscriptionGroup.m
//  ReaderFlower
//
//  Created by dudu tsang on 13-1-29.
//  Copyright (c) 2013年 MMM. All rights reserved.
//

#import "DDSubscription+DDSubscriptionGroup.h"
#import "DDSubscriptionGroup.h"
#import "DDGRDBDefines.h"
#import "NSString+DDGoogleReader.h"

@interface DDSubscription()

@end

@implementation DDSubscription (DDSubscriptionGroup)


- (DDSubscriptionGroup *)subscriptionGroup
{
    DDSubscriptionGroup *result = [[DDSubscriptionGroup alloc] init];
    result.alone = (self.categoriesId == nil || [self.categoriesId count] == 0) ? true: false;
    result.label = self.title;
    result.sType = [result.label getSubscriptionType];
    result.groupedSubscriptions = [[NSArray alloc] initWithObjects:self, nil];
    
    return result;
}

@end
