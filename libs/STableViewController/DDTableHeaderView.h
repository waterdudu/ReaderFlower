//
//  DDTableHeaderView.h
//  XSTableViewController
//
//  Created by dudu Shang on 2/8/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDTableHeaderView : UIView
{
//    UILabel *title;
//    UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UILabel *lastUpdatedDate;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
