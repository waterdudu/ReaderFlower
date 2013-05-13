//
//  DDTagList.m
//  ReaderFlower
//
//  Created by dudu Shang on 2/25/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "DDTagList.h"

@implementation DDTagList

@synthesize tagList = _tagList;

- (id)initWithTagListDictionaryArray:(NSArray *)array
{
    if ((self = [super init])) {
        self.tagList = array;
    }
    return self;
}

@end
