# react-native-tus

Native TUS implementation for React Native

If you aren't looking for background functionality please see [tus-js-client](https://github.com/tus/tus-js-client)

## Getting started

`$ npm install @zachywheeler/react-native-tus --save`

or

`$ yarn add @zachywheeler/react-native-tus`

### Mostly automatic installation

```
# RN >= 0.60
cd ios && pod install

# RN < 0.60
react-native link react-native-tus
```

#### iOS setup

Add Background Processing capability and Background Scheduler Permitted Identifier to Info.plist

```
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
  <string>io.tus.uploading</string>
</array>
<key>UIBackgroundModes</key>
<array>
  <string>processing</string>
</array>
```


Call the Tus Client initialization singleton from your AppDelegate. There is some flexibility regarding where you initialize this. The main concern is that the client gets initialized at or around launch time and NOT when React Native lazy loads the module.

```
#import "TusNative.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [RNTusClientBridgeInstanceHolder initializeBackgroundClient];
}
```


## Usage

```js
import { Upload } from "@zachywheeler/react-native-tus";

```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
