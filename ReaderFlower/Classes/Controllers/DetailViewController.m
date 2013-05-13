//
//  DetailViewController.m
//  ReaderFlower
//
//  Created by dudu Shang on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "DTColor+HTML.h"
#import "NSData+DTBase64.h"

#import "DTAttributedTextView.h"
#import "DTWebVideoView.h"

#import "NSAttributedString+HTML.h"
#import "NSString+HTMLConvert.h"

const CGFloat TITLE_VIEW_HEIGHT = 50.0;
const int TITLE_VIEW_TAG = 10;

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
- (void)configureTextView;
- (void)configureTitleView;

- (void)configurePageScrollView;
- (void)loadVisibleTextView;
- (void)loadVisiblePages;
- (void)loadPage:(NSInteger)page;
- (void)purgePage:(NSInteger)page;
// from black apple
- (NSAttributedString *)getAttributeString:(NSString *)string;
// from vm
- (void)reconfigurePageTextView;

- (void)addGestures;

- (NSAttributedString *)getAttributeString:(NSString *)string;

- (NSString *)t_get_attribute_string_from_file;
- (NSAttributedString *)t_get_render_string;


@end

@implementation DetailViewController

@synthesize detailItem = _detailItem;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize webView = _webView;
@synthesize feedContent = _feedContent;
@synthesize textView = _textView;
@synthesize baseURL = _baseURL;
@synthesize feedItem = _feedItem;

@synthesize mediaPlayers = _mediaPlayers;

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;

@synthesize feeds = _feeds;
@synthesize pageTextViews = _pageTextViews;


#pragma mark Properties

- (NSMutableSet *)mediaPlayers
{
	if (!_mediaPlayers)
	{
		_mediaPlayers = [[NSMutableSet alloc] init];
	}
	
	return _mediaPlayers;
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

#pragma mark - gesture
- (void)addGestures
{
    UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
//    [self.view addGestureRecognizer:swipeGestureRight];
    [self.textView addGestureRecognizer:swipeGestureRight];
    
    UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.textView addGestureRecognizer:swipeGestureLeft];
    
//    [self.view addGestureRecognizer:swipeGestureLeft];
}

- (IBAction)handleSwipeGesture:(UIGestureRecognizer *)sender
{
    UISwipeGestureRecognizerDirection direction = [(UISwipeGestureRecognizer *)sender direction];
    switch (direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            NSLog(@"Left");
            
            break;
            
        case UISwipeGestureRecognizerDirectionRight:
            NSLog(@"Right");
            break;
        default:
            break;
    }
                                                   
}

#pragma mark UIViewController

- (void)loadView
{
    [super loadView];
    
    
    if(DD_WEBVIEW_CONTENT_RENDER)
    {
        [self.textView setHidden:YES];
    }
    // from black apple
    [self.textView setHidden:YES];

}
// black apple
-(void)loadPageAt:(NSInteger)page
{
    [self loadPage:page];
}
- (void)loadVisiblePages
{
    // First, determine which page is currently visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = (NSInteger)floor((self.scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    DLog(@"loaded page : %d", page);
    // Update the page control
    self.pageControl.currentPage = page;
    
    // Work out which pages you want to load
    NSInteger firstPage = page - 1;
    NSInteger lastPage = page + 1;
    
    // Purge anything before the first page
    for (NSInteger i=0; i<firstPage; i++) {
        [self purgePage:i];
    }
    
	// Load pages in our range
    for (NSInteger i=firstPage; i<=lastPage; i++) {
        [self loadPage:i];
    }
    
	// Purge anything after the last page
    for (NSInteger i=lastPage+1; i<self.feeds.count; i++) {
        [self purgePage:i];
    }
    
}
- (void)purgePage:(NSInteger)page {
    if (page < 0 || page >= self.feeds.count) {
        // If it's outside the range of what you have to display, then do nothing
        return;
    }
    
    // Remove a page from the scroll view and reset the container array
    UIView *pageView = [self.pageTextViews objectAtIndex:page];
    if ((NSNull*)pageView != [NSNull null]) {
        [pageView removeFromSuperview];
        [self.pageTextViews replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}

- (void)loadPage:(NSInteger)page {
    if (page < 0 || page >= self.feeds.count) {
        // If it's outside the range of what you have to display, then do nothing
        return;
    }
    
    // 1
    UIView *pageView = [self.pageTextViews objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {
        // 2
        CGRect frame = self.scrollView.bounds;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0.0f;
        
        // 3
 //       UIImageView *newPageView = [[UIImageView alloc] initWithImage:[self.pageImages objectAtIndex:page]];
//        newPageView.contentMode = UIViewContentModeScaleAspectFit;
//        newPageView.frame = frame;
//        [self.scrollView addSubview:newPageView];
        
        // new a dttextview and add as a subview
        [DTAttributedTextContentView setLayerClass:[CATiledLayer class]];
     
        DTAttributedTextView *newTextView = [[DTAttributedTextView alloc] initWithFrame:frame];

        
        newTextView.textDelegate = self;
        newTextView.contentView.shouldDrawImages = YES;
        newTextView.contentView.shouldLayoutCustomSubviews = YES;
        
        newTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        newTextView.contentView.edgeInsets = UIEdgeInsetsMake(40, 40, 400, 40);  // less than 400, textview will not scroll to the end
        DDFeedItem *feedItem = [self.feeds objectAtIndex:page];
        NSString *content = feedItem.content ? feedItem.content : feedItem.summary;
        newTextView.attributedString = [self getAttributeString:content];
        
        newTextView.contentMode = UIViewContentModeScaleAspectFit;
        newTextView.frame = frame;
  
        [self.scrollView addSubview:newTextView];
        
        // 4
        [self.pageTextViews replaceObjectAtIndex:page withObject:newTextView];

//        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Oliver.jpg"]];
//        [self.pageTextViews replaceObjectAtIndex:page withObject:imageView];

        
//        [self.pageTextViews replaceObjectAtIndex:page withObject:newTextView.contentView];
        
//        [self.textView setHidden:NO];
//        self.textView.attributedString = [self t_get_render_string];
    }
}

- (void)loadVisibleTextView
{
    
    
    // 4
    CGSize pagesScrollViewSize = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * self.feeds.count, pagesScrollViewSize.height);
    
    // 5
    [self loadVisiblePages];
}

- (void)configureTitleView
{
    
    CGRect frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, TITLE_VIEW_HEIGHT);
    
    UILabel *title = [[UILabel alloc] initWithFrame:frame];
    
    //    title.textColor       = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    title.textColor  = [UIColor blackColor];
    //    title.backgroundColor = [UIColor clearColor];
//    title.backgroundColor = [UIColor blueColor];
    title.font = [UIFont boldSystemFontOfSize:24.0];
//    title.text            = @"self.feedItem.title";
    title.tag  = TITLE_VIEW_TAG;
    //    title.backgroundColor = [
  	[self.view addSubview:title];

}
- (void)configureTextView
{
    
    CGRect frame = CGRectMake(0.0, TITLE_VIEW_HEIGHT, self.view.frame.size.width, self.view.frame.size.height);

    [DTAttributedTextContentView setLayerClass:[CATiledLayer class]];
	self.textView = [[DTAttributedTextView alloc] initWithFrame:frame];
	self.textView.textDelegate = self;
    self.textView.contentView.shouldDrawImages = YES;
    self.textView.contentView.shouldLayoutCustomSubviews = YES;
    
	self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textView.contentView.edgeInsets = UIEdgeInsetsMake(40, 40, 400, 40);  // less than 400, textview will not scroll to the end
    


	[self.view addSubview:self.textView];
    [self.textView setHidden:YES];

}

- (void)loadPageTextViewAt:(NSInteger)index
{
    [self loadPage:index];
}
- (void)reconfigurePageTextView
{
    [self configurePageScrollView];
    
    CGSize pagesScrollViewSize = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * self.feeds.count, pagesScrollViewSize.height);
    
}
- (void)configurePageScrollView
{
    NSInteger pageCount = self.feeds.count;
    
    // 2
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = pageCount;
    
    // 3
    self.pageTextViews = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < pageCount; ++i) {
        [self.pageTextViews addObject:[NSNull null]];
    }
// black apple    
    CGSize pagesScrollViewSize = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * self.feeds.count, pagesScrollViewSize.height);
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
//        self.detailDescriptionLabel.text = [self.detailItem description];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    [self configureTitleView];
    // [self configureTextView ];
    
    [self configurePageScrollView];
    
    [self addGestures];
    self.feeds = [[NSMutableArray alloc] init];
    
    [self addObserver:self forKeyPath:@"feeds" options:NSKeyValueObservingOptionNew context:nil];
    
      
}

- (void)didChangeValueForKey:(NSString *)key
{
    if ([key isEqualToString:@"feeds"]) {
        DLog(@"change feeds value");
        [self configurePageScrollView];
    }
}

- (void)reloadContentByWebView
{
    [self.webView loadHTMLString:self.feedContent baseURL:nil];
}

- (void)reloadContentByDTAttributedTextView
{
    // Do not use self.feedContent, read content from feedItem instead
//    if (self.feedContent == nil)  return;
    // Load HTML data
    
    if (DD_READ_FEED_CONTENT_FROM_HTML_FILE) {
        self.feedContent = [self t_get_attribute_string_from_file];
    }

//	NSString *readmePath = [[NSBundle mainBundle] pathForResource:_fileName ofType:nil];
//	NSString *html = [NSString stringWithContentsOfFile:readmePath encoding:NSUTF8StringEncoding error:NULL];
//	NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
	
	// Create attributed string from HTML
	CGSize maxImageSize = CGSizeMake(self.view.bounds.size.width - 20.0, self.view.bounds.size.height - 20.0);
	
    NSURL *baseURL = nil;
    
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:2.0],NSTextSizeMultiplierDocumentOption, [NSValue valueWithCGSize:maxImageSize], DTMaxImageSize,
                             @"Times New Roman", DTDefaultFontFamily,  @"purple", DTDefaultLinkColor, baseURL, NSBaseURLDocumentOption, nil]; 
	
//	NSAttributedString *string = [[NSAttributedString alloc] initWithHTML:data options:options documentAttributes:NULL];
    //	NSString *stringReplacedPercent = [self.feedContent stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];  // using self.feedContent
    NSString *content = self.feedItem.content == nil ? self.feedItem.summary : self.feedItem.content;
//    DLog(@"%@", content);
    
    NSString *stringReplacedPercent = [content stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    stringReplacedPercent = stringReplacedPercent ? stringReplacedPercent : self.feedItem.content;

    // remove html tags
    NSString *stringNoHTMLTag = [[stringReplacedPercent stringByConvertingHTMLToPlainText] stringByRemovingNewLinesAndWhitespace];
    DLog(@"********     %@", stringNoHTMLTag);

    
    NSData *stringData = [stringReplacedPercent dataUsingEncoding:NSUTF8StringEncoding];
    
//    DLog(@"%@", stringReplacedPercent);

    //    NSAttributedString *string = [[NSAttributedString alloc] initWithString:self.feedContent attributes:options];
//    NSAttributedString *string = [[NSAttributedString alloc] initWithString:stringReplacedPercent attributes:options];
    NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:stringData options:options documentAttributes:nil];
//    DLog(@"%@", string);
	// Display string
	self.textView.attributedString = string;
    
    
    
    // Update title view
    UILabel *title_label = (UILabel *)[self.view viewWithTag:TITLE_VIEW_TAG];
    title_label.text = self.feedItem.title;
	

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
    
/*
	[self.textView setContentInset:UIEdgeInsetsMake(0, 0, 304, 0)];
	[self.textView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 44, 0)];
    // now the bar is up so we can autoresize again
	self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.navigationController setToolbarHidden:NO animated:YES];
*/
//    [self reloadContentByDTAttributedTextView];
    
    [self loadVisibleTextView];


}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    

}

- (void)viewWillDisappear:(BOOL)animated
{
    // stop all playing media
	for (MPMoviePlayerController *player in self.mediaPlayers)
	{
		[player stop];
	}

    
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
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}
							
#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}


#pragma mark - DTAttributedTextContentViewDelegate

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame
{
	if (attachment.contentType == DTTextAttachmentTypeVideoURL)
	{
		NSURL *url = (id)attachment.contentURL;
		
		// we could customize the view that shows before playback starts
		UIView *grayView = [[UIView alloc] initWithFrame:frame];
		grayView.backgroundColor = [DTColor blackColor];
		
		// find a player for this URL if we already got one
		MPMoviePlayerController *player = nil;
		for (player in self.mediaPlayers)
		{
			if ([player.contentURL isEqual:url])
			{
				break;
			}
		}
		
		if (!player)
		{
			player = [[MPMoviePlayerController alloc] initWithContentURL:url];
			[self.mediaPlayers addObject:player];
		}
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_4_2
		NSString *airplayAttr = [attachment.attributes objectForKey:@"x-webkit-airplay"];
		if ([airplayAttr isEqualToString:@"allow"])
		{
			if ([player respondsToSelector:@selector(setAllowsAirPlay:)])
			{
				player.allowsAirPlay = YES;
			}
		}
#endif
		
		NSString *controlsAttr = [attachment.attributes objectForKey:@"controls"];
		if (controlsAttr)
		{
			player.controlStyle = MPMovieControlStyleEmbedded;
		}
		else
		{
			player.controlStyle = MPMovieControlStyleNone;
		}
		
		NSString *loopAttr = [attachment.attributes objectForKey:@"loop"];
		if (loopAttr)
		{
			player.repeatMode = MPMovieRepeatModeOne;
		}
		else
		{
			player.repeatMode = MPMovieRepeatModeNone;
		}
		
		NSString *autoplayAttr = [attachment.attributes objectForKey:@"autoplay"];
		if (autoplayAttr)
		{
			player.shouldAutoplay = YES;
		}
		else
		{
			player.shouldAutoplay = NO;
		}
		
		[player prepareToPlay];
		
		player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		player.view.frame = grayView.bounds;
		[grayView addSubview:player.view];
		
		return grayView;
	}
	else if (attachment.contentType == DTTextAttachmentTypeImage)
	{
		// if the attachment has a hyperlinkURL then this is currently ignored
		DTLazyImageView *imageView = [[DTLazyImageView alloc] initWithFrame:frame];
        imageView.shouldShowProgressiveDownload = YES;
		imageView.delegate = self;
		if (attachment.contents)
		{
			imageView.image = attachment.contents;
		}
		
		// url for deferred loading
		imageView.url = attachment.contentURL;
        DLog(@"%@", attachment.contentURL);
		
		return imageView;
	}
	else if (attachment.contentType == DTTextAttachmentTypeIframe)
	{
        // contentURL
        // http://reader.googleusercontent.com/reader/embediframe?src=http://player.youku.com/player.php/sid/XNTA4NTQxOTgw/v.swf&width=480&height=400

        DTWebVideoView *videoView = [[DTWebVideoView alloc] initWithFrame:frame];
        videoView.delegate = (id<DTWebVideoViewDelegate>)self;
		videoView.attachment = attachment;
		
		return videoView;

//        return nil;
	}
	else if (attachment.contentType == DTTextAttachmentTypeObject)
	{
		// somecolorparameter has a HTML color
		UIColor *someColor = [UIColor colorWithHTMLName:[attachment.attributes objectForKey:@"somecolorparameter"]];
		
		UIView *someView = [[UIView alloc] initWithFrame:frame];
		someView.backgroundColor = someColor;
		someView.layer.borderWidth = 1;
		someView.layer.borderColor = [UIColor blackColor].CGColor;
		
		return someView;
	}
	
	return nil;
}


#pragma mark - DTLazyImageViewDelegate

- (void)lazyImageView:(DTLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size {
#if 0
	NSURL *url = lazyImageView.url;
	CGSize imageSize = size;


    NSLog(@"----------   %f %f   ---------", size.width, size.height);
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL == %@", url];
	
	// update all attachments that matchin this URL (possibly multiple images with same size)
	for (DTTextAttachment *oneAttachment in [_textView.contentView.layoutFrame textAttachmentsWithPredicate:pred])
	{
        
        DLog(@"------------------------------------");

        DLog(@"            image    size :%f %f", imageSize.width, imageSize.height);
        DLog(@"attachement original size :%f %f", oneAttachment.originalSize.width, oneAttachment.originalSize.height);
        DLog(@"attachement display  size :%f %f", oneAttachment.displaySize.width, oneAttachment.displaySize.height);
  
        //		oneAttachment.originalSize = imageSize;
        CGSize s = oneAttachment.displaySize;
      //	oneAttachment.originalSize = CGSizeMake(200, 200);
        oneAttachment.originalSize = s;
//        oneAttachment.originalSize = oneAttachment.displaySize;
        
		if (!CGSizeEqualToSize(imageSize, oneAttachment.displaySize))
		{
//			oneAttachment.displaySize = imageSize;
            oneAttachment.displaySize = s;
            
		}
	}
#endif 	
	// redo layout
	// here we're layouting the entire string, might be more efficient to only relayout the paragraphs that contain these attachments
	[_textView.contentView relayoutText];


}

#pragma mark - scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Load the pages that are now on screen
    [self loadVisiblePages];
}

#pragma mark - DTWebVideoViewDelegate
- (BOOL)videoView:(DTWebVideoView *)videoView shouldOpenExternalURL:(NSURL *)url
{
    // NO video should be opened Externally (i.e. by Safary web browser)
    return NO;
}

#pragma mark - feeds function
- (NSAttributedString *)getAttributeString:(NSString *)string
{
    // Create attributed string from HTML
	CGSize maxImageSize = CGSizeMake(self.view.bounds.size.width - 20.0, self.view.bounds.size.height - 20.0);
	
    NSURL *baseURL = nil;
    
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:2.0],NSTextSizeMultiplierDocumentOption, [NSValue valueWithCGSize:maxImageSize], DTMaxImageSize,
                             @"Times New Roman", DTDefaultFontFamily,  @"purple", DTDefaultLinkColor, baseURL, NSBaseURLDocumentOption, nil]; 
	
    NSString *stringReplacedPercent = [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    stringReplacedPercent = stringReplacedPercent ? stringReplacedPercent : string;
    
    NSData *stringData = [stringReplacedPercent dataUsingEncoding:NSUTF8StringEncoding];
    
    NSAttributedString *attributeString = [[NSAttributedString alloc] initWithHTMLData:stringData options:options documentAttributes:nil];
    
    return attributeString;
}

#pragma mark - test
- (NSString *)t_get_attribute_string_from_file
{
    // Load HTML data
    //    NSString *fileName = @"Image.html";
    NSString *fileName = @"Image_brokenbridge.html";
    
	NSString *readmePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
	NSString *html = [NSString stringWithContentsOfFile:readmePath encoding:NSUTF8StringEncoding error:NULL];

    
    return html;
}

- (NSAttributedString *)t_get_render_string
{
    // Create attributed string from HTML
	CGSize maxImageSize = CGSizeMake(self.view.bounds.size.width - 20.0, self.view.bounds.size.height - 20.0);
	
    NSURL *baseURL = nil;
    
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:2.0],NSTextSizeMultiplierDocumentOption, [NSValue valueWithCGSize:maxImageSize], DTMaxImageSize,
                             @"Times New Roman", DTDefaultFontFamily,  @"purple", DTDefaultLinkColor, baseURL, NSBaseURLDocumentOption, nil]; 
	
    NSString *content = [self t_get_attribute_string_from_file];
     
    NSString *stringReplacedPercent = [content stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    stringReplacedPercent = stringReplacedPercent ? stringReplacedPercent : self.feedItem.content;
    
    // remove html tags
    NSString *stringNoHTMLTag = [[stringReplacedPercent stringByConvertingHTMLToPlainText] stringByRemovingNewLinesAndWhitespace];
     
    NSData *stringData = [stringReplacedPercent dataUsingEncoding:NSUTF8StringEncoding];
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:stringData options:options documentAttributes:nil];
    
    return string;

}


@end
