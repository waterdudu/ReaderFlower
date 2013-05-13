//
//  DDGoogleReader.m
//  ReaderFlower
//
//  Created by dudu Shang on 3/12/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "DDGoogleReader.h"
#import "DDReaderDefines.h"

#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "FMDatabaseQueue.h"

#import "DDReaderDefines.h"
#import "DDFeedItem.h"

#import "DDGRDatabase.h"
#import "DDGRDBDefines.h"

#import "NSString+URLEncode.h"
#import "NSData+DDFeedItem.h"


@interface DDGoogleReader()

- (NSString *)getAuthHeader;

- (BOOL)signInByEmail:(NSString *)email password:(NSString *)password;

@end


@implementation DDGoogleReader

@synthesize auth = _auth;
@synthesize lsid = _lsid;
@synthesize email = _email;
@synthesize sid = _sid;
@synthesize token = _token;
@synthesize error = _error;
@synthesize delegate = _delegate;
@synthesize password = _password;
@synthesize r = _r;

#pragma private methods
- (NSString *)getAuthHeader
{
    return [NSString stringWithFormat:@"GoogleLogin auth=%@", self.auth];
}

- (BOOL)signIn
{
    return [self signInByEmail:self.email password:self.password];
}

- (BOOL)signInByEmail:(NSString *)email password:(NSString *)password
{
/*
    ASIHTTPRequest* r = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:kDDGRUserLogin]];
    [r setUseCookiePersistence:YES];
    [r setRequestMethod:@"GET"];
    [r addRequestHeader:@"Authorization" value:[self getAuthHeader]];
    
//    [r addRequestHeader:@"Cookie" value:[NSString stringWithFormat:@"SID=%@", [self sid]]];
    [r addRequestHeader: @"User-Agent" value:kDDGRUserAgent];   
    [r startSynchronous];
    
    NSError *error = [r error];
    if (error) {
        return NO;
    }
*/
    
    NSString *postString = @"POST /accounts/ClientLogin HTTP/1.0 Content-type: application/x-www-form-urlencoded accountType=HOSTED_OR_GOOGLE&Email=myEmail&Passwd=myPassword&service=reader&source=scroll";
    
    postString = [postString stringByReplacingOccurrencesOfString:@"myEmail" withString:email];
    postString = [postString stringByReplacingOccurrencesOfString:@"myPassword" withString:password];

    NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
    NSString *url = kDDGRUserLogin;

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSString *responseString = nil;
    if (error != nil) {
        responseString = [error description];
        return NO;
    }
    else
    {
        responseString =  [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }
    
    NSLog(@"response string : %@", responseString);
    
    // get sid, lsid & auth
    NSArray *lines = [responseString componentsSeparatedByString:@"\n"];
    
    NSString* clientSID = [[lines objectAtIndex:0] substringFromIndex:4];
    NSString* clientLSID = [[lines objectAtIndex:1] substringFromIndex:5];
    NSString* clientAuth = [[lines objectAtIndex:2] substringFromIndex:5];
    
    self.sid = clientSID;
    self.lsid = clientLSID;
    self.auth = clientAuth;
    self.password = password;

    // login OK
    // set sid, auth, etc
    return YES;
}




#pragma mark - subscriptions
- (void)loadMoreFeeds:(NSString *)feedURL
{
    // by http request
    DDGRDatabase *db = [[DDGRDatabase alloc] init];
    // TODO:Error check
    [db openDB];
    NSString *c = [db getContinuationByURL:feedURL];
    c = c == nil ? @"" : c;
    
    [self getFeedsByURL:feedURL continuation:c numberOfContents:40];
    
    // TODO: save feeds to db in delegate 
}

////////////////////////////////////////////////////////////////////////////////
// NOTE:
// called only when view loaded without internet connection
////////////////////////////////////////////////////////////////////////////////

- (void)loadMoreFeedsFromDB:(NSString *)feedURL numberOfContent:(int)numberOfContent
{
    // from DB;
    // TODO:Error check
    NSArray *feeds = [[NSArray alloc] init];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:[DDGRDatabase getDBPath]];
    
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:kSelectFeedItemsWithNumber, [NSNumber numberWithInt:numberOfContent]];
        
        
        
         
         
    }];
  //  [db openDB];    
    
    
    
    

}


- (void)getSubscriptionList
{
    NSString *getSubscriptionListURL = [NSString stringWithFormat:
                             @"%@?output=json&client=scroll",
                             kDDGRSubscriptionList
                             ];
    
    self.r = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:getSubscriptionListURL]];
    [self.r setRequestMethod:@"GET"];
    [self.r addRequestHeader:@"Authorization" value:[self getAuthHeader]];
    [self.r setTimeOutSeconds:10.0f];
    [self.r setShouldAttemptPersistentConnection:NO];

    //    __block ASIHTTPRequest *wr = r;          // a weak reference of request r
    __weak ASIHTTPRequest *wr = self.r;          // a weak reference of request r
    __weak id<DDGoogleReaderDelegate> wd = self.delegate;

    [self.r setCompletionBlock:^{
        if (wd) {
            ///////////////////////////////////////////////////////
            // create a NSArray of FeedItems from JSON response
            NSMutableArray *subscriptionGroupList = [[wr responseData] subscriptionGroupList];
            [wd subscriptionListDidFinished:subscriptionGroupList error:nil];
        }
    }];
    
    [self.r setFailedBlock:^{
        if (wd) {
            NSLog(@"%@", [wr error]);
            [wd subscriptionListDidFinished:nil error:[wr error]];
        }
    }];
    
    [self.r startAsynchronous];

}

- (void)getFeedsByURL:(NSString *)feedURL 
              continuation:(NSString *)continuation
          numberOfContents:(int)numberOfContents
{
    ///////////////////////////////////////////////////////////////
    ///                 format request string
    ///////////////////////////////////////////////////////////////
    ///
    /// getting feeds url has the following format:
    /// i.e : 
    /// A) www.google.com.hk/reader/api/0/stream/contents
    /// B) /feed/http%3A%2F%2Fblog.sina.com.cn%2Frss%2F1191258123.xml
    /// C) ?r=n&c=CJbTyY6a6acC&n=40&ck=1357896142427&client=scroll
    ///
    /// TODO:
    /// is ck needed?
    /// TODO:
    /// are they different when n=40 and n=20?
    

/*    
    NSMutableArray *feeds = [[NSMutableArray alloc] init];
    DDFeedItem *item = [[DDFeedItem alloc] init];
    item.title = @"123";
    DDFeedItem *item2 = [[DDFeedItem alloc] init];
    item2.title = @"456";
    [feeds addObject:item];
    [feeds addObject:item2];
    
    [self.delegate feedQuickAddDidFinished:feeds error:nil];
    
    return;
*/    
    NSString *getFeedsURL = [NSString stringWithFormat:
                             @"%@/feed/%@?r=n&c=%@&n=%d&client=scroll",
                             //@"%@/feed/%@?r=n&%@&client=scroll",
                             kDDGRStreamContentsPrefix,
                            [feedURL urlEncode],
                             continuation,
                             numberOfContents
                             ];

    NSLog(@" --  %@ ---", getFeedsURL);
   
//    self.request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:getFeedsURL]];
    self.r = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:getFeedsURL]];
    [self.r setRequestMethod:@"GET"];
    [self.r addRequestHeader:@"Authorization" value:[self getAuthHeader]];
    [self.r setTimeOutSeconds:10.0f];
    [self.r setShouldAttemptPersistentConnection:NO];
    NSLog(@"--- %@ ---", [self getAuthHeader]);
    
    
    // see : http://stackoverflow.com/questions/8859649/asihttprequest-asiformdatarequest-referencing-request-object-within-blocks-u
    
    //    __block ASIHTTPRequest *wr = r;          // a weak reference of request r
    __weak ASIHTTPRequest *wr = self.r;          // a weak reference of request r
    __weak id<DDGoogleReaderDelegate> wd = self.delegate;
    

    [self.r setCompletionBlock:^{

        if (wd) {
//            [self.delegate RequestDidFinished:self status:YES type:GetFeedType];
            NSLog(@"----------------  OK");
            ///////////////////////////////////////////////////////
            // create a NSArray of FeedItems from JSON response
            
//            [self.delegate feedSubscriptionDidFinished:self error:nil];
//            NSArray *feeds = [[r responseData] feeds];
            DDBatchFeedItems *batchItems = [[wr responseData] batchFeedItems];

//            [self.delegate feedQuickAddDidFinished:batchItems error:nil];
            [wd feedSubscriptionDidFinished:batchItems error:nil];
        }
    }];
    
    [self.r setFailedBlock:^{
        if (wd) {
            NSLog(@"%@", [wr error]);
            [wd feedSubscriptionDidFinished:nil error:[wr error]];
        }
    }];
    
    [self.r startAsynchronous];
}

#pragma mark - token
- (BOOL)setTokenWhenError:(NSError **)error
{
    NSString *token_url = @"https://www.google.com/reader/api/0/token";
    //    ASIHTTPRequest* r = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:kDDGRToken]];
    ASIHTTPRequest* r = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:token_url]];
    [r setUseCookiePersistence:YES];
    [r setRequestMethod:@"GET"];
    [r addRequestHeader:@"Authorization" value:[self getAuthHeader]];
    
    [r addRequestHeader: @"User-Agent" value:kDDGRUserAgent];   
    [r startSynchronous];
    
    NSError *err = [r error];
    if (err) {
        *error = err;
        NSLog(@"error : %@", [err description]);
        return NO;
    }
//    [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//    NSString *responseString = [r responseData];
    NSData *responseData = [r responseData];
    NSString *tokenString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    self.token = tokenString;
    
    NSLog(@"-----    token:%@  ------", self.token);

    
    
    return YES;

}
 
@end
