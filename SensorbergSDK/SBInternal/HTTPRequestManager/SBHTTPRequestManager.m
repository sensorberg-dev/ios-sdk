//
//  SBHTTPRequestManager.m
//  SensorbergSDK
//
//  Copyright (c) 2014-2016 Sensorberg GmbH. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "SBHTTPRequestManager.h"

#if !TARGET_OS_WATCH
#import <SystemConfiguration/SystemConfiguration.h>

#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#pragma mark - Constants

NSString * SBDefaultCertificateFileName = @"SensorbergSSL";
NSString * SBDefaultCertificateFileExtention = @"cer";

typedef void (^SBNetworkReachabilityStatusBlock)(SBNetworkReachability status);

static const void * SBNetworkReachabilityRetainCallback(const void *info) {
    return Block_copy(info);
}

static void SBNetworkReachabilityReleaseCallback(const void *info) {
    if (info) {
        Block_release(info);
    }
}

static void SBPostReachabilityStatusChange(SCNetworkReachabilityFlags flags, SBNetworkReachabilityStatusBlock block) {

    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
    
    SBNetworkReachability status = SBNetworkReachabilityUnknown;
    if (isNetworkReachable == NO) {
        status = SBNetworkReachabilityNone;
    }
#if	TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0)
    {
        status = SBNetworkReachabilityViaWWAN;
    }
#endif
    else
    {
        status = SBNetworkReachabilityViaWiFi;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block)
        {
            block(status);
        }
    });
}

static void SBNetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    SBPostReachabilityStatusChange(flags, (__bridge SBNetworkReachabilityStatusBlock)info);
}

#pragma mark - SBInternalNetworkRequestOperation

@interface SBInternalSBHTTPRequestOperation : NSOperation
@property (nonnull, nonatomic, strong) NSURLRequest *request;
@property (nullable, nonatomic, readonly, strong) NSURLSession *session;
@property (nullable, nonatomic, copy) void (^completion)(NSData * __nullable data, NSError * __nullable error);

- (instancetype)initWithURLRequest:(NSURLRequest *)request session:(NSURLSession *)session
                        completion:(nonnull void (^)(NSData * __nullable data, NSError * __nullable error))completionHandler;
@end

@implementation SBInternalSBHTTPRequestOperation
@synthesize finished = _isFinished;
@synthesize executing = _isExecuting;

- (instancetype)initWithURLRequest:(NSURLRequest *)request session:(NSURLSession * _Nonnull)session
                        completion:(nonnull void (^)(NSData * __nullable data, NSError * __nullable error))completionHandler
{
    if (self = [super init])
    {
        _request = request;
        _completion = completionHandler;
        _session = session;
    }
    
    return self;
}

- (void)main
{
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:self.request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (self.completion)
        {
            if (!error && [response respondsToSelector:@selector(statusCode)])
            {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                if (httpResponse.statusCode >= 400)
                {
                    error = [NSError errorWithDomain:NSURLErrorDomain code:httpResponse.statusCode userInfo:@{@"reason" : [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]}];
                }
            }
            
            self.completion(data, error);
        }
        [self finish];
    }];
    if (task)
    {
        [task resume];
    }
    else
    {
        if (self.completion)
        {
            self.completion(nil, [NSError errorWithDomain:NSURLErrorDomain
                                                     code:NSURLErrorUnknown
                                                 userInfo:@{@"reason": NSLocalizedString(@"Cannot create URL Session Data Task", nil)}]);
        }
        [self finish];
    }
}

- (void)finish
{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = NO;
    _isFinished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end

#pragma mark - SBHTTPRequestManager
#pragma mark - Internal

@interface SBHTTPRequestManager () <NSURLSessionDelegate>

@property (nonatomic, strong) NSOperationQueue * _Nonnull operationQueue;
@property (readwrite, nonatomic, assign) SBNetworkReachability reachabilityStatus;
@property (readwrite, nonatomic, strong) id networkReachability;
@property (nonnull, nonatomic, strong) NSURLSession *urlSession;
@end


#pragma mark -

@implementation SBHTTPRequestManager

#pragma mark - Static Interfaces

+ (instancetype _Nonnull)sharedManager
{
    static dispatch_once_t once;
    static SBHTTPRequestManager *_sharedManager = nil;
    
    dispatch_once(&once, ^{
        _sharedManager = [SBHTTPRequestManager new];
        
    });
    
    return _sharedManager;
}

#pragma mark - Class Interfaces For Certificate File.

+ (nonnull NSString *)fileName
{
    return [SBDefaultCertificateFileName copy];
}

+ (nonnull NSString *)fileExtention
{
    return [SBDefaultCertificateFileExtention copy];
}

+ (NSString *)filePath
{
    static NSString *documentPath;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSArray *appSupportDir = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        documentPath = appSupportDir.firstObject;
        documentPath = [documentPath stringByAppendingPathComponent:@".certificate"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:documentPath])
        {
            NSError *error = nil;
            [fileManager createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:&error];
            if (error)
            {
                NSLog(@"Failed to create certificate folder : %@", error);
            }
        }
    });
    
    return [[documentPath stringByAppendingPathComponent:[self fileName]] stringByAppendingPathExtension:[self fileExtention]];
}

+ (BOOL)checkAndCopyInitialCertificate
{
    if ([self fileName].length == 0)
    {
        return NO;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [self filePath];
    if (![fileManager fileExistsAtPath:filePath])
    {
        NSString *initialFilePath = [[NSBundle mainBundle] pathForResource:[self fileName] ofType:[self fileExtention]];
        NSData *certificateData = [NSData dataWithContentsOfFile:initialFilePath];
        NSLog(@"Initial Certificate File path : %@", initialFilePath);
        NSLog(@"Target Certificate File path : %@", filePath);
        NSError *writingFileError = nil;
        if (!certificateData || ![certificateData writeToFile:filePath options:NSDataWritingAtomic error:&writingFileError])
        {
            // error
            NSLog(@"Failed to write certificate file.\nError : %@", writingFileError ? : @"No Data to wrtie");
            return NO;
        }
    }
    
    return YES;
}

+ (void)updateCertificateDataFromBundle:(BOOL)force
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSString *currentFileVersion = [[NSUserDefaults standardUserDefaults] objectForKey:[self fileName]];
    
    if (force || ![version isEqualToString:currentFileVersion])
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *filePath = [[self class] filePath];
        [fileManager removeItemAtPath:filePath error:nil];
        
        if ([self checkAndCopyInitialCertificate])
        {
            [[NSUserDefaults standardUserDefaults] setObject:version forKey:[self fileName]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

+ (void)updateCertificateDataWithData:(NSData * _Nonnull)data
{
    if (!data)
    {
        return;
    }
    
    [data writeToFile:[self filePath] atomically:YES];
}

#pragma mark - Instance Life Cycle

- (instancetype)init
{
    if (self = [super init])
    {
        struct sockaddr_in address;
        bzero(&address, sizeof(address));
        address.sin_len = sizeof(address);
        address.sin_family = AF_INET;
        
        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&address);
        _networkReachability = CFBridgingRelease(reachability);
        _reachabilityStatus = SBNetworkReachabilityUnknown;
        
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
        _operationQueue.qualityOfService = NSQualityOfServiceUserInitiated;
        
        NSURLSessionConfiguration *cacheConfiguration = [[NSURLSessionConfiguration defaultSessionConfiguration] copy];
        cacheConfiguration.requestCachePolicy = NSURLRequestReturnCacheDataElseLoad;
        self.urlSession = [NSURLSession sessionWithConfiguration:cacheConfiguration delegate:self delegateQueue:nil];
        
        [self startMonitoring];
        [[self class] updateCertificateDataFromBundle:NO];
    }
    
    return self;
}

- (void)dealloc
{
    [self stopMonitoring];
}

#pragma mark - Public Interfaces

- (void)getDataFromURL:(nonnull NSURL *)URL
          headerFields:(nullable NSDictionary *)header
              useCache:(BOOL)useCache
            completion:(void (^)(NSData * __nullable data, NSError * __nullable error))completionHandler;
{
    NSMutableURLRequest *URLRequest = [NSMutableURLRequest requestWithURL:URL];
    URLRequest.HTTPMethod = @"GET";
    [self setHeaderFields:header forURLRequest:URLRequest];
    URLRequest.cachePolicy = useCache ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringCacheData;
    
    SBInternalSBHTTPRequestOperation *networkRequestOperation = [[SBInternalSBHTTPRequestOperation alloc] initWithURLRequest:URLRequest session:self.urlSession completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (completionHandler)
        {
            completionHandler(data, error);
        }
    }];
    [self.operationQueue addOperation:networkRequestOperation];
}

- (void)postData:(NSData *)data URL:(nonnull NSURL *)URL
    headerFields:(NSDictionary *)header
      completion:(void (^)(NSData * __nullable data, NSError * __nullable error))completionHandler
{
    NSMutableURLRequest *URLRequest = [NSMutableURLRequest requestWithURL:URL];
    URLRequest.HTTPMethod = @"POST";
    URLRequest.HTTPBody = data;
    URLRequest.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    [self setHeaderFields:header forURLRequest:URLRequest];
    SBInternalSBHTTPRequestOperation *networkRequestOperation = [[SBInternalSBHTTPRequestOperation alloc] initWithURLRequest:URLRequest session:self.urlSession completion:^(NSData * _Nullable responseData, NSError * _Nullable error) {
        if (completionHandler)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(responseData, error);
            });
        }
    }];
    
    [self.operationQueue addOperation:networkRequestOperation];
}

#pragma mark - Private Interfaces

- (void)setHeaderFields:(nonnull NSDictionary *)header forURLRequest:(nonnull NSMutableURLRequest *)URLRequest
{
    if (header && [header isKindOfClass:[NSDictionary class]])
    {
        for (NSString *key in header.allKeys)
        {
            id valueForKey = header[key];
            if ([valueForKey isKindOfClass:[NSString class]]) {
                [URLRequest setValue:valueForKey forHTTPHeaderField:key];
            }
        }
    }
}

#pragma mark - <NSURLSessionDelegate>


-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    if (!completionHandler)
    {
        return;
    }
    
    if (!self.useCertificatePinning)
    {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, NULL);
        return;
    }
    
    // Get remote certificate
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, 0);
    
    // Set SSL policies for domain name check
    NSMutableArray *policies = [NSMutableArray array];
    [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)challenge.protectionSpace.host)];
    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
    
    // Evaluate server certificate
    SecTrustResultType result;
    SecTrustEvaluate(serverTrust, &result);
    BOOL certificateIsValid = (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
    
    // Get local and remote cert data
    NSData *remoteCertificateData = CFBridgingRelease(SecCertificateCopyData(certificate));
    NSData *localCertificate = [NSData dataWithContentsOfFile:[[self class] filePath]];
    
    // The pinnning check
    if ([remoteCertificateData isEqualToData:localCertificate] && certificateIsValid)
    {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
    else
    {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, NULL);
    }
}

#pragma mark - Network Reachability

- (BOOL)isReachable
{
    return self.reachabilityStatus == SBNetworkReachabilityViaWWAN || self.reachabilityStatus == SBNetworkReachabilityViaWiFi;
}

- (void)startMonitoring
{
    [self stopMonitoring];
    
    if (self.networkReachability)
    {
        __weak __typeof(self)weakSelf = self;
        SBNetworkReachabilityStatusBlock callback = ^(SBNetworkReachability status)
        {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            strongSelf.reachabilityStatus = status;
        };
        
        id networkReachability = self.networkReachability;
        SCNetworkReachabilityContext context = {0, (__bridge void *)callback, SBNetworkReachabilityRetainCallback, SBNetworkReachabilityReleaseCallback, NULL};
        SCNetworkReachabilitySetCallback((__bridge SCNetworkReachabilityRef)networkReachability, SBNetworkReachabilityCallback, &context);
        SCNetworkReachabilityScheduleWithRunLoop((__bridge SCNetworkReachabilityRef)networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
            SCNetworkReachabilityFlags flags;
            if (SCNetworkReachabilityGetFlags((__bridge SCNetworkReachabilityRef)networkReachability, &flags)) {
                SBPostReachabilityStatusChange(flags, callback);
            }
        });
    }
}

- (void)stopMonitoring
{
    if (self.networkReachability)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop((__bridge SCNetworkReachabilityRef)self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    }
}

@end

#endif
