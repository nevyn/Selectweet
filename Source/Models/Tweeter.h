//
//  Tweeter.h
//  Selectweet
//
//  Created by Joachim Bengtsson on 2009-10-28.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Tweeter : NSManagedObject
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * screen_name;
@property (nonatomic, retain) NSNumber * ident;
@property (nonatomic, retain) NSString * profile_image_url;

+(Tweeter*)tweeterWithObjectValue:(NSDictionary*)rep inContext:(NSManagedObjectContext*)moc;

@end

@interface Tweeter (TweeterCoreDataAccessors)
@property (nonatomic, retain) NSSet* tweets;
@end
