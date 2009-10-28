//
//  MyDocument.h
//  Selectweet
//
//  Created by Joachim Bengtsson on 2009-10-27.
//  Copyright Third Cog Software 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TwitterAccount.h"
#import "MGTwitterEngine.h"

@interface SelectweetUserDocument : NSPersistentDocument 
<MGTwitterEngineDelegate> 
{
	TwitterAccount *account;
	MGTwitterEngine *engine;
	
	IBOutlet NSWindow *progressWindow;
		IBOutlet NSProgressIndicator *progress_spinner;
	IBOutlet NSWindow *loginWindow;
		IBOutlet NSButton *login_cancelButton;
		IBOutlet NSButton *login_loginButton;
	
	NSMutableDictionary *requests;
	
	NSTimer *refreshTimer;
	
	IBOutlet NSArrayController *tweets;
}
-(IBAction)loadTweets:(id)sender;
@end
