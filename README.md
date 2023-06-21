# brainpac-nih-ios

The [BrainPark Assessment of Cognition (BrainPAC) Project](http://www.brainpark.com/projects/brain-pac) aims to develop a one-of-a-kind electronic battery with industry partners (Torus Games), which is informed by neuroscience, engaging, and clinically useful for the assessment and monitoring of individuals across the spectrum of impulsive-compulsive disorders.

This Swift package contains two of the games, BART (balloons game) and SST (dragon game), and can be integrated into the Mobile Toolbox developed by [@Sage-Bionetworks](https://github.com/Sage-Bionetworks).

## Installation

Follow normal Swift package installation. Select File > Add Packages... and search for `https://github.com/BrainPark/brainpac-nih-ios`. Latest production releases are on the `main` branch.

Ensure that the BrainPACNIH library is in "Frameworks, Libraries and Embedded Content" under the General tab for your target.

## Usage

> If running on an iOS simulator, it must be running on x86_64 architecture. This is a limitation of Unity. If you are using XCode 14.3+, you can expose these simulators by going to Product > Destination > Destination Architectures and select 'Show Rosetta Destinations'.

This package allows you to call a SwiftUI.View called `BrainPACView` that opens the Unity window with the BART or SST game loaded.

`BrainPACView` accepts a `game` argument of the enum type `BrainPACGame`. Its cases are `.bart` and `.sst`. The second argument, `onSessionComplete`, is a callback that passs the arguments `resultsPath: String` and `schemaUrl: String`. `resultsPath` is the path to the results .json file on the device storage, and `schemaUrl` is the URL to the corresponding JSON schema.

Simple usage might look like:

```swift
import SwiftUI
import BrainPACNIH

func onSessionComplete(resultsPath: String, schemaUrl: String) -> Void {
    print(resultsPath)
    print(schemaUrl)
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                NavigationLink(destination: BrainPACView(game: BrainPACGame.bart, onSessionComplete: onSessionComplete)) {
                    Text("Play BART")
                }
                Spacer()
                NavigationLink(destination: BrainPACView(game: BrainPACGame.sst, onSessionComplete: onSessionComplete)) {
                    Text("Play SST")
                }
                Spacer()
            }
        }
    }
}
```

> NOTE: `BrainPACView` adds a new UIWindow required to run Unity. Once the game session is complete, it unloads the window and returns to the previous key window.

## Known issues

- You can’t load more than one instance of the Unity runtime. This will be an issue if there are multiple packages using the UnityFramework.

## License
