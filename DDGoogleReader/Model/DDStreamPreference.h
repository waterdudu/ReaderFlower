//
//  DDStreamPreference.h
//  ReaderFlower
//
//  Created by dudu Shang on 2/25/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDStreamPreference : NSObject
{
    NSString *_subscriptionOrderString;
    
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // key   : streamId(user/xxx/label/myLabel)
    // value : "5F1F941D355A7E4F1D4D18B1BD0D5B4CC974DB1407D4D9A6" or nil
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NSDictionary *_streamPrefs;
}

@property (nonatomic, strong) NSString *subscriptionOrderString;
@property (nonatomic, strong) NSDictionary *streamPrefs;

- (id)initWithDict:(NSDictionary *)dict;

@end
