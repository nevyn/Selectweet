//
//  Tweeter.m
//  Selectweet
//
//  Created by Joachim Bengtsson on 2009-10-28.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "Tweeter.h"
#import <objc/runtime.h>
#import "Massage.h"

@implementation Tweeter
@dynamic created_at, name, screen_name, ident, profile_image_url;

+(NSEntityDescription*)descriptionInContext:(NSManagedObjectContext*)moc;
{
	return [NSEntityDescription entityForName:NSStringFromClass(self) inManagedObjectContext:moc];
}

+(Tweeter*)findOrCreateByID:(long long)ident inContext:(NSManagedObjectContext*)moc;
{
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];	
	[fetchRequest setEntity:[Tweeter descriptionInContext:moc]];
	[fetchRequest setFetchLimit:1];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"ident = %@", [NSNumber numberWithLongLong:ident]]];
	
	NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:nil];
	
	if ((fetchResults != nil) && ([fetchResults count] == 1))
		return [fetchResults objectAtIndex:0];
	else {
		Tweeter *tw = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:moc];
		[tw setValue:[NSNumber numberWithLongLong:ident] forKey:@"ident"];
		return tw;
	}
}
+(NSDictionary*)massageObjectValue:(NSDictionary*)rep;
{
	NSMutableDictionary *rep1 = [NSMutableDictionary dictionaryWithDictionary:rep];
	[rep1 removeObjectForKey:@"id"];

	return rep1;
}
+(Tweeter*)tweeterWithObjectValue:(NSDictionary*)rep0 inContext:(NSManagedObjectContext*)moc;
{
	Tweeter *tweeter = [self findOrCreateByID:[[rep0 objectForKey:@"id"] longLongValue] inContext:moc];
	
	NSDictionary *rep = [Tweeter massageObjectValue:rep0];

	unsigned count = 0;
	objc_property_t *props = class_copyPropertyList([self class], &count);
	for(int i = 0; i < count; i++) {
		NSString *name = [NSString stringWithCString:property_getName(props[i]) encoding:NSUTF8StringEncoding];
		if( ! [name isEqual:@"ident"] )
			[tweeter setValue:[rep objectForKey:name] forKey:name];
	}
	free(props);

	
	return tweeter;
}
@end
