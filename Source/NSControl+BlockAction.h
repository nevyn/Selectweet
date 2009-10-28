//
//  NSControl+BlockAction.h
//  Selectweet
//
//  Created by Joachim Bengtsson on 2009-10-27.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSControl (TCBlockAction)
-(void)setBlockAction:(void(^)())action;
@end
