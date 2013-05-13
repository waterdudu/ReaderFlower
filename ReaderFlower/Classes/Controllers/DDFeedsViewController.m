//
//  DDFeedsViewController.m
//  ReaderFlower
//
//  Created by dudu Shang on 1/27/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "DDFeedsViewController.h"
#import "DDFeedItem.h"
#import "DDGoogleReader.h"
#import "DDGRDatabase.h"
#import "MasterViewController.h"
#import "DetailViewController.h"

#import "DDTableFooterView.h"
#import "DDTableHeaderView.h"

#import "NSData+DDFeedItem.h"

#import "AppDelegate.h"

@interface DDFeedsViewController()

- (DDBatchFeedItems *)t_get_star_batchfeeditems;
- (DDBatchFeedItems *)t_get_batchfeeditems;
- (DDBatchFeedItems *)t_get_batchfeeditems_songshuhui;


- (void)refreshLastUpdatedData;

// Private helper methods
- (void) addItemsOnTop;
- (void) addItemsOnBottom;
- (NSString *) createRandomValue;

- (void)configureHeaderFooterView;

@end

@implementation DDFeedsViewController

@synthesize batchFeedItems = _batchFeedItems;
@synthesize feedURL = _feedURL;
@synthesize auth = _auth;
//@synthesize subscription = _subscription;
@synthesize googleReader = _googleReader;
@synthesize feeds = _feeds;

- (void)configureHeaderFooterView
{
    
    [self initialize];
    self.title = self.title;
//    [self.tableView setBackgroundColor:[UIColor lightGrayColor]];
    
    // set the custom view for "pull to refresh". See DemoTableHeaderView.xib.
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DDTableHeaderView" owner:self options:nil];
    DDTableHeaderView *headerView = (DDTableHeaderView *)[nib objectAtIndex:0];
    self.headerView = headerView;
    
    // set the custom view for "load more". See DemoTableFooterView.xib.
    nib = [[NSBundle mainBundle] loadNibNamed:@"DDTableFooterView" owner:self options:nil];
    DDTableFooterView *footerView = (DDTableFooterView *)[nib objectAtIndex:0];
    self.footerView = footerView;
    
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - DDGoogleReader delegate
- (void)feedSubscriptionDidFinished:(DDBatchFeedItems *)batchFeedItems error:(NSError *)error
{
    //    self.batchFeedItems = batchFeedItems;
    //    [self.items insertObjects:batchFeedItems.items atIndexes:0];  // crash when items has no items
    //    [self.items addObjectsFromArray:batchFeedItems.items];        // this is OK
    if ([self.feeds count] > 0) {
        [self.feeds addObjectsFromArray:batchFeedItems.items];
    }
    else
    {
        // TODO:how to construct a NSMutableArray from another array ?
        self.feeds = [[NSMutableArray alloc] initWithArray:batchFeedItems.items];   
    }
    
    // dispatch save batch feed item to DB
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        DDGRDatabase *db = [[DDGRDatabase alloc] init];
        if ([db openDB]) {
            [db saveBatchFeedItemsToDB:batchFeedItems];
            
            //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            // save continuation to DB
            //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            // feed/XXX => XXX
            NSString *feedURL = [batchFeedItems.feedId substringFromIndex:5];
            [db saveContinuationByURL:feedURL withContinuation:batchFeedItems.continuation];
            DLog(@"continuation in delegate : %@", batchFeedItems.continuation);
            [db closeDB];
        }
    });
    
    [self.tableView reloadData];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // init data source
    self.feeds = [[NSMutableArray alloc] init];
    [self configureHeaderFooterView];
    
    if (DD_OFFLINE_DEBUG) {
        DDBatchFeedItems *batchFeedItems = nil;
        if (DD_GET_STAR_ITEMS) 
        {
            batchFeedItems = [self t_get_star_batchfeeditems];
        }
        else
        {
            batchFeedItems = [self t_get_batchfeeditems];
        }
        [self feedSubscriptionDidFinished:batchFeedItems error:nil];
        return;
    }
    self.googleReader = [[DDGoogleReader alloc] init];
    self.googleReader.delegate = self;
    self.googleReader.auth = self.auth;
    [self.googleReader getFeedsByURL:self.feedURL continuation:@"" numberOfContents:40];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
}


#pragma mark - google reader delegate


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)setFeeds:(NSMutableArray *)feeds
{
    _feeds = feeds;
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    DetailViewController *detailVC = (DetailViewController *)appDelegate.splitViewController.delegate;
    detailVC.feeds = feeds;

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

//    return [self.batchFeedItems.items count];
    return [self.feeds count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
//    DDFeedItem *item = [self.batchFeedItems.items objectAtIndex:indexPath.row];
    DDFeedItem *item = [self.feeds objectAtIndex:indexPath.row];
    cell.textLabel.text = item.title;
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"Nib name" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
/*
    UISplitViewController *splitVC = (UISplitViewController *)self.parentViewController.parentViewController;
//    DLog(@"%@", splitVC);
    UINavigationController *navVC = [splitVC.viewControllers objectAtIndex:1];
    DetailViewController *detailVC = [navVC.viewControllers objectAtIndex:0];
//    DetailViewController *detailVC = (DetailViewController *)splitVC.delegate;
//    NSAssert(detailVC != nil, @"detail View controller should not be nil");
 */
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    DetailViewController *detailVC = (DetailViewController *)[appDelegate.splitViewController delegate]; 
    if (detailVC == nil) {
        DLog(@"!!!!           detail view is nil        !!!!!");
    }


//    DDFeedItem *item =  [self.batchFeedItems.items objectAtIndex:indexPath.row];
    DDFeedItem *item = [self.feeds objectAtIndex:indexPath.row];
    detailVC.feedItem = item;
//    detailVC.feedContent = item.content == nil ? item.summary : item.content;
//    DLog(@"%@", detailVC.feedContent);

//    masterVC.detailViewController.feedContent = @"<p><b>abcd</b></p>";
    
    if(DD_WEBVIEW_CONTENT_RENDER) 
    {
        [detailVC reloadContentByWebView];
    }
    else
    {
//        [detailVC reloadContentByDTAttributedTextView];

//   version from my black apple
        [detailVC loadPageAt:indexPath.row];
	
//    version from vmware
//        [detailVC loadPageTextViewAt:indexPath.row];
//        [detailVC loadVisiblePages];
    }
    
    
    
    
}
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Pull to Refresh

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) pinHeaderView
{
    [super pinHeaderView];
    
    // do custom handling for the header view
    DDTableHeaderView *hv = (DDTableHeaderView *)self.headerView;
    [hv.activityIndicator startAnimating];
    hv.title.text = @"Loading...";
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) unpinHeaderView
{
    [super unpinHeaderView];
    
    // do custom handling for the header view
    [[(DDTableHeaderView *)self.headerView activityIndicator] stopAnimating];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Update the header text while the user is dragging
//
- (void) headerViewDidScroll:(BOOL)willRefreshOnRelease scrollView:(UIScrollView *)scrollView
{
    DDTableHeaderView *hv = (DDTableHeaderView *)self.headerView;
    [self refreshLastUpdatedData];
    if (willRefreshOnRelease)
        hv.title.text = @"Release to refresh...";
    else
        hv.title.text = @"Pull down to refresh...";
}

- (void)refreshLastUpdatedData
{
    NSDate *date = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setAMSymbol:@"AM"];
    [formatter setPMSymbol:@"PM"];
    [formatter setDateFormat:@"MM/dd/yyyy hh:mm:a"];
    DDTableHeaderView *hv = (DDTableHeaderView *)self.headerView;
    hv.lastUpdatedDate.text = [NSString stringWithFormat:@"Last Updated: %@", [formatter stringFromDate:date]];
    
}
////////////////////////////////////////////////////////////////////////////////////////////////////
//
// refresh the list. Do your async calls here.
//
- (BOOL) refresh
{
    if (![super refresh])
        return NO;
    [self refreshLastUpdatedData];
    // Do your async call here
    // This is just a dummy data loader:
    [self performSelector:@selector(addItemsOnTop) withObject:nil afterDelay:2.0];
    // See -addItemsOnTop for more info on how to finish loading
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Load More

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// The method -loadMore was called and will begin fetching data for the next page (more). 
// Do custom handling of -footerView if you need to.
//
- (void) willBeginLoadingMore
{
    DDTableFooterView *fv = (DDTableFooterView *)self.footerView;
    [fv.activityIndicator startAnimating];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Do UI handling after the "load more" process was completed. In this example, -footerView will
// show a "No more items to load" text.
//
- (void) loadMoreCompleted
{
    [super loadMoreCompleted];
    
    DDTableFooterView *fv = (DDTableFooterView *)self.footerView;
    [fv.activityIndicator stopAnimating];
    
    if (!self.canLoadMore) {
        // Do something if there are no more items to load
        
        // We can hide the footerView by: [self setFooterViewVisibility:NO];
        
        // Just show a textual info that there are no more items to load
        fv.infoLabel.hidden = NO;
        
        [self performSelector:@selector(hiddenFooterView) withObject:nil afterDelay:1.0];
    }
}

- (void)hiddenFooterView
{
    [self setFooterViewVisibility:NO];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) loadMore
{
    if (![super loadMore])
        return NO;
    
    // Do your async loading here
    [self performSelector:@selector(addItemsOnBottom) withObject:nil afterDelay:.2];
    // See -addItemsOnBottom for more info on what to do after loading more items
    
    return YES;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Dummy data methods 

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addItemsOnTop
{
    [self.tableView reloadData];
    
    // Call this to indicate that we have finished "refreshing".
    // This will then result in the headerView being unpinned (-unpinHeaderView will be called).
    [self refreshCompleted];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) addItemsOnBottom
{
    DDGRDatabase *db = [[DDGRDatabase alloc] init];
    if ([db openDB]) {
        NSString *continuation = [db getContinuationByURL:self.feedURL];
        NSLog(@"add items on bottom : %@", continuation);
        [db closeDB];
        [self.googleReader getFeedsByURL:self.feedURL continuation:continuation numberOfContents:40];
/*        
        DDBatchFeedItems *more_items = 
        [self feedSubscriptionDidFinished:more_items error:nil];
        [self.tableView reloadData];
        //  if (self.items.count > 50)
        self.canLoadMore = NO; // signal that there won't be any more items to load
        //  else
        self.canLoadMore = YES;
        
        // Inform STableViewController that we have finished loading more items
        [self loadMoreCompleted];
*/
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *) createRandomValue
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    return [NSString stringWithFormat:@"%@ %@", [dateFormatter stringFromDate:[NSDate date]],
            [NSNumber numberWithInt:rand()]];
}



#pragma mark -
#pragma mark test

- (DDBatchFeedItems *)t_get_star_batchfeeditems
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"star_items" ofType:@"txt"];
    
    NSLog(@"star batch item data path = %@", path);
    
    NSData *content = [NSData dataWithContentsOfFile:path];
    
    DDBatchFeedItems *batchFeedItems = [content batchFeedItems];
    
    return  batchFeedItems;
}

- (DDBatchFeedItems *)t_get_batchfeeditems
{
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"http%3A%2F%2Fwww.dbanotes.net%2Findex" ofType:@"data"];
 
    NSString *path = [[NSBundle mainBundle] pathForResource:@"http%3A%2F%2Fwww.dbanotes.net%2Findex_only_4_feeds" ofType:@"data"];
    
    NSLog(@"batch item data path = %@", path);
    
    NSData *content = [NSData dataWithContentsOfFile:path];
    
    DDBatchFeedItems *batchFeedItems = [content batchFeedItems];
    
//    DLog(@"%@", batchFeedItems);
    return  batchFeedItems;
}

- (DDBatchFeedItems *)t_get_batchfeeditems_songshuhui
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"songshuhui" ofType:@"data"];
    
    NSLog(@"batch item data path = %@", path);
    
    NSData *content = [NSData dataWithContentsOfFile:path];
    
    DDBatchFeedItems *batchFeedItems = [content batchFeedItems];
    
    //    DLog(@"%@", batchFeedItems);
    return  batchFeedItems;
    
    
}
@end
