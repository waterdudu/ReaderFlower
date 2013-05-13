//
//  DDSubscription.h
//  ReaderFlower
//
//  Created by dudu Shang on 1/27/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDSubscription : NSObject
{
    int         _pk;
    NSString    *_subscriptionId;       // id: "feed/http://video.google.com/videofeed?type=top100new"
    NSString    *_title;
    NSString    *_sortid;               // BD0D5B4C
    NSString    *_firstitemmsec;        // 1216692368681
    NSString    *_htmlUrl;              // http://video.google.com/
        
    // one subscription may have more than one category associated with it
    NSArray    *_categoriesId;         // id:"user/10060313821523494015/label/Video" 
    NSArray    *_categoriesLabel;      // label:"Video"
    
    int         _unreadcount;
    NSString    *_continuation;
    NSString    *_faviconLink;
    UIImage     *_favicon;
    
    int         _sType;

}

@property (nonatomic) int pk;

@property (nonatomic, copy) NSString *subscriptionId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *sortid;
@property (nonatomic, copy) NSString *firstitemmsec;
@property (nonatomic, copy) NSString *htmlUrl;

@property (nonatomic, strong) NSArray *categoriesId;
@property (nonatomic, strong) NSArray *categoriesLabel;

@property (nonatomic) int unreadcount;
@property (nonatomic, strong) NSString *continuation;
@property (nonatomic, strong) NSString *faviconLink;
@property (nonatomic, strong) UIImage *favicon;

@property (nonatomic) int sType;
@end

