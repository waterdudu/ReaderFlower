//
//  DDGRDatabase.m
//  ReaderFlower
//
//  Created by dudu tsang on 13-1-21.
//  Copyright (c) 2013年 MMM. All rights reserved.
//

#import "DDGRDatabase.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

#import "DDFeedItem.h"
#import "DDSubscription.h"

#import "DDBatchFeedItems.h"
#import "DDGRDBDefines.h"
#import "DDSubscription.h"
#import "DDSubscriptionGroup.h"

#import "NSString+DDGoogleReader.h"
#import "DDSubscription+DDSubscriptionGroup.h"

#define kDBName @"/_0_._0_"

@interface DDGRDatabase()

- (BOOL)openDB;
- (BOOL)closeDB;
+ (NSString *)getDBPath;

// create tables
- (void)createFeedItemTable;
- (void)createFeedContentTable;
- (void)createSubscriptionTable;
- (void)createUserTable;
- (void)createSubscriptionRelationTable;

// insert operations
- (void)insertIntoContent:(int)itemPK content:(NSString *)realContent;
- (void)insertIntoItem:(DDFeedItem *)item;
- (void)insertIntoSubscription:(DDSubscription *)subscription;
- (void)insertIntoSubscriptionRelation:(NSString *)groupLabel 
                        subscriptionId:(NSString *)subscriptinId;

// select operations
- (NSArray *)selectSubscriptionWithType:(DDSubscriptionType)type;
- (NSArray *)selectChildSubscriptions:(int)parentPK;
- (NSArray *)selectSubscriptionsNoLabel;
- (NSString *)selectRealContentByItemPK:(int)pk;

// aux
- (int)getPKByItemId:(NSString *)itemId;
- (void)checkDBError;
// return NSArray of subscriptions
+ (NSArray *)resultSet2Subscription:(FMResultSet*)resultSet;


@end

@implementation DDGRDatabase

@synthesize delegate = _delegate;
@synthesize db = _db;
@synthesize queue = _queue;

#pragma mark - private


- (BOOL)openDB
{
//    self.db = [[FMDatabase alloc] initWithPath:[self getDBPath]];
    self.db = [FMDatabase databaseWithPath:[DDGRDatabase getDBPath]];
    DLog(@"%@", [DDGRDatabase getDBPath]);
    
    if (![self.db open]) {
        NSLog(@"Could not open db");
        return NO;
    }
    return YES;
}

- (BOOL)closeDB
{
    return [self.db close];
}

+ (NSString *)getDBPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];

    return [documentDirectory stringByAppendingFormat:kDBName];
}


- (BOOL)createDatabase
{
    FMDatabase *db = [[FMDatabase alloc] initWithPath:[DDGRDatabase getDBPath]];

    if (![db open]) {
        [self checkDBError];
        return NO;
        // TODO:
        //   what should I do in ARC project, if I cannot call [obj release]?
//        [db release];
    }
    return [db close];
}

#pragma mark - feeds & subscription & User

- (void)saveUserToDB:(NSString *)email password:(NSString *)password
{
    [self.db executeUpdate:kInsertUserSQL, email, password];
    [self checkDBError];
}
- (BOOL)hasUserInDB:(NSString *)email
{
    FMResultSet *rs = [self.db executeQuery:kSelectUserByEmail, email];
    while ([rs next]) {
        return YES;
    }
    return NO;
}
- (NSString *)getContinuationByURL:(NSString *)feedURL
{
//    if (!self.db || [self openDB] == NO)  return nil;
    
    // TODO:use FMDatabaseQueue
    // select
    NSString *subscriptionId = [NSString stringWithFormat:@"feed/%@", feedURL];
    DLog(@"--subscriptionID-- : %@", subscriptionId);
    FMResultSet *rs = [self.db executeQuery:kSelectContinuation, subscriptionId];
    [self checkDBError];
    NSString *continuation = nil;
    while ([rs next]) {
        continuation = [rs stringForColumn:@"continuation"];
        break;
    }
    
    return continuation;
}
- (void)saveContinuationByURL:(NSString *)feedURL withContinuation:(NSString *)continuation
{
    if (continuation == nil || [continuation length] <= 0) return;
    
    NSString *subscriptionId = [NSString stringWithFormat:@"feed/%@", feedURL];
    [self.db beginTransaction];
    [self.db executeUpdate:kSetContinuation, continuation, subscriptionId];
    [self checkDBError];
    [self.db commit];
}
- (void)saveBatchFeedItemsToDB:(DDBatchFeedItems *)batchFeedItem
{
    // TODO:dispatch_async. (dudu:call async outside)
    
    // TODO!!!:using disptch_queue in FMDatabase(FMDatabaseQueue)

    NSArray *items = batchFeedItem.items;

//    [self.db beginTransaction];  
    for (DDFeedItem *item in items) {
        // excute insert
        [self insertIntoItem:item];
    }
//    [self.db commit];
    
}

- (void)saveSubscriptionGroupList:(NSArray *)subscriptionGroupList
{
    // subscriptin Group List
    // NSArray:
    // +------------------------+     +---------------------------+
    // | DDSubscriptionGroup    | --> | label                     | 
    // +------------------------+     |    groupedSubscriptions   |
    // |                        |     |  +----------------------+ |
    // +------------------------+     |  |  DDSubscription      | |
    // |                        |     |  +----------------------+ |
    // |                        |     |  |                      | |
    // |         ...            |     |  +----------------------+ |
    // |                        |     |  |                      | |
    // +------------------------+     |  |        ...           | |
    // |                        |     |  |                      | |
    // |                        |     |  +----------------------+ |
    // |                        |     +---------------------------+
    // |                        |
    // |                        |
    // |                        |
    // |                        |
    // +------------------------+
    //
    // label: (A OR B)
    //      A) /user/16940643....38/label/x  (grouped)
    //      B) subscription's title          (non grouped)
    // 
    for (DDSubscriptionGroup *sGroup in subscriptionGroupList) {
        ///////////////////////////////////////////////////////////////////////
        //      1) insert label into subscription table
        ///////////////////////////////////////////////////////////////////////
        DDSubscription *groupSubs = [[DDSubscription alloc] init];
        groupSubs.subscriptionId  = sGroup.label;
        groupSubs.title           = [sGroup.label getLabelContentFromCategoriesId];
        groupSubs.sType           = sGroup.sType;
        
        if (!sGroup.alone) 
            [self insertIntoSubscription:groupSubs];

        ///////////////////////////////////////////////////////////////////////
        //      2) insert subscriptions in this group into subscription table
        ///////////////////////////////////////////////////////////////////////
        for (DDSubscription *s in sGroup.groupedSubscriptions) {
            [self insertIntoSubscription:s];
            
            // 3) goes from here
            [self insertIntoSubscriptionRelation:groupSubs.subscriptionId subscriptionId:s.subscriptionId];
        }
        ///////////////////////////////////////////////////////////////////////
        //      3) insert into subscription relation table
        ///////////////////////////////////////////////////////////////////////
        //      see step 2)
        
    }
}
- (void)saveFeeds:(NSString *)feedURL feeds:(NSArray *)feeds
{
    for (DDFeedItem *item in feeds) {
        // save all feeds to DB
        
    }
}
- (void)loadFeedsByURLFromDB:(NSString *)feedURL fromDate:(NSDate *)date numberOfItems:(int)numberOfItems
{
    
}
- (NSMutableArray *)loadSubscriptionGroupList
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    ////////////////////////////////////////////////////////////////
    //         1) load subscriptin with label
    ////////////////////////////////////////////////////////////////
    NSArray *labeled_subscriptions = [self selectSubscriptionWithType:DDSubscriptionLabel];
    for (DDSubscription *s in labeled_subscriptions) {
        NSArray *child_subscriptions = [self selectChildSubscriptions:s.pk];
        DDSubscriptionGroup *group = [[DDSubscriptionGroup alloc] init];
        group.label                = s.subscriptionId;
        group.groupedSubscriptions = [NSArray arrayWithArray:child_subscriptions];
        
        // add to result
        [result addObject:group];
    }
    ////////////////////////////////////////////////////////////////
    //         2) load subscription with***OUT*** label
    ////////////////////////////////////////////////////////////////
    //    NSArray *subscription_no_label = [self selectSubscriptionWithType:DDSubscriptionFeed];
    NSArray *subscription_no_label = [self selectSubscriptionsNoLabel];
    for (DDSubscription *s in subscription_no_label) {
        DDSubscriptionGroup *group = [s subscriptionGroup];
        
        // add to result
        [result addObject:group];
    }
    
    return result;
}


#pragma mark - insert

- (void)insertIntoSubscription:(DDSubscription *)subscription
{
    

//    [self.db beginTransaction];
    NSData *data_categoriesId = [NSKeyedArchiver archivedDataWithRootObject:subscription.categoriesId];
    NSData *data_categoriesLabel = [NSKeyedArchiver archivedDataWithRootObject:subscription.categoriesLabel];
    
    [self.db executeUpdate:kInsertSubscriptionSQL
                ,subscription.subscriptionId
                ,subscription.title
                ,subscription.firstitemmsec
                ,subscription.sortid
                ,subscription.htmlUrl
//                ,subscription.categoriesId, subscription.categoriesLabel
                ,data_categoriesId, data_categoriesLabel
                ,subscription.unreadcount, subscription.continuation, subscription.faviconLink
                ,[NSNumber numberWithInt:subscription.sType]
     ];
    

    [self checkDBError];
    
//    [self.db commit];
}
- (void)insertIntoContent:(int)itemPK content:(NSString *)realContent
{
    [self.db executeUpdate:kInsertContent, [NSNumber numberWithInt:itemPK], realContent];
    [self checkDBError];
}
- (void)insertIntoItem:(DDFeedItem *)item
{
                             
    [self.db beginTransaction];
//    [self insertIntoContent:item.content];

    [self.db executeUpdate:kInsertItemSQL, item.itemId, item.crawlTime, item.title, item.author,
                                item.alternateHref, item.originTitle, item.originStreamId, item.published, item.updated,
                                item.shortSummary,   // DONE:use part of content as summary
                                item.isRead, item.isStar, item.isLiked, item.isShared, item.likeCount];
    [self checkDBError];
    // insert into content
    int pk = [self getPKByItemId:item.itemId];
    [self.db executeUpdate:kInsertContent, [NSNumber numberWithInt:pk], item.realContent];
    [self checkDBError];
    [self.db commit];
 }

- (void)insertIntoSubscriptionRelation:(NSString *)groupLabel subscriptionId:(NSString *)subscriptinId
{
    [self.db executeUpdate:kInsertSubSubSQL, groupLabel, subscriptinId];
    [self checkDBError];
}

#pragma mark - select

- (NSArray *)selectSubscriptionWithType:(DDSubscriptionType)type
{
    FMResultSet *rs = [self.db executeQuery:kSelectSubscriptionWithType, [NSNumber numberWithInt:type]];
    NSArray *result = [DDGRDatabase resultSet2Subscription:rs];
    return result;  // TODO: do i need to call [NSArray arrayWithArray:result] ???
}

- (NSArray *)selectChildSubscriptions:(int)parentPK
{
    FMResultSet *rs = [self.db executeQuery:kSelectChildSubscriptions, [NSNumber numberWithInt:parentPK]];
    NSArray *result = [DDGRDatabase resultSet2Subscription:rs];
    return result;  // TODO: do i need to call [NSArray arrayWithArray:result] ???
}

- (NSArray *)selectSubscriptionsNoLabel
{
    FMResultSet *rs = [self.db executeQuery:kSelectSubscriptionsNoLabel];
    NSArray *result = [DDGRDatabase resultSet2Subscription:rs];
    return result;  // TODO: do i need to call [NSArray arrayWithArray:result] ???
}

- (NSString *)selectRealContentByItemPK:(int)pk
{
    FMResultSet *rs = [self.db executeQuery:kSelectRealContentByItemPK, [NSNumber numberWithInt:pk]];
    NSString *realContent = nil;
    while ([rs next]) {
        realContent = [rs stringForColumn:@"real_content"];
        break;
    }
    return realContent;
}


#pragma mark -
#pragma mark dealloc
- (void)dealloc
{
    [self closeDB];
}

#pragma mark - db create
- (BOOL)createTables
{
    if(![self openDB])
    {
        DLog(@"%@", @"open db error!");
        return NO;
    }

    
//    [self.db beginTransaction];
    
    [self createFeedItemTable];
    [self createFeedContentTable];
    [self createSubscriptionTable];
    [self createUserTable];
    [self createSubscriptionRelationTable];
    
    return YES;
//    [self.db commit];
}

- (void)createFeedItemTable
{
    //////////////////////////////////////////////////////////////
    //     do NOT use executeQuery when creating table,
    //     it has no effect
    //////////////////////////////////////////////////////////////

    //    [self.db executeQuery:kCreateItemTable];
    [self.db executeUpdate:kCreateItemTable];
    [self checkDBError];
}


- (void)createFeedContentTable
{
    [self.db executeUpdate:kCreateContentTable];
    [self checkDBError];
}

- (void)createSubscriptionTable
{
    [self.db executeUpdate:kCreateSubscriptionTable];
    [self checkDBError];
}

- (void)createUserTable
{
    [self.db executeUpdate:kCreateUserTable];
    [self checkDBError];
}
- (void)createSubscriptionRelationTable
{
    [self.db executeUpdate:kCreateSubscriptionRelationTable];
    [self checkDBError];
}

#pragma mark - aux functions
- (void)checkDBError
{
    if ([self.db hadError]) {
        DLog(@"Err %d: %@", [self.db lastErrorCode], [self.db lastErrorMessage]);
    }
    else
    {
        DLog(@"insert OK");
    }
}

- (int)getPKByItemId:(NSString *)itemId
{
    FMResultSet *rs = [self.db executeQuery:kSelectItemPKByItemId, itemId];
    [self checkDBError];
    int pk = -1;
    while ([rs next]) {
        pk = [rs intForColumn:@"pk"];
        break;
    }
    return pk;
}
+ (NSArray *)resultSet2Subscription:(FMResultSet *)resultSet
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    int subscription_pk   = -1;
    int pk                = -1;
    while ([resultSet next]) {
        DDSubscription *s = [[DDSubscription alloc] init];
        subscription_pk   = [resultSet intForColumn:@"subscription_pk"];
        pk                = [resultSet intForColumn:@"pk"];
        
        s.pk              = 0 == subscription_pk ? pk : subscription_pk;
        DLog(@"%d", s.pk);
        s.subscriptionId  = [resultSet stringForColumn:@"subscriptionId"];
        s.title           = [resultSet stringForColumn:@"title"];
        s.sortid          = [resultSet stringForColumn:@"sortId"];
        s.firstitemmsec   = [resultSet stringForColumn:@"firstitemmsec"];
        s.htmlUrl         = [resultSet stringForColumn:@"htmlUrl"];
        
        s.unreadcount     = [resultSet intForColumn:@"unreadcount"];
        s.continuation    = [resultSet stringForColumn:@"continuation"];
        s.faviconLink     = [resultSet stringForColumn:@"faviconLink"];
        
        s.sType           = [resultSet intForColumn:@"stype"];
        
        NSArray *array_id = [NSKeyedUnarchiver unarchiveObjectWithData:[resultSet dataForColumn:@"categoriesId"]];
        NSArray *array_label = [NSKeyedUnarchiver unarchiveObjectWithData:[resultSet dataForColumn:@"categoriesLabel"]];
        
        s.categoriesId    = array_id;
        s.categoriesLabel = array_label;
        
        [result addObject:s];
    }
    return result;
}



#pragma mark - test
+ (void)t_insert_subscription
{
    
    FMDatabase *db = [FMDatabase databaseWithPath:[DDGRDatabase getDBPath]];
    
    if (![db open]) {
        NSLog(@"Could not open db");
        return;
    }

//    [db beginTransaction];
    
    [db executeUpdate:kInsertSubscriptionSQL, @"subscriptionId", @"title", @"firstitemmsec",@"sortid",
     @"htmlUrl",
     nil, nil,
     0, @"continuation", @"faviconLink", [NSNumber numberWithInt:2]];
     
 
    if ([db hadError]) {
        DLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    else
    {
        DLog(@"insert OK");
    }
    
    
//    [db commit];
    [db close];

}

+ (void)t_select_subscription_with_type
{
    DDGRDatabase *db = [[DDGRDatabase alloc] init];
    if (![db openDB]) {
        DLog(@"Error open DB");
        return;
    }
    
    NSArray *feeds_subscriptions = [db selectSubscriptionWithType:DDSubscriptionFeed];
    DLog(@"%@", feeds_subscriptions);
    
}

+ (void)t_select_child_subscription
{
    DDGRDatabase *db = [[DDGRDatabase alloc] init];
    if (![db openDB]) {
        DLog(@"Error open DB");
        return;
    }
    NSArray *child_subscriptins = [db selectChildSubscriptions:12];
    DLog(@"%@", child_subscriptins);

}

+ (NSMutableArray *)t_load_subscription_list
{
    DDGRDatabase *db = [[DDGRDatabase alloc] init];
    if (![db openDB]) {
        DLog(@"Error open DB");
        return nil;
    }
    NSMutableArray *subscriptionGroupList = [db loadSubscriptionGroupList];
    DLog(@"%@", subscriptionGroupList);
    return subscriptionGroupList;
}








@end
