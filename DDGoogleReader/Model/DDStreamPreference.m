//
//  DDStreamPreference.m
//  ReaderFlower
//
//  Created by dudu Shang on 2/25/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "DDStreamPreference.h"

@implementation DDStreamPreference

@synthesize streamPrefs = _streamPrefs;
@synthesize subscriptionOrderString = _subscriptionOrderString;

- (id)initWithDict:(NSDictionary *)dict
{
    if ((self = [super init])) {
        self.streamPrefs = dict;
    }
    return self;
}

@end
