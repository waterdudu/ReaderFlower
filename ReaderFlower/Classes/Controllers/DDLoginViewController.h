//
//  DDLoginViewController.h
//  ReaderFlower
//
//  Created by dudu Shang on 1/28/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDGoogleReader;
@protocol DDLoginViewControllerDelegate;

@interface DDLoginViewController : UIViewController
{
    IBOutlet UITextField *email;
    IBOutlet UITextField *password;
    
    __unsafe_unretained id<DDLoginViewControllerDelegate> _delegate;

    
}


- (IBAction)dismissMe:(id)sender;
//@property (nonatomic, strong) UITextField *email;
//@property (nonatomic, strong) UITextField *password;

@property (nonatomic, unsafe_unretained) id<DDLoginViewControllerDelegate> delegate;


- (IBAction)signIn:(id)sender;
- (IBAction)cancel:(id)sender;

@end


@protocol DDLoginViewControllerDelegate <NSObject>

//- (void)dismissMe:(DDLoginViewController *)modalViewController;

- (void)didFinishLogin:(DDGoogleReader *)reader status:(BOOL)status;


@end


