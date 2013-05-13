//
//  DDTagList.h
//  ReaderFlower
//
//  Created by dudu Shang on 2/25/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDTagList : NSObject
{
    NSArray *_tagList;
}

@property (nonatomic, strong) NSArray *tagList;

- (id)initWithTagListDictionaryArray:(NSArray *)array;

@end
