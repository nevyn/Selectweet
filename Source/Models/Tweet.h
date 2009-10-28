//
//  Tweet.h
//  Selectweet
//
//  Created by Joachim Bengtsson on 2009-10-28.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Tweeter;

@interface Tweet : NSManagedObject
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * favorited;
@property (nonatomic, retain) NSString * geo;
@property (nonatomic, retain) NSNumber * ident;
@property (nonatomic, retain) NSString * in_reply_to_screen_name;
@property (nonatomic, retain) NSNumber * in_reply_to_status_id;
@property (nonatomic, retain) NSString * in_reply_to_user_id;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * truncated;

+(Tweet*)latestTweetInContext:(NSManagedObjectContext*)moc;
+(Tweet*)tweetWithObjectValue:(NSDictionary*)rep inContext:(NSManagedObjectContext*)moc;

@end

@interface Tweet (TweetCoreDataAccessors)
-(Tweeter*)tweeter;
@end