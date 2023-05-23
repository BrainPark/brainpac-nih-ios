// Created 5/23/23
// swift-tools-version:5.0

#import "BrainPACUnity.h"

#include <UnityFramework/UnityFramework.h>
#include <UnityFramework/NativeCallProxy.h>

BrainPACGame const BrainPACGameBalloons = @"BART";
BrainPACGame const BrainPACGameDragon = @"SST";

UnityFramework* UnityFrameworkLoad()
{
    NSString* bundlePath = nil;
    bundlePath = [[NSBundle mainBundle] bundlePath];
    bundlePath = [bundlePath stringByAppendingString: @"/Frameworks/UnityFramework.framework"];
    
    NSBundle* bundle = [NSBundle bundleWithPath: bundlePath];
    if ([bundle isLoaded] == false) [bundle load];
    
    UnityFramework* ufw = [bundle.principalClass getInstance];
    if (![ufw appController])
    {
        // unity is not initialized
        [ufw setExecuteHeader: &_mh_execute_header];
    }
    return ufw;
}

@interface BrainPACUnity () <UnityFrameworkListener, NativeCallsProtocol>

@property (nullable, nonatomic, strong) UnityFramework* ufw;
@property (nonatomic) bool didQuit;

@end

@implementation BrainPACUnity

+ (instancetype)sharedManager {
    static BrainPACUnity *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        // Cannot rely upon requiring this library to use this class as the app delegate. Instead, listen for state changes.
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                          object:nil queue:nil
                                                      usingBlock:^(NSNotification * _Nonnull note) {
            if ([self unityIsInitialized]) {
                [[[self ufw] appController] applicationWillEnterForeground: [UIApplication sharedApplication]];
            }
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                          object:nil queue:nil
                                                      usingBlock:^(NSNotification * _Nonnull note) {
            if ([self unityIsInitialized]) {
                [[[self ufw] appController] applicationDidBecomeActive: [UIApplication sharedApplication]];
            }
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification
                                                          object:nil queue:nil
                                                      usingBlock:^(NSNotification * _Nonnull note) {
            if ([self unityIsInitialized]) {
                [[[self ufw] appController] applicationWillResignActive: [UIApplication sharedApplication]];
            }
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                          object:nil queue:nil
                                                      usingBlock:^(NSNotification * _Nonnull note) {
            if ([self unityIsInitialized]) {
                [[[self ufw] appController] applicationDidEnterBackground: [UIApplication sharedApplication]];
            }
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification
                                                          object:nil queue:nil
                                                      usingBlock:^(NSNotification * _Nonnull note) {
            if ([self unityIsInitialized]) {
                [[[self ufw] appController] applicationWillTerminate: [UIApplication sharedApplication]];
            }
        }];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[self ufw] unregisterFrameworkListener: self];
    [[self ufw] unloadApplication];
    self.ufw = nil;
}

- (NSArray <BrainPACGame> *)allGames {
    return @[
        BrainPACGameBalloons,
        BrainPACGameDragon,
    ];
}

- (BOOL)show:(BrainPACGame)game fromWindow:(UIWindow*)window error:(NSError **)error {
    
    // If Unity has been quit, it cannot be restarted.
    if (self.didQuit) {
        if (error != NULL) {
            NSDictionary *errorDictionary = @{
                NSLocalizedDescriptionKey : @"Cannot restart Unity after it has been quit."
            };
            *error = [[NSError alloc] initWithDomain:@"BrainPACErrorDomain"
                    code:-99 userInfo:errorDictionary];
        }
        return false;
    }
    
    // Set the current game
    self.currentGame = game;
    self.hostMainWindow = window;
    [self initUnityIfNeeded];
    [[self ufw] sendMessageToGOWithName: "GameManager" functionName: "LoadGame" message: game.UTF8String];
    [[self ufw] showUnityWindow];
    
    return true;
}

- (void)onSessionComplete:(NSString*)message {
    //... callback code goes here
    // TODO: syoung 05/23/2023 - Figure out what I am suppose to do with this.
    NSLog(@"onSessionComplete called: %@", message);
}

- (void)showHostMainWindow {
    [[self hostMainWindow] makeKeyAndVisible];
}

- (bool)unityIsInitialized {
    return (self.hostMainWindow != nil) && (self.ufw != nil) && (self.ufw.appController != nil);
}

- (void)initUnityIfNeeded {
    // Exit early if already initialized.
    if (self.unityIsInitialized) {
        return;
    }

    self.ufw = UnityFrameworkLoad();
    [[self ufw] setDataBundleId: "com.unity3d.framework"];
    [[self ufw] registerFrameworkListener: self];
    [NSClassFromString(@"FrameworkLibAPI") registerAPIforNativeCalls:self];

    // syoung 05/23/2023 No idea what this doing - it crashes the app.
    [[self ufw] runEmbeddedWithArgc: 0 argv: nullptr appLaunchOpts: nil];
    
    // set quit handler to change default behavior of exit app
    [[self ufw] appController].quitHandler = ^(){ NSLog(@"AppController.quitHandler called"); };
}

// TODO: syoung 05/24/2023 When, if ever, should the framework be unloaded or quit?
//- (void)unloadButtonTouched:(UIButton *)sender
//{
//    if(![self unityIsInitialized]) {
//        showAlert(@"Unity is not initialized", @"Initialize Unity first");
//    } else {
//        [UnityFrameworkLoad() unloadApplication];
//    }
//}
//
//- (void)quitButtonTouched:(UIButton *)sender
//{
//    if(![self unityIsInitialized]) {
//        showAlert(@"Unity is not initialized", @"Initialize Unity first");
//    } else {
//        [UnityFrameworkLoad() quitApplication:0];
//    }
//}

- (void)unityDidUnload:(NSNotification*)notification
{
    NSLog(@"unityDidUnload called");

    [[self ufw] unregisterFrameworkListener: self];
    self.ufw = nil;
    [self showHostMainWindow];
}

- (void)unityDidQuit:(NSNotification*)notification
{
    NSLog(@"unityDidQuit called");

    [[self ufw] unregisterFrameworkListener: self];
    self.ufw = nil;
    self.didQuit = true;
    [self showHostMainWindow];
}

@end
