//
//  DDSubscriptionSectionController.m
//  ReaderFlower
//
//  Created by dudu tsang on 13-1-30.
//  Copyright (c) 2013年 MMM. All rights reserved.
//

#import "DDSubscriptionSectionController.h"
#import "DDSubscription.h"
#import "DDFeedsViewController.h"
#import "AppDelegate.h"
#import "MasterViewController.h"
#import "DTCoreTextConstants.h"

@interface DDSubscriptionSectionController()

- (void)showFeedView:(NSUInteger)row;

@end

@implementation DDSubscriptionSectionController

@synthesize title = _title;
@synthesize subscriptions = _subscriptions;
@synthesize hasChild = _hasChild;

-(BOOL)hasChild
{
    DDSubscription *subs = [self.subscriptions objectAtIndex:0];
    return subs.categoriesId == nil || [subs.categoriesId count] == 0 ? NO : YES;
}

- (id)initWithArray:(NSArray *)subscriptions viewController:(UIViewController *)givenViewController {
    if ((self = [super initWithViewController:givenViewController])) {
        self.subscriptions = subscriptions;
    }
    return self;
}


#pragma mark -
#pragma mark Subclass

- (NSUInteger)contentNumberOfRow {
    return [self.subscriptions count];
}

- (NSString *)titleContentForRow:(NSUInteger)row {
//    return [self.subscriptions objectAtIndex:row];
    DDSubscription *subs = [self.subscriptions objectAtIndex:row];
    return subs.title;
}

- (void)didSelectContentCellAtRow:(NSUInteger)row {
    
   
    /// push feed view
    DDFeedsViewController *feedsViewController = [[DDFeedsViewController alloc] initWithNibName:@"DDFeedsViewController" bundle:nil];
    
    DDSubscription *subs = [self.subscriptions objectAtIndex:[self.tableView indexPathForSelectedRow].row];

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    UINavigationController *navVC = [appDelegate.splitViewController.viewControllers objectAtIndex:0];
    MasterViewController *masterVC = [navVC.viewControllers objectAtIndex:0];
    
    NSString *feedsUrl = [subs.subscriptionId substringFromIndex:5];
    feedsViewController.feedURL = feedsUrl;
    feedsViewController.title = subs.title;
    feedsViewController.auth = masterVC.auth;
    
    [masterVC.navigationController pushViewController:feedsViewController animated:YES];
/* */
    
//    [self showFeedView:row];
/*
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self];
    [nav pushViewController:feedsViewController animated:YES];
*/
}

- (void)didSelectCellAtRow:(NSUInteger)row
{
    if (self.hasChild) {
        [super didSelectCellAtRow:row];
    }
    else
    {
       
        /// push feed view
        DDFeedsViewController *feedsViewController = [[DDFeedsViewController alloc] initWithNibName:@"DDFeedsViewController" bundle:nil];
        
        DDSubscription *subs = [self.subscriptions objectAtIndex:0];
        NSString *feedsUrl = [subs.subscriptionId substringFromIndex:5];
        feedsViewController.feedURL = feedsUrl;

        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//        DetailViewController *detailVC = (DetailViewController *)appDelegate.splitViewController.delegate;

        UINavigationController *navVC = [appDelegate.splitViewController.viewControllers objectAtIndex:0];
        MasterViewController *masterVC = [navVC.viewControllers objectAtIndex:0];

        feedsViewController.auth = masterVC.auth;

        [masterVC.navigationController pushViewController:feedsViewController animated:YES];
 /* */
//        [self showFeedView:row];
    }
}

#pragma mark - private methods
- (void)showFeedView:(NSUInteger)row
{
    /// push feed view
    DDFeedsViewController *feedsViewController = [[DDFeedsViewController alloc] initWithNibName:@"DDFeedsViewController" bundle:nil];
    
    DDSubscription *subs = [self.subscriptions objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    NSString *feedsUrl = [subs.subscriptionId substringFromIndex:5];
    feedsViewController.feedURL = feedsUrl;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    UINavigationController *navVC = [appDelegate.splitViewController.viewControllers objectAtIndex:0];
    MasterViewController *masterVC = [navVC.viewControllers objectAtIndex:0];
    
    feedsViewController.auth = masterVC.auth;
    
    [masterVC.navigationController pushViewController:feedsViewController animated:YES];

}




@end
