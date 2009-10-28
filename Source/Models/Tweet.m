//
//  Tweet.m
//  Selectweet
//
//  Created by Joachim Bengtsson on 2009-10-28.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "Tweet.h"
#import "Tweeter.h"
#import <objc/runtime.h>
#import "Massage.h"

@implementation Tweet
@dynamic created_at, favorited, geo, ident, in_reply_to_screen_name, in_reply_to_status_id, in_reply_to_user_id, source, text, truncated;

+(NSEntityDescription*)descriptionInContext:(NSManagedObjectContext*)moc;
{
	return [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:moc];
}

+(Tweet*)latestTweetInContext:(NSManagedObjectContext*)moc;
{
	NSError *fetchError = nil;
	
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];	
	[fetchRequest setEntity:[Tweet descriptionInContext:moc]];
	[fetchRequest setFetchLimit:1];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"ident" ascending:NO]]];
	
	NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:&fetchError];
	
	if ((fetchResults != nil) && ([fetchResults count] == 1) && (fetchError == nil))
		return [fetchResults objectAtIndex:0];
	
	return nil;
}
+(NSDictionary*)massageObjectValue:(NSDictionary*)rep;
{
	NSMutableDictionary *rep1 = [NSMutableDictionary dictionaryWithDictionary:rep];
	
	[rep1 setObject:toid([rep objectForKey:@"id"]) forKey:@"ident"];
	setid(@"in_reply_to_status_id");
	[rep1 setObject:[NSNumber numberWithBool:[[rep objectForKey:@"favorited"] isEqual:@"true"]] forKey:@"favorited"];
	
	return rep1;
}
+(Tweet*)tweetWithObjectValue:(NSDictionary*)rep0 inContext:(NSManagedObjectContext*)moc;
{
	NSDictionary *rep = [Tweet massageObjectValue:rep0];
	Tweet *tweet = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:moc];
	unsigned count = 0;
	objc_property_t *props = class_copyPropertyList([self class], &count);
	for(int i = 0; i < count; i++) {
		NSString *name = [NSString stringWithCString:property_getName(props[i]) encoding:NSUTF8StringEncoding];
		[tweet setValue:[rep objectForKey:name] forKey:name];
	}
	free(props);
	
	[tweet setValue:[Tweeter tweeterWithObjectValue:[rep objectForKey:@"user"] inContext:moc] forKey:@"tweeter"];
	
	NSLog(@"Got a tweet at ID %lld", tweet.ident.longLongValue);
	
	return tweet;
}

@end
