//
//  DDFeedsViewController.h
//  ReaderFlower
//
//  Created by dudu Shang on 1/27/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "STableViewController.h"
#import "DDBatchFeedItems.h"
#import "DDSubscription.h"
#import "DDGoogleReaderDelegate.h"

@class DDGoogleReader;
//@interface DDFeedsViewController : UITableViewController <DDGoogleReaderDelegate>
@interface DDFeedsViewController : STableViewController <DDGoogleReaderDelegate>




@property (strong, nonatomic) DDBatchFeedItems *batchFeedItems;
// no need to pass subscription, only feedURL and title is OK
// @property (strong, nonatomic) DDSubscription *subscription;  
@property (strong, nonatomic) NSString *feedURL;
@property (strong, nonatomic) NSString *auth;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) DDGoogleReader *googleReader;


@property (strong, nonatomic) NSMutableArray *feeds;

@end
