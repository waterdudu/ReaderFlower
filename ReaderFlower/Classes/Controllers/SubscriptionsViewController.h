//
//  SubscriptionsViewController.h
//  ReaderFlower
//
//  Created by dudu Shang on 1/28/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DDGoogleReaderDelegate.h"
#import "DDBatchFeedItems.h"

@interface SubscriptionsViewController : UITableViewController<DDGoogleReaderDelegate>
{
    NSMutableArray *_subscriptionGroupList;
}

@property (strong, nonatomic) NSString *auth;
@property (strong, nonatomic) DDBatchFeedItems *batchFeedItems;
@property (strong, nonatomic) NSMutableArray *subscriptionGroupList;

@property (nonatomic, strong) NSMutableArray *retractableControllers;
@property (nonatomic, strong) NSMutableArray *rFuck;


//    test
+ (NSMutableArray *)getSubscriptionGroupListOffline;

@end
