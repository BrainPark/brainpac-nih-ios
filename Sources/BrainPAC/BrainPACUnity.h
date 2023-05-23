// Created 5/23/23
// swift-tools-version:5.0

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if defined(__cplusplus)
#  define ENUM_EXTERN extern "C" __attribute__((visibility("default")))
#else
#  define ENUM_EXTERN extern __attribute__((visibility("default")))
#endif

NS_ASSUME_NONNULL_BEGIN

typedef NSString * BrainPACGame NS_TYPED_ENUM;

ENUM_EXTERN BrainPACGame const BrainPACGameBalloons;
ENUM_EXTERN BrainPACGame const BrainPACGameDragon;

@protocol BrainPACDelegate
@end

@interface BrainPACUnity : NSObject

@property (nonatomic, nullable) UIWindow* hostMainWindow;
@property (nonatomic, nullable, weak) id <BrainPACDelegate> delegate;
@property (nonatomic, nullable, strong) BrainPACGame currentGame;

+ (instancetype)sharedManager;

- (instancetype)init NS_UNAVAILABLE;

- (NSArray <BrainPACGame> *)allGames;
- (BOOL)show:(BrainPACGame)game fromWindow:(UIWindow*)window error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
