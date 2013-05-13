//
//  NSData+DDFeedItem.h
//  ReaderFlower
//
//  Created by dudu tsang on 13-1-25.
//  Copyright (c) 2013年 MMM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DDBatchFeedItems;
@class DDTagList;
@class DDStreamPreference;

@interface NSData (DDFeedItem)

//- (NSArray *)feeds;
- (DDBatchFeedItems *)batchFeedItems;
- (NSArray *)subscriptionList;
- (NSMutableArray *)subscriptionGroupList;
- (DDTagList *)tagList;
- (DDStreamPreference *)streamPreference;

@end
