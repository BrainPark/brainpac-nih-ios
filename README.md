# brainpac-nih-ios

The [BrainPark Assessment of Cognition (BrainPAC) Project](http://www.brainpark.com/projects/brain-pac) aims to develop a one-of-a-kind electronic battery with industry partners (Torus Games), which is informed by neuroscience, engaging, and clinically useful for the assessment and monitoring of individuals across the spectrum of impulsive-compulsive disorders.

This Swift package contains two of the games, BART (balloons game) and SST (dragon game), and can be integrated into the Mobile Toolbox developed by [@Sage-Bionetworks](https://github.com/Sage-Bionetworks).

## Installation

As this is a private package, you will need to add your GitHub or GitHub Enterprise account in Xcode’s preferences. Then, select File > Swift Packages > Add Package Dependency and search for "brainpac-nih-ios".

Once the package has been added, select your target and under General > Frameworks, Libraries and Embedded Content, add UnityFramework.framework. Then, navigate to Build Phases > Build Binary with Libraries and remove UnityFramework.framework.

## Usage

 > The following code is in Obj-C. Use a bridging header for Swift integration.

Initialise the `UnityFramework` by including the headers and getting the singleton instance:

```objc
#include <UnityFramework/UnityFramework.h>
//...
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
```

You can set an object to listen to Unity events using the following methods:

```objc
// Register listener
[[self ufw] registerFrameworkListener: self];
// Unregister listener
[[self ufw] unregisterFrameworkListener: self];
```

To run Unity when other Views exist, call the following method (see [Unity docs](https://docs.unity3d.com/Manual/UnityasaLibrary-iOS.html) for more info):

```objc
[[self ufw] runEmbeddedWithArgc: gArgc argv: gArgv appLaunchOpts: appLaunchOpts];
```

You can now show a Unity view whilst a non-Unity view is showing:

```objc
[[self ufw] showUnityWindow];
```

To load a specific game, you can call the following method, which sends a message to the GameManager to execute the LoadGame function with either "BART" or "SST":

```obj-c
[[self ufw] sendMessageToGOWithName: "GameManager" functionName: "LoadGame" message: "BART"];
```

> NOTE: You can call the above method after UnityFramework is initialised, before `runEmbeddedWithArgc`.

With the `NativeCallProxy`, you can set a callback that executes upon a participant completing a session. To do this, conform to the `NativeCallsProtocol` and implement the following methods:

```objc
#include <UnityFramework/UnityFramework.h>
#include <UnityFramework/NativeCallProxy.h>
//...
@interface AppDelegate : UIResponder<UIApplicationDelegate, UnityFrameworkListener, NativeCallsProtocol>
@property UnityFramework* ufw;
//...
@end
//...
@implementation AppDelegate
//...
- (void)onSessionComplete:(NSString*)message
{
    //... callback code goes here
}
//...
@end
```

You must also call the following method before the callback can be run:

```objc
[NSClassFromString(@"FrameworkLibAPI") registerAPIforNativeCalls:self];
```

For more information on the UnityFramework methods, please refer to the [Unity docs](https://docs.unity3d.com/Manual/UnityasaLibrary-iOS.html).

## Cached data

When the game is completed, the data is stored in a persistent cache on the device. 

In iOS, the path to this file is `/var/mobile/Containers/Data/Application/<guid>/Documents/<filename>.json`

Possible filenames are `bartsession.json`, `bartconfig.json`, `sstsession.json` and `sstconfig.json`. Session files contain data collected during the participant's session, whereas config files contain the configuration used for the game. You can find the schemas [here](https://github.com/BrainPark/brainpac-nih-schemas/tree/main/schemas).

To clear the cache, you can call the following method:

```objc
[[self ufw] sendMessageToGOWithName: "GameDataManager" functionName: "ClearCache" message: ""];
```

## Known issues

- The package cannot be used with the iOS simulator as Unity only supports the ability to export either the Device or Simulator SDK at a time.
- You can’t load more than one instance of the Unity runtime.

## License
