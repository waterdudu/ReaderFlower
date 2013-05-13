//
//  DDSubscription+DDSubscriptionGroup.h
//  ReaderFlower
//
//  Created by dudu tsang on 13-1-29.
//  Copyright (c) 2013年 MMM. All rights reserved.
//

#import "DDSubscription.h"

@class DDSubscriptionGroup;

@interface DDSubscription (DDSubscriptionGroup)

- (DDSubscriptionGroup *)subscriptionGroup;

@end
