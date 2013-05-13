//
//  DDSubscriptionSectionController.h
//  ReaderFlower
//
//  Created by dudu tsang on 13-1-30.
//  Copyright (c) 2013年 MMM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCRetractableSectionController.h"

@interface DDSubscriptionSectionController : GCRetractableSectionController

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *subscriptions;       // subscription group, []
@property (nonatomic) BOOL hasChild;

- (id)initWithArray:(NSArray*) subscriptions viewController:(UIViewController *)givenViewController;

@end
