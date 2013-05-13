//
//  NSData+DDFeedItem.m
//  ReaderFlower
//
//  Created by dudu tsang on 13-1-25.
//  Copyright (c) 2013年 MMM. All rights reserved.
//

#import "NSData+DDFeedItem.h"
#import "JSONKit.h"
#import "DDFeedItem.h"
#import "DDSubscription.h"
#import "DDReaderDefines.h"
#import "DDBatchFeedItems.h"
#import "DDTagList.h"
#import "DDStreamPreference.h"
#import "DDSubscription+DDSubscriptionGroup.h"
#import "DDSubscriptionGroup.h"

#import "NSString+DDUtil.h"

#import "NSString+DDGoogleReader.h"

@interface NSData()

- (NSString *)getSubscriptionOrderingString:(NSDictionary *)dict forKey:(NSString *)key;

@end

@implementation NSData (DDFeedItem)

- (NSString *)getContentFromContent:(NSDictionary *)dict
{
    if ([dict objectForKey:kDDFeedItemContent] == nil) return nil;
    return [[dict objectForKey:kDDFeedItemContent] objectForKey:kDDFeedItemContent];
    
}
- (NSString *)getContentFromSummary:(NSDictionary *)dict
{
    if ([dict objectForKey:kDDFeedItemSummary] == nil) return nil;
    return [[dict objectForKey:kDDFeedItemSummary] objectForKey:kDDFeedItemContent];
}

- (NSArray *)getCategoriesIdAndLabelFromSubscriptionDict:(NSDictionary *)dict
{
    NSArray *categories        = [dict objectForKey:kDDSubscriptionCategories];
    if ([categories count] == 0) {
        return nil;
    }
    int capacity               = [categories count];
    NSMutableArray *result     = [[NSMutableArray alloc] initWithCapacity:2];
    NSMutableArray *idArray    = [[NSMutableArray alloc] initWithCapacity:capacity];
    NSMutableArray *labelArray = [[NSMutableArray alloc] initWithCapacity:capacity];
    
    for (NSDictionary *d in categories) {
        NSString *categoriesId    = [d objectForKey:kDDSubscriptionCategoriesId];
        NSString *categoriesLabel = [d objectForKey:kDDSubscriptionCategoriesLabel];
        [idArray addObject:categoriesId];
        [labelArray addObject:categoriesLabel];
    }
    [result addObject:idArray];
    [result addObject:labelArray];
    
    return [[NSArray alloc] initWithArray:result];  // TODO:return result or a new NSArray?
}

- (DDSubscription *)getSubscriptionFromDict:(NSDictionary *)dict
{
    DDSubscription *s = [[DDSubscription alloc] init];
    s.subscriptionId  = [dict objectForKey:kDDSubscriptionId];
    s.title           = [dict objectForKey:kDDSubscriptionTitle];
    s.sortid          = [dict objectForKey:kDDSubscriptionSortid];
    s.firstitemmsec   = [dict objectForKey:kDDSubscriptionFirstitemmsec];

    s.sType            = [s.subscriptionId getSubscriptionType];
    
    NSArray *cArray   = [self getCategoriesIdAndLabelFromSubscriptionDict:dict];
    s.categoriesId    = [cArray objectAtIndex:0];
    s.categoriesLabel = [cArray objectAtIndex:1];
    
    
    return s;

}

#pragma mark -
#pragma mark feeds & suscription

- (DDBatchFeedItems *)batchFeedItems
{

///////////////////////////////////////////////////////////////////////////
//               a result example (dictionary)
///////////////////////////////////////////////////////////////////////////
//    {
//    direction: "ltr",
//        id: "feed/http://blog.sina.com.cn/rss/1191258123.xml",
//    title: "韩寒",
//    continuation: "CJfBiLuj9J8C",
//        self: [
//        {
//             href: "http://www.google.com.hk/reader/api/0/stream/contents/feed/http%3A%2F%2Fblog.sina.com.cn%2Frss%2F1191258123.xml?r=n&c=CJbTyY6a6acC&n=40&ck=1357896142427&client=scroll"
//        }
//               ],
//    alternate: [
//        {
//        href: "http://blog.sina.com.cn/twocold",
//        type: "text/html"
//        }
//                ],
//    updated: 1301038503,
//    items: []
//     }

    DDBatchFeedItems *result = [[DDBatchFeedItems alloc] init];

    // TODO : input error check
//    NSDictionary *feedsDict = [self objectFromJSONData];
    NSError *error = nil;
    
    NSDictionary *feedsDict = [NSJSONSerialization JSONObjectWithData:self options:kNilOptions error:&error];
    
    if (feedsDict == nil || error != nil) 
    {
        DLog(@"%@", [error description]);
        return nil;
    }
    
    result.feedId = [feedsDict objectForKey:@"id"];
    result.title  = [feedsDict objectForKey:@"title"];
    result.continuation = [feedsDict objectForKey:@"continuation"];
    
    // get all items
    NSArray *allItems = [feedsDict objectForKey:@"items"];
    
    NSMutableArray *feeds = [[NSMutableArray alloc] initWithCapacity:[allItems count]];
    
    // TODO:use fast enum
    for (NSDictionary *itemDict in allItems) {
        DDFeedItem *item = [[DDFeedItem alloc] init];
        item.crawlTime = [itemDict objectForKey:kDDFeedItemCrawlTimeMsec];
        item.title     = [itemDict objectForKey:kDDFeedItemTitle];
        item.author    = [itemDict objectForKey:kDDFeedItemAuthor];
        item.itemId    = [itemDict objectForKey:kDDFeedItemId];
        item.published = [itemDict objectForKey:kDDFeedItemPublished];
        item.updated   = [itemDict objectForKey:kDDFeedItemUpdated];
        //        item.alternateHref = [itemDict objectForKey:kDDFeedItem
        item.alternateHref = [[[itemDict objectForKey:@"alternate"] objectAtIndex:0] objectForKey:@"href"];
        
        item.summary       = [self getContentFromSummary:itemDict];
        item.content       = [self getContentFromContent:itemDict];
        
        item.isRead   = NO;
        item.isLiked  = NO;  // TODO:what should this value be?
        item.isShared = NO;  // TODO:what should this value be?
        item.isStar   = NO;  // TODO:what should this value be?
        
        // TODO:add more to DDFeedItem

        [feeds addObject:item];
    }
    
    // TODO:should i use initwitharray method?
    // see:http://stackoverflow.com/questions/1768937/how-do-i-convert-nsmutablearray-to-nsarray
    //     http://stackoverflow.com/questions/1746204/disadvantage-of-using-nsmutablearray-vs-nsarray
    //     http://cocoadev.com/wiki/NSMutableArray
    result.items = [[NSArray alloc] initWithArray:feeds];   
    
    return result;
}

- (NSArray *)subscriptionList
{
    NSError *error = nil;
    
    NSDictionary *subscriptionDict = [NSJSONSerialization JSONObjectWithData:self options:kNilOptions error:&error];
    
    if (subscriptionDict == nil || error != nil) return nil;
    
    // get all subscriptions
    NSArray *allSubscriptions = [subscriptionDict objectForKey:@"subscriptions"];
    
    NSMutableArray *subscriptions = [[NSMutableArray alloc] initWithCapacity:[allSubscriptions count]];

    for (NSDictionary *sDict in allSubscriptions) {
        DDSubscription *s = [[DDSubscription alloc] init];
        s.subscriptionId  = [sDict objectForKey:kDDSubscriptionId];
        s.title           = [sDict objectForKey:kDDSubscriptionTitle];
        s.sortid          = [sDict objectForKey:kDDSubscriptionSortid];
        s.firstitemmsec   = [sDict objectForKey:kDDSubscriptionFirstitemmsec];
        
        NSArray *cArray   = [self getCategoriesIdAndLabelFromSubscriptionDict:sDict];
        s.categoriesId    = [cArray objectAtIndex:0];
        s.categoriesLabel = [cArray objectAtIndex:1];
        
        [subscriptions addObject:s];
    }
    // TODO:1, 2 or 3???
    // currently i'm using 2, see:http://stackoverflow.com/questions/3749657/nsmutablearray-arraywitharray-vs-initwitharray
    // return [NSArray arrayWithArray:subscriptions];              // 1
    return [[NSArray alloc] initWithArray:subscriptions];    // 2
    // return subscriptions                                     // 3

}

- (NSMutableArray *)subscriptionGroupList
{
    NSError *error;
 
    NSDictionary *subscriptionDict = [NSJSONSerialization JSONObjectWithData:self options:kNilOptions error:&error];
    
    if (subscriptionDict == nil || error != nil) return nil;
    
    // get all subscriptions
    NSArray *allSubscriptions = [subscriptionDict objectForKey:@"subscriptions"];
    
    NSMutableArray *subscriptionsGroupArray = [[NSMutableArray alloc] initWithCapacity:[allSubscriptions count]];
    NSMutableDictionary *subscriptionGroupDict = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *sDict in allSubscriptions) {
        DDSubscription *s = [self getSubscriptionFromDict:sDict];

        if (s.categoriesId == nil) {
            [subscriptionsGroupArray addObject:[s subscriptionGroup]];
            continue;
        }
        /// subscription has label
        for (NSString * label in s.categoriesId) {
            NSMutableArray *subscriptionGroupDictValue = [subscriptionGroupDict objectForKey:label];
            if (subscriptionGroupDictValue == nil) {
                /// add label as key to dict, and subscription as value in dict
                subscriptionGroupDictValue = [[NSMutableArray alloc] initWithObjects:s, nil];
                [subscriptionGroupDict setObject:subscriptionGroupDictValue forKey:label];
            }
            else {
                /// add to value for key is label
                [subscriptionGroupDictValue addObject:s];
            }
        }
        	
    }
    
//    for (DDSubscription *subs in [[subscriptionGroupDict allValues] objectAtIndex:0]) {
//        NSLog(@"%@", subs.title);
//        NSLog(@"%@", subs.subscriptionId);
//        NSLog(@"%@", subs.categoriesId);
//    }

    // TODO: put dictionary to array and sort
    // add dict to return array
    for (NSString *label in [subscriptionGroupDict allKeys]) {
        DDSubscriptionGroup * subsGroup = [[DDSubscriptionGroup alloc] init];

        // categoriesId in DDSubcription class
        subsGroup.label = label;
        DLog(@"%@", label);
        subsGroup.groupedSubscriptions = [subscriptionGroupDict objectForKey:label];
        subsGroup.sType                 = [label getSubscriptionType];
        
        [subscriptionsGroupArray insertObject:subsGroup atIndex:0];

    }
    
    // TODO:1, 2 or 3???
    // currently i'm using 2, see:http://stackoverflow.com/questions/3749657/nsmutablearray-arraywitharray-vs-initwitharray
    // return [NSArray arrayWithArray:subscriptions];              // 1
    // return [[NSArray alloc] initWithArray:subscriptionsGroupArray];    // 2
    return subscriptionsGroupArray;                                     // 3


}

- (DDTagList *)tagList
{
    //-----------------------
    // { 
    //   - tags:[
    //       - {
    //            id : "user/10xxxxxx/state/com.google/starred
    //            sortid : "3E899AE4"
    //       },
    //       - {
    //       }
    //   ]
    // }
    NSError *error = nil;
    
    NSDictionary *tagListDict = [NSJSONSerialization JSONObjectWithData:self options:kNilOptions error:&error];
    
    if (tagListDict == nil || error != nil) return nil;
    
    // get all tag list elements
    NSArray *allTagList = [tagListDict objectForKey:@"tags"];
    
    NSMutableArray *tagListArray = [[NSMutableArray alloc] initWithCapacity:[allTagList count]];
  
    for (NSDictionary *tagDict in allTagList) {
        NSDictionary *d = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [tagDict objectForKey:@"id"], @"id",
                           [tagDict objectForKey:@"sortid"], @"sortid", nil];
        
        [tagListArray addObject:d];
    }
    
    DDTagList *result = [[DDTagList alloc] initWithTagListDictionaryArray:tagListArray];
    return result;
}

- (DDStreamPreference *)streamPreference
{
    //-----------------------
    // { 
    //   - streamprefs:{
    //       - user/10xxxx/label/Photography : [
    //          - { 
    //                id : "user/10xxxxxx/state/com.google/starred
    //                sortid : "3E899AE4"
    //            }
    //       ],
    //   ]
    // }
    NSError *error = nil;
    
    NSDictionary *streamPrefsDict = [NSJSONSerialization JSONObjectWithData:self options:kNilOptions error:&error];
    
    if (streamPrefsDict == nil || error != nil) return nil;
    
    NSDictionary *streamPrefsInnerDict = [streamPrefsDict objectForKey:@"streamprefs"];

    NSMutableDictionary *resultDict= [[NSMutableDictionary alloc] init];

    DDStreamPreference *result = [[DDStreamPreference alloc] init];
    
    for (NSString *streamId in streamPrefsInnerDict) {
        if ([streamId contains:@"/state/com.google/root"]) {
            NSArray *array = (NSArray *)[streamPrefsInnerDict objectForKey:streamId];
            NSString *orderingString = [(NSDictionary *)[array objectAtIndex:0] objectForKey:@"value"];
            // save 
            result.subscriptionOrderString = orderingString;
            continue;
        }
        NSString *ordering = [self getSubscriptionOrderingString:streamPrefsInnerDict forKey:streamId];
        [resultDict setObject:ordering forKey:streamId];
    }
    
    return result;
}

#pragma mark - private helper functions

- (NSString *)getSubscriptionOrderingString:(NSDictionary *)dict forKey:(NSString *)key
{
    NSArray *array = (NSArray *)[dict objectForKey:key];
    // if array[0].value = false, return
    NSDictionary *array0Dict = (NSDictionary *)[array objectAtIndex:0];
    if ([(NSString *)[array0Dict objectForKey:@"value"] isEqualToString:@"false"]) {
        return nil;
    }
    
    NSDictionary *array1Dict = (NSDictionary *)[array objectAtIndex:1];
    NSString *orderingString = [array1Dict objectForKey:@"value"];
    
    return orderingString;
    
}









@end
