//
//  SelectweetApplicationDelegate.m
//  Selectweet
//
//  Created by Joachim Bengtsson on 2009-10-28.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "SelectweetApplicationDelegate.h"


@implementation SelectweetApplicationDelegate
- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	// On startup, when asked to open an untitled file, open the last opened
	// file instead
	if (!applicationHasStarted)
	{
		// Get the recent documents
		NSDocumentController *controller =
		[NSDocumentController sharedDocumentController];
		NSArray *documents = [controller recentDocumentURLs];
		
		// If there is a recent document, try to open it.
		if ([documents count] > 0)
		{
			NSError *error = nil;
			[controller
			 openDocumentWithContentsOfURL:[documents objectAtIndex:0]
			 display:YES error:&error];
			
			// If there was no error, then prevent untitled from appearing.
			if (error == nil)
			{
				return NO;
			}
		}
	}
	
	return YES;
}
-(void)applicationDidFinishLaunching:(NSNotification *)notification;
{
	applicationHasStarted = YES;
}
@end
