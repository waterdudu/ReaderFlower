//
//  DDGoogleReaderDelegate.h
//  ReaderFlower
//
//  Created by dudu Shang on 1/21/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DDGoogleReader;
@class DDBatchFeedItems;

typedef enum {
    QuickAddFeedType = 0,
    DeleteFeedType,
    GetSubscriptionType,
    GetStarType,
    GetFeedType,        // api : content/stream ..
    GetList,    // TODO, rename it to indicate more meaning
    ChangeLabelType,
    RenameTagType,
    StarItemType,
    NoneType

} DDGRAPIType;


@protocol DDGoogleReaderDelegate

// no use
- (void)RequestDidFinished:(DDGoogleReader *)reader
                    status:(BOOL)status
                      type:(DDGRAPIType)type;


- (void)feedQuickAddDidFinished:(DDBatchFeedItems *)batchFeedItems error:(NSError *)error;
- (void)feedSubscriptionDidFinished:(DDBatchFeedItems *)batchFeedItems error:(NSError *)error;
- (void)subscriptionListDidFinished:(NSMutableArray *)subscriptionList error:(NSError *)error;

//- (void)feedQuickAddDidFinished:(NSArray *)feeds error:(NSError *)error;
//- (void)feedDeleteDidFinished:(DDGoogleReader *)reader error:(NSError *)error;

// all feeds from only one feed source
//- (void)feedSubscriptionDidFinished:(DDGoogleReader *)reader error:(NSError *)error;


- (void)starFeedsDidFinished:(DDGoogleReader *)reader error:(NSError *)error;

// 
// create the tree
- (void)allSubscriptionsDidFinished:(DDGoogleReader *)reader error:(NSError *)error;


- (void)changeLabelDidFinished:(DDGoogleReader *)reader error:(NSError *)error;
// TODO:
//      is labelName needed?
- (void)createLabelDidFinished:(DDGoogleReader *)reader error:(NSError *)error;

- (void)renameTagDidFinished:(DDGoogleReader *)reader error:(NSError *)error;
- (void)starItemDidFinished:(DDGoogleReader *)reader error:(NSError *)error;


/*

- (void)feedQuickAddDidFinished:(DDGoogleReader *)reader status:(BOOL)status;
- (void)feedDeleteDidFinished:(DDGoogleReader *)reader status:(BOOL)status;

// all feeds from only one feed source
- (void)feedSubscriptionDidFinished:(DDGoogleReader *)reader status:(BOOL)status;

- (void)starFeedsDidFinished:(DDGoogleReader *)reader status:(BOOL)status;

// 
// create the tree
- (void)allSubscriptionsDidFinished:(DDGoogleReader *)reader status:(BOOL)status;


- (void)changeLabelDidFinished:(DDGoogleReader *)reader status:(BOOL)status;
// TODO:
//      is labelName needed?
- (void)createLabelDidFinished:(DDGoogleReader *)reader status:(BOOL)status;

- (void)renameTagDidFinished:(DDGoogleReader *)reader status:(BOOL)status;
- (void)starItemDidFinished:(DDGoogleReader *)reader status:(BOOL)status;
*/



@end





