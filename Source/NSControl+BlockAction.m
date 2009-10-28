//
//  NSControl+BlockAction.m
//  Selectweet
//
//  Created by Joachim Bengtsson on 2009-10-27.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "NSControl+BlockAction.h"
#import "BlockExtensions.h"
#import <objc/runtime.h>

@implementation NSControl (TCBlockAction)
-(void)setBlockAction:(void(^)())action;
{
	id action2 = [[action copy] autorelease];
	objc_setAssociatedObject(self, _cmd, action2, OBJC_ASSOCIATION_COPY);
	[self setTarget:action2];
	[self setAction:@selector(tcInvoke)];
}

@end
