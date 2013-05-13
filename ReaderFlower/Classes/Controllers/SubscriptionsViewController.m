//
//  SubscriptionsViewController.m
//  ReaderFlower
//
//  Created by dudu Shang on 1/28/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "SubscriptionsViewController.h"
#import "MasterViewController.h"

#import "DDFeedsViewController.h"
#import "AppDelegate.h"

#import "DDGoogleReader.h"

#import "JSONKit.h"
#import "DDGRDatabase.h"
#import "DDBatchFeedItems.h"
#import "DDFeedItem.h"
#import "DDSubscription.h"
#import "DDSubscriptionGroup.h"

#import "NSData+DDFeedItem.h"
#import "DDLoginViewController.h"
#import "DDSubscriptionSectionController.h"
#import "NSString+DDGoogleReader.h"

#import "DDGRDatabase.h"
#import "FMDatabase.h"



@interface SubscriptionsViewController()

- (void)refreshSubscriptionGroupList;

// offline debug

 
@end

@implementation SubscriptionsViewController

@synthesize batchFeedItems = _batchFeedItems;
@synthesize subscriptionGroupList = _subscriptionGroupList;
@synthesize auth = _auth;


@synthesize retractableControllers = _retractableControllers;

@synthesize rFuck = _rFuck;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    _retractableControllers = [[NSMutableArray alloc] initWithCapacity:200];
    self.retractableControllers = [[NSMutableArray alloc] init];
    
    self.rFuck = [[NSMutableArray alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //  LOAD subscription group list from file
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if (DD_OFFLINE_DEBUG == 1) {
        [self subscriptionListDidFinished:nil error:nil];
        return;
    }

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    MasterViewController *masterVC = [appDelegate masterViewController];
    //[masterVC showLoginView];
    if (!masterVC.email) {
        [masterVC showLoginView:nil];
        return;
    }

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //  LOAD subscription group list from DB
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    DDGRDatabase *db = [[DDGRDatabase alloc] init];
    self.subscriptionGroupList = [db loadSubscriptionGroupList];
    if ([self.subscriptionGroupList count] == 0) {
        // call [reader getSubscriptionList] => self.subscriptionGroupList
        
        DLog(@" get nothing about scription from DB");
        
    }
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //  call dipatch_async to refresh subscription group list
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    [self refreshSubscriptionGroupList];
    
   
}


- (void)subscriptionListDidFinished:(NSMutableArray *)subscriptionList error:(NSError *)error
{
    if (DD_OFFLINE_DEBUG == 1) {
        self.subscriptionGroupList = [SubscriptionsViewController getSubscriptionGroupListOffline];
    }
    else
        self.subscriptionGroupList = subscriptionList;
    
    // debug output
    NSLog(@"------     %@     -------", [self.retractableControllers count]);
    
    // init retractable controllers
    //self.retractableControllers = [NSMutableArray arrayWithCapacity:[self.subscriptionList count]];
    
    // fill retraxtable controllers with Subscription Group

    for (DDSubscriptionGroup *subsGroup in self.subscriptionGroupList) {

        DDSubscriptionSectionController *sc = [[DDSubscriptionSectionController alloc] initWithArray:subsGroup.groupedSubscriptions viewController:self];
        
        // TODO:change /use/xxx/label => label
//        sc.title = subsGroup.label;
        sc.title = [subsGroup.label getLabelContentFromCategoriesId];
        
//        [self.retractableControllers addObject:sc];
        [self.rFuck addObject:sc];
        
    }
    
    // dispatch save batch feed item to DB
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        DDGRDatabase *db = [[DDGRDatabase alloc] init];
        if ([db openDB]) {
            [db saveSubscriptionGroupList:subscriptionList];
          
            [db closeDB];
        }
    });
    
    [self.tableView reloadData];
}
- (void)feedSubscriptionDidFinished:(DDBatchFeedItems *)batchFeedItems error:(NSError *)error
{
    NSLog(@"%@", batchFeedItems.items);
    
}
- (void)feedQuickAddDidFinished:(DDBatchFeedItems *)batchFeedItems error:(NSError *)error
{
    NSLog(@"%@", batchFeedItems.items);
    self.batchFeedItems = batchFeedItems;
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    NSLog(@"%@", [self.retractableControllers count]);
//    return [self.retractableControllers count];
    return [self.rFuck count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return [self.subscriptionList count];
//    DDSubscriptionGroup * subsGroup = [self.subscriptionList objectAtIndex:section];
//    return [[subsGroup groupedSubscriptions] count];
    

    //    GCRetractableSectionController *sc = [self.retractableControllers objectAtIndex:section];
    GCRetractableSectionController *sc = [self.rFuck objectAtIndex:section];
    
    return sc.numberOfRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
/*
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    DDSubscription *subscription = [self.subscriptionList objectAtIndex:indexPath.row];
    cell.textLabel.text = subscription.title;   
    
    return cell;
*/
    
    //    GCRetractableSectionController *sc = [self.retractableControllers objectAtIndex:indexPath.section];
    GCRetractableSectionController *sc = [self.rFuck objectAtIndex:indexPath.section];
    return [sc cellForRow:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    GCRetractableSectionController* sectionController = [self.retractableControllers objectAtIndex:indexPath.section];
    GCRetractableSectionController* sectionController = [self.rFuck objectAtIndex:indexPath.section];
    DLog(@"indexPath section : %d, row : %d", indexPath.section, indexPath.row);
    
    return [sectionController didSelectCellAtRow:indexPath.row];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate



/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.

     DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"Nib name" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];

    
    
    DDFeedsViewController *feedsViewController = [[DDFeedsViewController alloc] initWithNibName:@"DDFeedsViewController" bundle:nil];
    
    DDSubscription *subs = [self.subscriptionList objectAtIndex:indexPath.row];
    NSString *feedsUrl = [subs.subscriptionId substringFromIndex:5];
    feedsViewController.feedURL = feedsUrl;
    DLog(@"%@", self.auth);
    feedsViewController.auth = self.auth;
    
    [self.navigationController pushViewController:feedsViewController animated:YES];  
}
*/
#pragma mark - google reader(subscription)

- (void)refreshSubscriptionGroupList
{
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // to get subscription group list, only auth string is needed
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    DDGoogleReader *reader = [[DDGoogleReader alloc] init];
    BOOL status = false;
    
    // TODO:check this code
    UINavigationController *navVC = (UINavigationController *)self.parentViewController;
    
    MasterViewController *masterVC = [navVC.viewControllers objectAtIndex:0];
    
    if (masterVC.email == nil) {
        // TODO:notice the user to login
        return;
    }
    /*
    status = [reader signInByEmail:masterVC.email password:masterVC.password];
    if (status) {
        NSLog(@"Login OK");
        NSLog(@"auth = %@, SID = %@", reader.auth, reader.sid);
        self.auth = reader.auth;
    }
    */
    reader.auth = masterVC.auth;
    reader.delegate = self;
    
    
    // [reader getFeedsByURL:@"http://blog.sina.com.cn/rss/1191258123.xml" continuation:@"CJbTyY6a6acC" numberOfContents:40];
    [reader getSubscriptionList];

}

#pragma mark -
#pragma mark - offline debug

+ (NSArray *)getSubscriptionGroupListOffline
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"subscription_list_fianceeyi_resaved" ofType:@"json"];
    
    NSLog(@"data path = %@", path);
    
    NSData *content = [NSData dataWithContentsOfFile:path];
    
    NSMutableArray *array = nil;
    if (DD_LOAD_SUBSCRIPTION_FROM_DB) {
        array = [DDGRDatabase t_load_subscription_list];
    }
    else
    {
        array = [content subscriptionGroupList];        
    }
    
    return array;
}

#pragma mark - test

@end
