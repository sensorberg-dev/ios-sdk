//
//  SBReminder.m
//  Pods
//
//  Created by Andrei Stoleru on 31/08/15.
//
//

#import "SBScheduler.h"

#import "SBUtility.h"

emptyImplementation(SBMNotification)

@interface SBScheduler() {
    NSMutableDictionary *timers;
}

@end

@implementation SBScheduler

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:5];
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(application:didFinishLaunchingWithOptions:) name:UIApplicationDidFinishLaunchingNotification object:nil];
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        //
        timers = [NSMutableDictionary new];
    }
    return self;
}

- (void)addNotification:(SBMNotification*)notification {
    //
    NSTimer *timer = [[NSTimer alloc] initWithFireDate:notification.date
                                              interval:.5
                                                target:self
                                              selector:@selector(performInvocation:) userInfo:notification.key
                                               repeats:notification.isRepeating];
    //
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    //
    NSLog(@"timer: %@",timer);
    //
    [timers setValue:timer forKey:notification.key];
}

- (void)getNotifications {
    NSLog(@"%s: %@",__func__,timers);
}

#pragma mark - Scheduler events

- (BOOL)performInvocation:(SBMNotification*)notification {
    NSLog(@"%s",__func__);
    return YES;
}

#pragma mark - UIApplication events

- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"%s",__func__);
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"%s",__func__);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"%s",__func__);
    //
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"%s",__func__);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"%s",__func__);
}

@end
