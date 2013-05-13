//
//  MasterViewController.m
//  ReaderFlower
//
//  Created by dudu Shang on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

#import "DDLoginViewController.h"
#import "SubscriptionsViewController.h"

#import "DDGRDatabase.h"
#import "AppDelegate.h"
#import "DDGoogleReader.h"

// for test purpose
#import "JSONKit.h"
#import "NSData+DDFeedItem.h"



#if DD_DB_DEBUG
static DDGRDatabase * g_db = nil;
#endif

@interface MasterViewController()


- (void)t_subscriptionGroupList;
- (void)t_db_saveBatchItem;

- (void)t_db_create;
- (void)t_insert_subscription;
- (void)t_select_subscription_with_type;
- (void)t_db_save_subscription_group_list;
- (void)t_db_select_child_subscription;
- (void)t_db_select_continuation;

- (void)configureNavigationBar;


@end

@implementation MasterViewController


@synthesize detailViewController = _detailViewController;
@synthesize subscriptionViewController = _subscriptionViewController;

@synthesize auth = _auth;
@synthesize email = _email;
@synthesize password = _password;

@synthesize items = _items;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Master", @"Master");
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.clearsSelectionOnViewWillAppear = NO;
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        }
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Google Reader Delegate


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    //    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
    
    
    [self configureNavigationBar ];
    //[self t_subscriptionGroupList];

#if DD_DB_DEBUG

//    [self t_insert_subscription ];

    g_db = [[DDGRDatabase alloc] init];
    
    [self t_db_create];
//    [self t_db_saveBatchItem];
    

//    [self t_db_save_subscription_group_list];
//    [self t_select_subscription_with_type];
//    [self t_db_select_child_subscription];
  

#endif
    




#if DD_OFFLINE_DEBUG
    self.items = [[NSArray alloc] initWithObjects:@"Account", @"Subscriptions", nil];
#endif
  
    
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
    
    if (self.email == nil) {
        // show login in table
        [self showLoginView:nil];
    }
    else
    {
        self.items = [[NSArray alloc] initWithObjects:@"Account", @"Subscriptions", nil];
        
    }
  
    
//    [self showLoginView];
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
    
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    CGRect window_rect = appDelegate.window.bounds;
//    NSLog(@"width : %f height : %f", window_rect.size.width, window_rect.size.height);
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];

}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }

    // Configure the cell.
    //cell.textLabel.text = NSLocalizedString(@"Detail", @"Detail");

    cell.textLabel.text = [self.items objectAtIndex:indexPath.row    ];

    
    return cell;
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
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    if (!self.detailViewController) {
	        self.detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPhone" bundle:nil];
	    }

        [self.navigationController pushViewController:self.detailViewController animated:YES];
    }
    
    if (0 == indexPath.row) {
        DDLoginViewController  *loginVC = [[DDLoginViewController alloc] initWithNibName:@"DDLoginViewController" bundle:nil];

        NSLog(@"1. --  --- ----  %@", self.navigationController);

        NSLog(@"%@", [self.navigationController presentingViewController]);
        NSLog(@"%@", [self.navigationController presentedViewController]);
        NSLog(@"%@", self.navigationController.parentViewController);
        
        loginVC.delegate = self;
//        [self.navigationController presentModalViewController:loginVC animated:YES];
          [self.navigationController pushViewController:loginVC animated:YES]; 
    } else if(1 == indexPath.row) {
        SubscriptionsViewController *subscriptionVC = [[SubscriptionsViewController alloc] initWithNibName:@"SubscriptionsViewController" bundle:nil];
        subscriptionVC.retractableControllers = [[NSMutableArray alloc] init];
        [self.navigationController pushViewController:subscriptionVC animated:YES];
        
        
//        self.detailViewController.feedContent = @"<b>xin</b>";
//        [self.detailViewController reloadContent];
    }

   
}
#pragma mark - DDLoginDelegate
- (void)didFinishLogin:(DDGoogleReader *)reader status:(BOOL)status
{
    if (status == NO) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Reader Flower" message:@"Login in Error!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    self.email = reader.email;
    self.password = reader.password;
    self.auth = reader.auth;
    
    self.items = [[NSArray alloc] initWithObjects:@"Star", @"Subscriptions", nil];
    [self.tableView reloadData];

    
 
}

#pragma -
#pragma mark loginview

- (void)dismissMe:(DDLoginViewController *)modalViewController
{
    NSLog(@"%@", [modalViewController presentingViewController]);
    NSLog(@"%@", [modalViewController presentedViewController]);
    NSLog(@"%@", modalViewController.parentViewController);
    
    NSLog(@"%@", [modalViewController.parentViewController presentingViewController]);
    NSLog(@"%@", [modalViewController.parentViewController presentedViewController]);
    NSLog(@"%@", modalViewController.parentViewController.parentViewController);
  
    UINavigationController *parent = (UINavigationController *)modalViewController.parentViewController;
    [parent popViewControllerAnimated:YES];
//    [modalViewController.parentViewController dismissModalViewControllerAnimated:YES];
    
    if ([modalViewController respondsToSelector:@selector(presentingViewController)]) {
        NSLog(@"2. -- --- ----  %@", [modalViewController presentingViewController]);
        [[modalViewController presentingViewController] dismissModalViewControllerAnimated:YES];
    }
    else
    {
        [modalViewController.parentViewController dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - navigation bar
- (void)configureNavigationBar
{
    
//    self.navigationItem.rightBarButtonItem = [UIBarButtonItem alloc] initWithBarButtonSystemItem:///<#(UIBarButtonSystemItem)#> target:<#(id)#> action:<#(SEL)#>
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"account.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showLoginView:)];
    
    
    
}
#pragma mark - dudu test
- (void)t_subscriptionGroupList
{

    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"subscription_list_fianceeyi" ofType:@"txt"];
    
/*    
    NSDictionary *kitData = [content objectFromJSONData];
    
    NSArray *allKeys = [kitData allKeys];
    
    // output all keys
    NSLog(@"%@", allKeys);
    
    
    // get all items
    NSArray *allItems = [kitData objectForKey:@"items"];
    
    NSLog(@"how many items : %d", [allItems	count]);
    
    NSDictionary *item0 = [allItems objectAtIndex:0];
    
    // all keys for one item
    NSLog(@"%@", [item0 allKeys]);
    
    NSMutableArray *itemsWithTitle = [NSMutableArray arrayWithCapacity:[allItems count]];
    
    for (NSDictionary *item in allItems) {
        NSString *title = [item objectForKey:@"title"];
        [itemsWithTitle addObject:title];
    }
    
    
    NSLog(@"titles : %@", itemsWithTitle);
*/

}

- (void)showLoginView:(id)sender
{
    const CGFloat width = 480.0;
    const CGFloat height = 420.0;
    
    DDLoginViewController  *loginVC = [[DDLoginViewController alloc] initWithNibName:@"DDLoginViewController" bundle:nil];
    
    loginVC.delegate = self;
    loginVC.modalPresentationStyle = UIModalPresentationFormSheet;
    loginVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    CGRect frame = CGRectMake((1024 - width)*0.5, (768 - height)*0.5, width, height);

 //    [splitVC presentModalViewController:loginVC animated:YES];
//    [appDelegate.window.rootViewController presentModalViewController:loginVC animated:YES];
//    [[appDelegate masterViewController] presentModalViewController:loginVC animated:YES];
    
//    loginVC.view.superview.frame = frame;
//    loginVC.view.center = splitVC.view.center;
  
    [self.navigationController presentModalViewController:loginVC animated:YES];
    
    loginVC.view.superview.frame = frame;
 
    
}

- (void)t_db_create
{


#if DD_DB_DEBUG
    [g_db createTables];
    
//    [self t_db_saveBatchItem];
#endif
    
}

- (void)t_insert_subscription
{
    [DDGRDatabase t_insert_subscription];
}

- (void)t_db_saveBatchItem
{
#if DD_DB_DEBUG

    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"http%3A%2F%2Fwww.dbanotes.net%2Findex" ofType:@"data"];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"http%3A%2F%2Fwww.dbanotes.net%2Findex_only_4_feeds" ofType:@"data"];
    
    
    NSLog(@"batch item data path = %@", path);
    
    NSData *content = [NSData dataWithContentsOfFile:path];
    
    DDBatchFeedItems *batchFeedItems = [content batchFeedItems];
    
    DLog(@"%@", batchFeedItems);
    
    [g_db saveBatchFeedItemsToDB:batchFeedItems];
    
#endif
    
}

- (void)t_select_subscription_with_type
{
    [DDGRDatabase t_select_subscription_with_type];
}
- (void)t_db_select_continuation
{
    DDGRDatabase *db = [[DDGRDatabase alloc] init];
    if (![db openDB]) {
        DLog(@"Open DB error!");
        return;
    }
    NSString *feedURL = @"http://www.dbanotes.net/index.xml";

    [db saveContinuationByURL:feedURL withContinuation:@"XXXYYY12345"];

    NSString *c = [db getContinuationByURL:feedURL];

    DLog(@"%@", c);
}
- (void)t_db_select_child_subscription
{
    [DDGRDatabase t_select_child_subscription];
}
- (void)t_db_save_subscription_group_list
{
    NSArray *groupList = [SubscriptionsViewController getSubscriptionGroupListOffline];
    DDGRDatabase *db = [[DDGRDatabase alloc] init];
    if(![db openDB])
    {
        [db checkDBError];
        return;
    }
    
    [db saveSubscriptionGroupList:groupList];
    
    [db closeDB];
}



@end
