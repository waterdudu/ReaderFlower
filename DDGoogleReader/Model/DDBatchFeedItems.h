//
//  DDBatchFeedItems.h
//  DDJSONKit
//
//  Created by tsang dudu on 13-1-14.
//  Copyright 2013年 MMM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface DDBatchFeedItems : NSObject {
    NSString            *_direction;
    NSString            *_feedId;
    NSString            *_title;
    NSString            *_continuation;
    
    NSString            *_alternateHref;
    NSString            *_alternateType;
    
    NSDate              *_updated;
    
    NSArray             *_items;
    
    
}

@property (nonatomic, copy) NSString  *direction;
@property (nonatomic, copy) NSString  *feedId;
@property (nonatomic, copy) NSString  *title;
@property (nonatomic, copy) NSString  *continuation;
@property (nonatomic, copy) NSString  *alternateHref;
@property (nonatomic, copy) NSString  *alternateType;

//@property (nonatomic, strong) NSDate  *updated;
//@property (nonatomic, strong) NSArray *items;

@property (nonatomic, retain) NSDate  *updated;
@property (nonatomic, retain) NSArray *items;


@end
