#import "NSCManager.h"
#import "Installation.h"
#import "NSString+MD5.h"

@interface NSCManager ()
@property (nonatomic, retain) NSString *api;
@property (nonatomic, retain) NSString *params;
@property (nonatomic, retain) NSString *tag;
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSURLConnection *urlConnection;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic) BOOL isAutoParams;
@end

@implementation NSCManager

@synthesize delegate;
@synthesize expectedBytes;
@synthesize receivedBytes;
@synthesize post;

+ (NSCManager*)createWithParams:(NSString*)api param:(NSString*)params delegate:(id<NSCManagerDelegate>)delegate result:(NSString*)key
{
    NSCManager *instance    = [[NSCManager alloc] init];
    instance.api            = api;
    instance.params         = params;
    instance.delegate       = delegate;
    instance.tag            = api;
    instance.key            = key;
    instance.isAutoParams   = YES;
    instance.post           = nil;
    
    return instance;
}

+ (NSCManager*)createWithParams:(NSString*)api param:(NSString*)params post:(NSString*)post delegate:(id<NSCManagerDelegate>)delegate {
    NSCManager *instance    = [NSCManager createWithParams:api param:params delegate:delegate result:nil];
    instance.post   = post;
    return instance;
}

+ (NSCManager*)createWithParams:(NSString*)api param:(NSString*)params delegate:(id<NSCManagerDelegate>)delegate
{
    return [NSCManager createWithParams:api param:params delegate:delegate result:nil];
}

+ (NSCManager*)createWithRawParams:(NSString*)api param:(NSString*)params delegate:(id<NSCManagerDelegate>)delegate result:(NSString*)key
{
    NSCManager *instance    = [NSCManager createWithParams:api param:params delegate:delegate result:key];
    instance.isAutoParams   = NO;
    
    return instance;
}

+ (NSCManager*)createWithRawParams:(NSString*)api param:(NSString*)params delegate:(id<NSCManagerDelegate>)delegate
{
    return [NSCManager createWithRawParams:api param:params delegate:delegate result:nil];
}

- (void)execute
{
    self.receivedBytes  = 0;
    NSMutableString *urlString;
    if (self.params == nil) {
        urlString = [NSMutableString stringWithFormat:@"%@%@?", API_SERVER_PREFIX, self.api];
    } else {
        urlString = [NSMutableString stringWithFormat:@"%@%@?%@&", API_SERVER_PREFIX, self.api, self.params];
    }
    
    if (self.isAutoParams == YES) {
        NSDate *date = [NSDate date];
        NSString * timeInMS = [NSString stringWithFormat:@"%lld", [@(floor([date timeIntervalSince1970] * 1000)) longLongValue]];

        NSString *s = [NSCManager getSecurityKey:timeInMS];
        [urlString appendString:[NSString stringWithFormat:@"s=%@&aid=%@&t=%@", s, [[Installation sharedObject] getAid], timeInMS]];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    
    if (self.post != nil) {
        
        NSData *postData = [self.post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
    }
    
    self.urlConnection  = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.urlConnection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                  forMode:NSRunLoopCommonModes];
    [self.urlConnection start];
}

+ (NSString*)getSecurityKey:(NSString*)timeInMS
{
    NSString *rowString = [NSString stringWithFormat:@"%@%@%@", [[Installation sharedObject] getAsk], [[Installation sharedObject] getAid], timeInMS];
    return [[rowString MD5] uppercaseString];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
//    [self.receivedData setLength:0];
    self.expectedBytes  = (NSUInteger)response.expectedContentLength;
    self.receivedData   = [NSMutableData dataWithCapacity:self.expectedBytes];
    if ([(NSObject*)self.delegate respondsToSelector:@selector(nscmanager:didReceiveResponse:)]) {
        [self.delegate nscmanager:self.tag didReceiveResponse:response];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(id)data
{
    [self.receivedData appendData:data];
    self.receivedBytes = self.receivedData.length;
    if ([(NSObject*)self.delegate respondsToSelector:@selector(nscmanager:didReceiveData:)]) {
        [self.delegate nscmanager:self.tag didReceiveData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.urlConnection = nil;
    self.receivedData = nil;
    
    if ([(NSObject*)self.delegate respondsToSelector:@selector(nscmanager:didFailWithError:)]) {
        [self.delegate nscmanager:self.tag didFailWithError:error];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([(NSObject*)self.delegate respondsToSelector:@selector(nscmanager:resultDidFinishLoading:)]) {
        NSError *error;
        NSDictionary *result  = [NSJSONSerialization
                                 JSONObjectWithData:self.receivedData
                                 options:NSJSONReadingAllowFragments
                                 error:&error];
        
        if (error) {
            [self.delegate nscmanager:self.tag resultDidFinishLoading:nil];
            return;
        }
        
        if (self.key == nil) {
            [self.delegate nscmanager:self.tag resultDidFinishLoading:result];
        } else {
            [self.delegate nscmanager:self.tag resultDidFinishLoading:result[self.key]];
        }
    }
    
    self.urlConnection = nil;
    self.receivedData = nil;
}

- (void)cancel
{
    [self.urlConnection cancel];
}
@end
