//
//  DDGRDatabaseDelegate.h
//  ReaderFlower
//
//  Created by dudu tsang on 13-1-21.
//  Copyright (c) 2013年 MMM. All rights reserved.
//


#import <Foundation/Foundation.h>



@protocol DDGRDatabaseDelegate

///////////////////////////////////////////////////////////////////////////////////
///         get feeds from JSON string converted by http response,
///         controller class can update UI, i.e. the tableview
///////////////////////////////////////////////////////////////////////////////////

- (void)saveFeedsDidFinished:(NSString *)aJSONFeedString status:(BOOL)status;

/// depracated
- (void)loadFeedsDidFinished:(NSString *)feedURL    // feed URL
                       feeds:(NSArray *)feeds       // return feeds from DB
               numberOfItems:(int)numberOfItems     // number of return feeds (TODO: needed?)
                      status:(BOOL)status;


- (void)loadFeedsByURLDidFinished:(NSString *)feedURL
                            feeds:(NSArray *)feeds
                           status:(BOOL)status;


- (void)feedSubscriptionDidLoaded:(DDBatchFeedItems *)batchFeedItems error:(NSError *)error;






@end