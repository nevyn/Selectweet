#define toid(x) ([x isEqual:@""] ? (id)nil : (id)[NSNumber numberWithLongLong:[x longLongValue]])
#define setid(k) { id v1 = toid([rep objectForKey:k]); if(v1) [rep1 setObject:v1 forKey:k]; else [rep1 removeObjectForKey:k]; }
