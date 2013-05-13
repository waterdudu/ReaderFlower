//
//  DTLazyImageView+NSString.m
//  ReaderFlower
//
//  Created by dudu Shang on 2/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "DTLazyImageView+NSString.h"
#import "NSData+DTBase64.h"

@implementation DTLazyImageView (NSString)

// JPEG string is shorter than PNG
- (NSString *)base64EncodedString
{

    if (self.image) {
        NSData *data = UIImageJPEGRepresentation(self.image, 1);
        if (data) {
            return [data base64EncodedString];
        }
    }
    return nil;
    
}
@end
