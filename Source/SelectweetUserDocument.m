//
//  MyDocument.m
//  Selectweet
//
//  Created by Joachim Bengtsson on 2009-10-27.
//  Copyright Third Cog Software 2009 . All rights reserved.
//

#import "SelectweetUserDocument.h"
#import "NSControl+BlockAction.h"
#import "Tweet.h"
#import "BlockExtensions.h"

static NSTimeInterval refreshInterval = 5*60;

@interface TCMGHandler : NSObject
{
	BOOL (^successHandler)();
	BOOL (^receiveHandler)(NSArray*);
	BOOL (^failureHandler)(NSError*);
}
+(TCMGHandler*)success:(BOOL(^)())success 
						 	 receive:(BOOL(^)(NSArray*))receive
						 	 failure:(BOOL(^)(NSError*))failure;
@property (copy) BOOL (^successHandler)();
@property (copy) BOOL (^receiveHandler)(NSArray*);
@property (copy) BOOL (^failureHandler)(NSError*);
@end
@implementation TCMGHandler
@synthesize successHandler, receiveHandler, failureHandler;
-(void)dealloc;
{
	self.successHandler = self.receiveHandler = self.failureHandler = nil;
	[super dealloc];
}
+(TCMGHandler*)success:(BOOL(^)())success 
						 	 receive:(BOOL(^)(NSArray*))receive
						 	 failure:(BOOL(^)(NSError*))failure;
{
	TCMGHandler *handler = [[[TCMGHandler alloc] init] autorelease];
	handler.successHandler = success;
	handler.receiveHandler = receive;
	handler.failureHandler = failure;
	return handler;
}
@end

@interface SelectweetUserDocument ()
@property (nonatomic, assign) TwitterAccount *account;
@property (nonatomic, retain) MGTwitterEngine *engine;
@property (nonatomic, retain) NSTimer *refreshTimer;

-(void)handleRequest:(NSString*)requestID
						 success:(BOOL(^)())success 
						 receive:(BOOL(^)(NSArray*))receive
						 failure:(BOOL(^)(NSError*))failure;

-(void)tryToLogin;
-(void)showLoginWindow;
-(void)scheduleRefreshTimer;

@end



@implementation SelectweetUserDocument
@synthesize engine;

- (id)initWithType:(NSString *)type error:(NSError **)error {
	if( ! [super initWithType:type error:error] )
		return nil;
	
	NSManagedObjectContext *moc = [self managedObjectContext];
	
	[[moc undoManager] disableUndoRegistration];
	self.account = [NSEntityDescription insertNewObjectForEntityForName:@"TwitterAccount"
																							 inManagedObjectContext:moc];
	[moc processPendingChanges];
	[[moc undoManager] enableUndoRegistration];
	
  return self;
}
- (id)init 
{
	if(![super init]) return nil;
	
	self.engine = [[[MGTwitterEngine alloc] initWithDelegate:self] autorelease];
	requests = [[NSMutableDictionary alloc] init];
	
	return self;
}
-(void)dealloc;
{
	self.account = self.engine = nil;
	[requests release];
	[super dealloc];
}

- (NSString *)windowNibName 
{
	return @"SelectweetUserDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController 
{
	[super windowControllerDidLoadNib:windowController];
	[progress_spinner startAnimation:nil];
	[tweets setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO]]];
}
-(void)awakeFromNib;
{
	[self performSelector:@selector(tryToLogin) withObject:nil afterDelay:0];
}

- (void)close;
{
	self.refreshTimer = nil;
	[super close];
}

#pragma mark
#pragma mark CoreData stuff

@synthesize account;
- (NSManagedObject *)account
{
	if (account != nil) {
		return account;
	}
	
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSError *fetchError = nil;
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"TwitterAccount"
																						inManagedObjectContext:moc];
	
	[fetchRequest setEntity:entity];
	NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:&fetchError];
	
	if ((fetchResults != nil) && ([fetchResults count] == 1) && (fetchError == nil)) {
		self.account = [fetchResults objectAtIndex:0];
		return account;
	}
	
	if (fetchError != nil) {
		[self presentError:fetchError];
	}
	else {
		NSRunAlertPanel(@"Couldn't find an account object", @"Can't continue, this is broken.", @"OK", nil, nil);
	}
	return nil;
}

#pragma mark 
#pragma mark Actions and UI
-(void)showLoginWindow;
{
	self.refreshTimer = nil;
	
	[NSApp beginSheet:loginWindow
 		 modalForWindow:[[self.windowControllers objectAtIndex:0] window]
			modalDelegate:nil
		 didEndSelector:NULL
	   		contextInfo:NULL];

	
	[login_cancelButton setBlockAction:^ {
		[loginWindow orderOut:nil];
		[NSApp endSheet:loginWindow];
		[self close];
	}];
	
	[login_loginButton setBlockAction:^ {
		[loginWindow orderOut:nil];
		[NSApp endSheet:loginWindow];
		[self tryToLogin];
	}];
}

-(void)tryToLogin;
{
	if(!self.account.username || !self.account.password) {
		[self showLoginWindow];
		return;
	}
	[engine setUsername:self.account.username password:self.account.password];
	
	[NSApp beginSheet:progressWindow
		 modalForWindow:[[self.windowControllers objectAtIndex:0] window]
			modalDelegate:nil
		 didEndSelector:NULL
				contextInfo:NULL];
	
	[self handleRequest:[engine checkUserCredentials]
		success:^ {
			[progressWindow orderOut:nil];
			[NSApp endSheet:progressWindow];
			[self scheduleRefreshTimer];
			[self loadTweets:nil];
			return YES;
		}
		receive:nil
		failure:^(NSError *arg1) {
			[NSApp presentError:arg1];
			[progressWindow orderOut:nil];
			[NSApp endSheet:progressWindow];
			return NO;
		}
	];
}

#pragma mark 
#pragma mark Loading tweets

@synthesize refreshTimer;
-(void)setRefreshTimer:(NSTimer *)newTimer;
{
	if(newTimer == refreshTimer) return;
	[refreshTimer invalidate]; [refreshTimer release];
	[newTimer retain]; refreshTimer = newTimer;
}
-(void)scheduleRefreshTimer;
{
	self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:refreshInterval target:self selector:@selector(loadTweets:) userInfo:nil repeats:YES];
}

-(IBAction)loadTweets:(id)sender;
{
	unsigned long long since = [Tweet latestTweetInContext:[self managedObjectContext]].ident.unsignedLongLongValue;
	NSLog(@"Loading tweets newer than %llu", since);
	[engine getFollowedTimelineSinceID:since
											 withMaximumID:0
											startingAtPage:0
															 count:0];
	
	
	if(self.refreshTimer) {
		// If we were run manually, we don't need to run until in refreshInterval seconds again, so reschedule
		[self scheduleRefreshTimer];
	}
}
#pragma mark 
#pragma mark MGTwitter callbacks

-(void)handleRequest:(NSString*)requestID
						 success:(BOOL(^)())success 
						 receive:(BOOL(^)(NSArray*))receive
						 failure:(BOOL(^)(NSError*))failure;
{
	[requests setObject:[TCMGHandler success:success receive:receive failure:failure] forKey:requestID];
}

- (void)requestSucceeded:(NSString *)connectionIdentifier;
{
	TCMGHandler *handler = [requests objectForKey:connectionIdentifier];
	if(handler && handler.successHandler) handler.successHandler();
}
- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error;
{
	TCMGHandler *handler = [requests objectForKey:connectionIdentifier];
	
	// If there's an error handler and it handles the error, do nothing.
	if(handler && handler.failureHandler && handler.failureHandler(error))
		return;
	else { // Else, handle the error globally.
	
		// Specially handled errors
		if(error.code == 401) { // Unauthorized
			[self showLoginWindow];
		} else // Generic error fallback
			[NSApp presentError:error];
	}
	
}
- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier;
{
	TCMGHandler *handler = [requests objectForKey:connectionIdentifier];
	if(handler && handler.receiveHandler && handler.receiveHandler(statuses)) {
		// Handler told us to not act on this, so don't.
	}	else {
		// These are implicitly "saved" into the moc by being created
		[statuses tcMap:^(id status) {
			return (id)[Tweet tweetWithObjectValue:status inContext:[self managedObjectContext]];
		}];
	}
}
- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)connectionIdentifier;
{
	TCMGHandler *handler = [requests objectForKey:connectionIdentifier];
	if(handler && handler.receiveHandler) handler.receiveHandler(messages);	
}
- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier;
{
	TCMGHandler *handler = [requests objectForKey:connectionIdentifier];
	if(handler && handler.receiveHandler) handler.receiveHandler(userInfo);	
}
- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)connectionIdentifier;
{
	TCMGHandler *handler = [requests objectForKey:connectionIdentifier];
	if(handler && handler.receiveHandler) handler.receiveHandler(miscInfo);	
}
- (void)connectionFinished:(NSString *)connectionIdentifier;
{
	[requests removeObjectForKey:connectionIdentifier];
}


@end
