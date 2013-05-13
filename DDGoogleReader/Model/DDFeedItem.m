//
//  DDFeedItem.m
//  DDJSONKit
//
//  Created by tsang dudu on 13-1-14.
//  Copyright 2013年 MMM. All rights reserved.
//

#import "DDFeedItem.h"
#import "NSString+HTMLConvert.h"

const NSInteger SHORT_SUMMARY_LENGTH = 30; 

@implementation DDFeedItem

@synthesize crawlTime=_crawlTime;        // usec
@synthesize title=_title;
@synthesize author=_author;
@synthesize itemId=_itemId;
@synthesize alternateHref=_alternateHref;
@synthesize alternateType=_alternateType;
@synthesize categories=_categories;

@synthesize published=_published;
@synthesize updated=_updated;

@synthesize content=_content;
@synthesize summary=_summary;
@synthesize direction=_direction;
@synthesize likingUsers=_likingUsers;
@synthesize comments=_comments;
@synthesize annotations=_annotations;

@synthesize originStreamId=_originStreamId;
@synthesize originTitle=_originTitle;
@synthesize originHtmlUrl=_originHtmlUrl;

// control variables
@synthesize isRead = _isRead;
@synthesize isShared = _isShared;
@synthesize isLiked = _isLiked;
@synthesize isStar = _isStar;

@synthesize likeCount = _likeCount;

@synthesize shortSummary = _shortSummary;
@synthesize realContent = _realContent;

- (NSString *)shortSummary
{
    NSString *realContent = self.summary ? self.summary : self.content;
    //    NSString *plainTextContent = [[realContent stringByConvertingHTMLToPlainText] stringByRemovingNewLinesAndWhitespace];
    NSString *plainTextContent = [realContent stringByConvertingHTMLToPlainText];
    if ([plainTextContent length] >= SHORT_SUMMARY_LENGTH) {
        return [plainTextContent substringToIndex:SHORT_SUMMARY_LENGTH];
    }
    
    return plainTextContent;
}

- (NSString *)realContent
{
    return self.summary ? self.summary : self.content;
}

@end
