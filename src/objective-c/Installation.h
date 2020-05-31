#import <Foundation/Foundation.h>

@interface Installation : NSObject
+ (Installation*)sharedObject;
- (NSString *)getDeviceId;
- (void) saveSession:(NSString *)ask id:(NSString*)aid;
- (BOOL) hasSession;
- (NSString *) getAid;
- (NSString *) getAsk;
@end
