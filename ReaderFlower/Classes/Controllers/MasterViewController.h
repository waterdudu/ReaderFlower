//
//  MasterViewController.h
//  ReaderFlower
//
//  Created by dudu Shang on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DDGoogleReaderDelegate.h"
#import "DDBatchFeedItems.h"
#import "SubscriptionsViewController.h"
#import "DDLoginViewController.h"

@class DetailViewController;



@interface MasterViewController : UITableViewController<DDLoginViewControllerDelegate>
{

}

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) SubscriptionsViewController *subscriptionViewController;
@property (strong, nonatomic) NSArray *items;

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *auth;


// UI part
- (void)showLoginView:(id)sender;

@end
