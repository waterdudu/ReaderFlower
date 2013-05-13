//
//  DDLanguageHelper.m
//  ReaderFlower
//
//  Created by dudu shang on 2/28/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "DDLanguageHelper.h"

@implementation DDLanguageHelper

+ (NSString *)getPreferedLanguage
{
    NSArray *languages = [NSLocale preferredLanguages];
    
    // index 0, index 1
    NSString *language0 = [languages objectAtIndex:0];
    NSString *language1 = [languages objectAtIndex:1];

    // if prefered language is en, use the second language for comparation
    if ([language0 isEqualToString:@"en"]) {
        return language1;
    }
    return language0;
}
@end
