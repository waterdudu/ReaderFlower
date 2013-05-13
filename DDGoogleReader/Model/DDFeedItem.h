//
//  DDFeedItem.h
//  DDJSONKit
//
//  Created by tsang dudu on 13-1-14.
//  Copyright 2013年 MMM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface DDFeedItem : NSObject {
    NSString         *_crawlTime;        // usec
    NSString         *_title;           
    NSString         *_author;
    NSString         *_itemId;              // "id":"tag:google.com,2005:reader/item/cb9acc012b985129"
    NSString         *_alternateHref;       // "alternate":[{"href":"http://blog.sina.com.cn/s/blog_4701280b0100egc6.html"
    NSString         *_alternateType;       //  ,"type":"text/html"}]
    NSMutableArray   *_categories;          // []
    
    NSString         *_published;           // 1250023156
    NSString         *_updated;             // 1250023156
    
    NSString         *_content;             // content { direction:"XX", content:"XX" }
    NSString         *_summary;             // summery { direction:"XX", content:"XX" }
    NSString         *_direction;
    NSString         *_likingUsers;         // []
    NSString         *_comments;            // []
    NSString         *_annotations;         // []
    
    NSString         *_originStreamId;      // feed/http://blog.sina.com.cn/rss/1191258123.xml
    NSString         *_originTitle;         // "hanhan"
    NSString         *_originHtmlUrl;       // http://blog.sina.cn/twocold
    
    // control variables
    BOOL             _isRead;
    BOOL             _isStar;
    BOOL             _isShared;
    BOOL             _isLiked;
    
    int              _likeCount;
    
    NSString         *_shortSummary;
}

//@property (nonatomic, copy) NSDate           *crawlTime;
@property (nonatomic, strong) NSString           *crawlTime;
@property (nonatomic, copy) NSString         *title;
@property (nonatomic, copy) NSString         *author;
@property (nonatomic, copy) NSString         *itemId;
@property (nonatomic, copy) NSString         *alternateHref;
@property (nonatomic, copy) NSString         *alternateType;
//@property (nonatomic, strong) NSMutableArray   *categories;
@property (nonatomic, copy) NSMutableArray   *categories;


//@property (nonatomic, retain) NSDate           *published;
//@property (nonatomic, retain) NSDate           *updated;
@property (nonatomic, strong) NSString           *published;
@property (nonatomic, strong) NSString           *updated;

@property (nonatomic, copy) NSString         *content;
@property (nonatomic, copy) NSString         *summary;
@property (nonatomic, copy) NSString         *direction;
@property (nonatomic, copy) NSString         *likingUsers;
@property (nonatomic, copy) NSString         *comments;
@property (nonatomic, copy) NSString         *annotations;


@property (nonatomic, copy) NSString         *originStreamId;
@property (nonatomic, copy) NSString         *originTitle;
@property (nonatomic, copy) NSString         *originHtmlUrl;

@property (nonatomic, assign) BOOL           isRead;
@property (nonatomic, assign) BOOL           isStar;
@property (nonatomic, assign) BOOL           isShared;
@property (nonatomic, assign) BOOL           isLiked;

@property (nonatomic, assign) int likeCount;

@property (nonatomic, strong) NSString      *shortSummary;

@property (nonatomic, strong) NSString      *realContent;

@end
