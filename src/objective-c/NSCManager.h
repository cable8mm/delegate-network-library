#import <Foundation/Foundation.h>

@class NSCManager;
@protocol NSCManagerDelegate
@optional
- (void) nscmanager:(NSString*)tag didReceiveResponse:(NSURLResponse*)response;
- (void) nscmanager:(NSString*)tag didReceiveData:(NSData *)data;
- (void) nscmanager:(NSString*)tag didFailWithError:(NSError*)error;
- (void) nscmanager:(NSString*)tag resultDidFinishLoading:(id)result;
@end

@interface NSCManager : NSObject <NSURLConnectionDelegate>
{
    id <NSCManagerDelegate> delegate;
    NSUInteger expectedBytes;
    NSUInteger receivedBytes;
    NSString *post;
}

@property (nonatomic) id <NSCManagerDelegate> delegate;
@property (nonatomic) NSUInteger expectedBytes;
@property (nonatomic) NSUInteger receivedBytes;
@property (nonatomic) NSString *post;

+ (NSCManager*)createWithParams:(NSString*)api param:(NSString*)params delegate:(id<NSCManagerDelegate>)delegate result:(NSString*)key;
+ (NSCManager*)createWithParams:(NSString*)api param:(NSString*)params delegate:(id<NSCManagerDelegate>)delegate;
+ (NSCManager*)createWithParams:(NSString*)api param:(NSString*)params post:(NSString*)post delegate:(id<NSCManagerDelegate>)delegate;
+ (NSCManager*)createWithRawParams:(NSString*)api param:(NSString*)params delegate:(id<NSCManagerDelegate>)delegate result:(NSString*)key;
+ (NSCManager*)createWithRawParams:(NSString*)api param:(NSString*)params delegate:(id<NSCManagerDelegate>)delegate;
- (void)execute;
- (void)cancel;
@end
