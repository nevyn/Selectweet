//
//  TwitterAccount.h
//  Selectweet
//
//  Created by Joachim Bengtsson on 2009-10-27.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TwitterAccount : NSManagedObject
@property (copy) NSString *username;
@property (copy) NSString *password;
@end
