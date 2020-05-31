#import "Installation.h"

@interface Installation ()
@property (nonatomic, retain) NSString *ask;
@property (nonatomic, retain) NSString *aid;
@end

@implementation Installation

+ (Installation*)sharedObject
{
    static dispatch_once_t once;
    static Installation *sharedObject;
    dispatch_once(&once, ^{
        sharedObject = [[self alloc] init];
        // Session Initialize
        sharedObject.ask    = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_DEFAULTS_USER_ASK"];
        sharedObject.aid    = [[NSUserDefaults standardUserDefaults] stringForKey:@"USER_DEFAULTS_USER_AID"];
    });
    return sharedObject;
}

- (NSString *)getDeviceId
{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

- (void) saveSession:(NSString *)ask id:(NSString*)aid
{
    // "ask":"2eab6b12-07c9-4f87-98d7-ed5cb7380c43","aid":"16"
    
    self.ask    = ask;
    self.aid    = aid;
}

- (BOOL) hasSession
{
    if (self.ask == nil) {
        return NO;
    }
    
    if (self.aid == nil) {
        return NO;
    }
    
    return YES;
}

- (NSString *) getAid
{
    return self.aid;
}

- (NSString *) getAsk
{
    return self.ask;
}

- (void) setAsk:(NSString *)ask
{
    if (![ask isEqualToString:_ask]) {
        _ask    = ask;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:ask forKey:@"USER_DEFAULTS_USER_ASK"];
        [defaults synchronize];
    }
}

- (void) setAid:(NSString *)aid
{
    if (![aid isEqualToString:_aid]) {
        _aid    = aid;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:aid forKey:@"USER_DEFAULTS_USER_AID"];
        [defaults synchronize];
    }
}

@end
