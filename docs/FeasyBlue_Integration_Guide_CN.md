# FeasyBlue iOS SDK 接入说明

## SDK 文件与架构

独立交付目录为 [`FEBluetoothSDK/`](../FEBluetoothSDK)，包含 `libFEBluetoothSDK.a` 和 `Headers/`。静态库包含 iPhone 真机 arm64，未包含模拟器切片；SDK 实现源码不在仓库中。

## Xcode 配置

1. 把静态库和全部公开头文件添加到工程。
2. 在应用 target 的 Link Binary With Libraries 中链接 `libFEBluetoothSDK.a`，并配置对应的 Library Search Paths、Header Search Paths。
3. 导入 CoreBluetooth 和 `FBlueSDKPublicHeader.h`。使用到的系统依赖及链接选项可参照 FeasyBlue 示例工程的 Build Settings。
4. 按应用功能配置蓝牙权限说明；需要后台蓝牙、定位或局域网功能时，参照 Demo 的 Info.plist 和实际业务配置。
5. 连接 iPhone 真机验证，不使用当前静态库构建模拟器目标。

## 最小扫描示例

下例只演示公开 API 的调用位置。调用前应完成蓝牙授权，并在蓝牙状态为 PoweredOn 后开始扫描；不要在扫描回调中高频刷新列表。

```objc
#import <CoreBluetooth/CoreBluetooth.h>
#import "FBlueSDKPublicHeader.h"

FEBluetoothSDK *sdk = [FEBluetoothSDK sharedFEBluetoothSDK];
if (sdk.feBluetoothSDKState == FEBluetoothSDKState_PoweredOn) {
    [sdk scanForPeripheralsWithServices:nil
                                block:^(FEPeripheral *peripheral, BOOL isNew) {
        // 根据业务显示、筛选或保存 peripheral。
    }];
}

// 离开扫描页面时停止扫描。
[sdk stopScan];
```

## 连接、通信与 OTA

- 用 `FEBluetoothSDKDelegate` 监听蓝牙状态；`FEConnectOptions` 控制连接选项。
- 用 `connect:options:` 连接扫描到的 `FEPeripheral`，通过该外设的回调跟踪连接状态和通信模式。
- 普通通信、AT 指令与 OTA 是不同模式，必须按设备支持情况切换并确认就绪。
- OTA 的 `FEOTA` 需要匹配模块的固件数据；固件处理和升级流程请参照 Demo，不能直接套用任意 `.bin`。
- WiFi 接口参见 `FEWiFi.h`；另有独立的 [FeasyWiFi Demo](../Demo/feasywifi-ios)。

完整方法、参数与可用性以 [Headers](../FEBluetoothSDK/Headers) 中的注释为准。SDK 修订记录见 [FBlueReadMe.md](../FEBluetoothSDK/Headers/FBlueReadMe.md)。

## 运行示例

打开 `Demo/feasyblue-ios/BLEAssistant.xcworkspace`，选择 `BLEAssistant` scheme。项目已经包含 Pods；如需重装，在 Demo 目录运行 `pod install`。主 App target 当前最低为 iOS 13，版本 1.8.6。

真机运行需要配置自己的签名团队。该文档依据本仓库头文件和工程配置整理，不代表已完成硬件功能测试。
