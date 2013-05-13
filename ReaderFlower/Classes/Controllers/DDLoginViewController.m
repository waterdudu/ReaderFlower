//
//  DDLoginViewController.m
//  ReaderFlower
//
//  Created by dudu Shang on 1/28/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "DDLoginViewController.h"
#import "DDGoogleReader.h"
#import "MasterViewController.h"
#import "DDGRDatabase.h"
#import "AppDelegate.h"

@implementation DDLoginViewController
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
#pragma mark - login
- (void)signIn:(id)sender
{
    // TODO:check if two UITextField is null
    DDGoogleReader *gr = [[DDGoogleReader alloc] init];
    gr.email = email.text;
    gr.password = password.text;
  
    BOOL signInStatus = NO;
#if DD_DONOT_LOGIN_USE_EXIST_AUTH
    signInStatus = YES;
    gr.auth =@"PLEASE PUT YOUR AUTH STRING HERE, BEGIN WITH DQAAA...";// @"DQAAAL";
    DLog(@"Using auth.");
#else
    signInStatus = [gr signIn];
#endif
    

//    BOOL signInStatus = [gr signInByEmail:myEmail password:myPasswd];
    // signInStatus = YES;
    if (signInStatus) {
        /// 1. pass username & password & auth to MasterViewController
        /// 2. navigate to subscription
              // save user & email to db
        DDGRDatabase *db = [[DDGRDatabase alloc] init];
        if (![db openDB])
        {
            // TODO:handler open error
        }
        [db saveUserToDB:email.text password:password.text];

        [self dismissMe:nil];
        
        // TODO:use delegate
        
        if (self.delegate) {
            [self.delegate didFinishLogin:gr status:YES];
        }
        
        
    }
    else
    {
        
        /// TODO:alertview
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Reader Flower" message:@"Login in failed!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        
        if (self.delegate) {
            [self.delegate didFinishLogin:nil status:NO];
        }
    }
    
    /*
    UISplitViewController *splitVC = self.parentViewController.parentViewController;
    
    UINavigationController *navVC = [splitVC.viewControllers objectAtIndex:1];
    DetailViewController *detailVC = [navVC.viewControllers objectAtIndex:0];
    DDFeedItem *item =  [self.batchFeedItems.items objectAtIndex:indexPath.row];
    
    detailVC.feedContent = item.content == nil ? item.summary : item.content;
    
    //    masterVC.detailViewController.feedContent = @"<p><b>abcd</b></p>";
    
     */

}

- (IBAction)cancel:(id)sender
{
    // TODO:do not use presentingViewController in iOS 4.x
    // only supported in iOS 5.x
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    /// see:http://stackoverflow.com/questions/8641557/how-set-uitextfield-height
    CGRect emailFrameOrigin = email.frame;
    CGRect passwordFrameOrigin = password.frame;
    
    emailFrameOrigin.size.height = emailFrameOrigin.size.height * 1.5;
    passwordFrameOrigin.size.height = passwordFrameOrigin.size.height * 1.5;
    
    email.frame = emailFrameOrigin;
    password.frame = passwordFrameOrigin;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)dismissMe:(id)sender
{
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
   // return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
