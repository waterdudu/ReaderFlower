//
//  NSString+DDGoogleReader.h
//  ReaderFlower
//
//  Created by dudu Shang on 1/31/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDGRDBDefines.h"

@interface NSString (DDGoogleReader)

- (NSString *)getLabelContentFromCategoriesId;
- (DDSubscriptionType)getSubscriptionType;


@end
