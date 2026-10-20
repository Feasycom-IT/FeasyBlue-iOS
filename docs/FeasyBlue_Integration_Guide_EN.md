# FeasyBlue iOS SDK Integration Guide

## Package

[`FEBluetoothSDK/`](../FEBluetoothSDK) contains `libFEBluetoothSDK.a` and public headers. The library contains an **arm64 iPhone device** slice. Simulator slices and SDK implementation source are not included.

## Integration

1. Add the static library and all public headers to your Xcode project.
2. Link `libFEBluetoothSDK.a` in the app target and configure library/header search paths. Use the FeasyBlue demo Build Settings as a reference for system dependencies and linker options.
3. Import CoreBluetooth and `FBlueSDKPublicHeader.h`.
4. Configure Bluetooth usage descriptions. Configure location, local networking and background capabilities only as required by your application; inspect the demo Info.plist for its existing settings.
5. Run on a physical iPhone. The supplied static library does not support simulator builds.

## Scan

Start scanning after Bluetooth permission has been granted and the SDK reports PoweredOn. Avoid refreshing UI on every discovery callback.

```objc
#import <CoreBluetooth/CoreBluetooth.h>
#import "FBlueSDKPublicHeader.h"

FEBluetoothSDK *sdk = [FEBluetoothSDK sharedFEBluetoothSDK];
if (sdk.feBluetoothSDKState == FEBluetoothSDKState_PoweredOn) {
    [sdk scanForPeripheralsWithServices:nil
                                block:^(FEPeripheral *peripheral, BOOL isNew) {
        // Display, filter or retain the peripheral as needed.
    }];
}

// Stop when leaving the scanning screen.
[sdk stopScan];
```

## Connection and device operations

Use `FEBluetoothSDKDelegate` for Bluetooth state updates. Connect a discovered `FEPeripheral` with `connect:options:` and configure `FEConnectOptions` as needed. Register peripheral callbacks to track connection state and operating mode before sending data.

Communication, AT commands and OTA use different modes. Follow the demo workflow and the connected module's capabilities. `FEOTA` requires firmware data matching the module and its expected format; arbitrary binary files are not interchangeable. WiFi APIs are declared in `FEWiFi.h`; a separate [FeasyWiFi demo](../Demo/feasywifi-ios) is included.

Public [headers and API comments](../FEBluetoothSDK/Headers) are the reference for method signatures and availability. SDK revision notes are in [FBlueReadMe.md](../FEBluetoothSDK/Headers/FBlueReadMe.md).

## Build the demos

Open `Demo/feasyblue-ios/BLEAssistant.xcworkspace` and select the `BLEAssistant` scheme. The app target is version 1.8.6 and targets iOS 13 or later. Pods and lockfiles are included. If reinstalling dependencies, run `pod install` from the demo directory.

The WiFi workspace is `Demo/feasywifi-ios/FeasyWIFI.xcworkspace`, scheme `FeasyWIFI`; its app target is version 1.2.2 and targets iOS 10 or later. Each demo retains its bundled SDK files; verify binary/API compatibility before replacing them.

Select your own signing team and Bundle ID for device deployment. This guide reflects the supplied headers and project configuration; hardware functionality and full app builds were not validated as part of repository packaging.
