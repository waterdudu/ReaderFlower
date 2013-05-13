//
//  DDGRDatabase.h
//  ReaderFlower
//
//  Created by dudu tsang on 13-1-21.
//  Copyright (c) 2013年 MMM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FMDatabase.h"

@class DDBatchFeedItems;
@class FMDatabaseQueue;
//#import "DDGRDatabaseDelegate.h"
@protocol DDGRDatabaseDelegate;


@interface DDGRDatabase : NSObject

{
    __unsafe_unretained id<DDGRDatabaseDelegate> _delegate;
	FMDatabase *_db;
    FMDatabaseQueue *_queue;
}

@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, strong) FMDatabaseQueue *queue;

// @property (nonatomic, assign) id<DDGRDatabaseDelegate> delegate;
// see this:
//    http://stackoverflow.com/questions/8138902/existing-ivar-delegate-for-unsafe-unretained-property-delegate-must-be-un
@property (nonatomic, unsafe_unretained) id<DDGRDatabaseDelegate> delegate;  // this is OK


- (BOOL)createDatabase;
- (BOOL)createTables;

- (BOOL)openDB;
- (BOOL)closeDB;

- (void)checkDBError;

- (void)loadFeedsByURLFromDB:(NSString *)feedURL fromDate:(NSDate *)date numberOfItems:(int)numberOfItems;
- (void)saveBatchFeedItemsToDB:(DDBatchFeedItems *)batchFeedItem;
- (void)saveSubscriptionGroupList:(NSArray *)subscriptionGroupList;

- (void)saveUserToDB:(NSString *)email password:(NSString *)password;
- (BOOL)hasUserInDB:(NSString *)email;

- (NSMutableArray *)loadSubscriptionGroupList;
- (NSString *)getContinuationByURL:(NSString *)feedURL;
- (void)saveContinuationByURL:(NSString *)feedURL withContinuation:(NSString *)continuation;

///////////////////////////////////////////////////////////////////////////
///  save feeds from http response
// 
///  feeds:array of FeedItems
- (void)saveFeeds:(NSString *)feedURL feeds:(NSArray *)feeds;   //

+ (NSString *)getDBPath;

//////////////////        test         ///////////////////

+ (void)t_insert_subscription;
+ (void)t_insert_feed;
+ (void)t_select_subscription_with_type;
+ (void)t_select_child_subscription;
+ (NSMutableArray *)t_load_subscription_list;


@end




