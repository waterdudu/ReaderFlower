//
//  DDGoogleReader.h
//  ReaderFlower
//
//  Created by dudu Shang on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "DDGoogleReaderDelegate.h"

@interface DDGoogleReader : NSObject

{
    NSString* _sid;
    NSString* _auth;
    NSString* _lsid;

    NSString* _token;
    NSString* _email;

    NSError *_error;

    __unsafe_unretained id<DDGoogleReaderDelegate> _delegate;
    ASIHTTPRequest *_r;
    
}

@property (nonatomic, copy) NSString* sid;
@property (nonatomic, copy) NSString* auth;
@property (nonatomic, copy) NSString* lsid;
@property (nonatomic, copy) NSString* email;
@property (nonatomic, copy) NSString* password;
@property (nonatomic, copy) NSString* token;

@property (nonatomic, strong) NSError *error;

/////////////////////////////////////////////////////////////////////
///        WHT this is OK???? while Database's delegate is wrong????
// @property (nonatomic, assign) id<DDGoogleReaderDelegate> delegate;
@property (nonatomic, unsafe_unretained) id<DDGoogleReaderDelegate> delegate;

@property (nonatomic, strong) ASIHTTPRequest *r;


- (BOOL)signIn;

// token
- (BOOL)setTokenWhenError:(NSError **)error;

// subscription
- (void)loadMoreFeedsFromDB:(NSString *)feedURL numberOfContent:(int)numberOfContent;
- (void)loadMoreFeeds:(NSString *)feedURL;

- (void)getSubscriptionList;

- (void)getFeedsByURL:(NSString *)feedURL
              continuation:(NSString *)continuation
          numberOfContents:(int)numberOfContents;


// stream



@end
