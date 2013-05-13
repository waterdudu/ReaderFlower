//
//  DDReaderDefines.h
//  ReaderFlower
//
//  Created by dudu Shang on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#ifndef ReaderFlower_DDReaderDefines_h
#define ReaderFlower_DDReaderDefines_h

static NSString* const kDDGRScope                = @"https://www.google.com/reader/api";
static NSString* const kDDGRUserAgent            = @"ReaderFlower/0.1";

// API root
static NSString* const kDDGRAPIPrefix            = @"https://www.google.com/reader/api/0";

static NSString* const kDDGRAtomPrefix           = @"https://www.google.com/reader/atom";
static NSString* const kDDGRStreamContentsPrefix = @"https://www.google.com/reader/api/0/stream/contents";

static NSString* const kDDGRUserLogin            = @"https://www.google.com/accounts/ClientLogin";

static NSString* const kDDGRToken                = @"https://www.google.com/reader/api/0/token";

static NSString* const kDDGRSubscriptionList     = @"https://www.google.com/reader/api/0/subscription/list";

// items key in dictionary
static NSString* const kDDFeedItemCrawlTimeMsec       = @"crawlTimeMsec";
static NSString* const kDDFeedItemTimeStampUsec       = @"timestampUsec";
static NSString* const kDDFeedItemId                  = @"id";
static NSString* const kDDFeedItemTitle               = @"title";
static NSString* const kDDFeedItemAuthor              = @"author";
static NSString* const kDDFeedItemCategories          = @"categories";
static NSString* const kDDFeedItemPublished           = @"published";
static NSString* const kDDFeedItemUpdated             = @"updated";
static NSString* const kDDFeedItemContent             = @"content";
static NSString* const kDDFeedItemSummary             = @"summary";

// subscrition keys in dictionary
static NSString* const kDDSubscriptionId              = @"id";
static NSString* const kDDSubscriptionTitle           = @"title";
static NSString* const kDDSubscriptionSortid          = @"sortid";
static NSString* const kDDSubscriptionFirstitemmsec   = @"firstitemmsec";
static NSString* const kDDSubscriptionCategories      = @"categories";
static NSString* const kDDSubscriptionCategoriesId    = @"id";
static NSString* const kDDSubscriptionCategoriesLabel = @"label";


static NSString* const kDDFeedItemAlternate           = @"alternate";
static NSString* const kDDFeedItem                    = @"alternate";





#endif
