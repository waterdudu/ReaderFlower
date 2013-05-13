//
//  DetailViewController.h
//  ReaderFlower
//
//  Created by dudu Shang on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DTAttributedTextView.h"
#import "DTLazyImageView.h"
#import "DDFeedItem.h"
#import "DTWebVideoView.h"

@class DTAttributedTextView;

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate,
    DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate, DTWebVideoViewDelegate,
    UIScrollViewDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) DDFeedItem *feedItem;
@property (strong, nonatomic) NSString *feedContent;
@property (strong, nonatomic) NSString *title;

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSMutableSet *mediaPlayers;

@property (strong, nonatomic) DTAttributedTextView *textView;
// for scroll detail view
@property (strong, nonatomic) NSArray *feeds;
@property (strong, nonatomic) NSMutableArray *pageTextViews;


@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;


- (void)reloadContent;
- (void)reloadContentByWebView;
- (void)reloadContentByDTAttributedTextView;

// from black apple
- (void)loadPageAt:(NSInteger)page;
// from vmware
- (void)loadPageTextViewAt:(NSInteger)index;
- (void)loadVisiblePages;

@end
