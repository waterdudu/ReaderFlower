//
//  DDTableHeaderView.m
//  XSTableViewController
//
//  Created by dudu Shang on 2/8/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "DDTableFooterView.h"

@implementation DDTableFooterView
@synthesize activityIndicator = _activityIndicator;
@synthesize infoLabel = _infoLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    [super awakeFromNib];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
