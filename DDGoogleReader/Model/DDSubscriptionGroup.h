//
//  DDSubscriptionGroup.h
//  ReaderFlower
//
//  Created by dudu tsang on 13-1-29.
//  Copyright (c) 2013年 MMM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDSubscriptionGroup : NSObject


@property (strong, nonatomic) NSString *label;
@property (strong, nonatomic) NSArray *groupedSubscriptions;
@property (nonatomic) BOOL alone;

@property (nonatomic) int sType;

@end
