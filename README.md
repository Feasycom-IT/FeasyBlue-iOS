# FeasyBlue iOS App（SDK + Demo）

FeasyBlue 是飞易通蓝牙模块的配置、通信与固件升级示例 App。本仓库提供 **应用层源码、预编译 FEBluetoothSDK、FeasyWiFi 示例工程和接入文档**。

SDK 以静态库和公开头文件交付，**不包含 FEBluetoothSDK 的实现源码**。

> FeasyBlue iOS app source, prebuilt SDK and demo projects. The SDK is distributed as an arm64 static library with public headers; its implementation source is not included.

## 1. 下载 / Download

- [下载完整开发资料包](https://github.com/Feasycom-IT/FeasyBlue-iOS/releases/latest)
- [浏览 FeasyBlue 示例源码](Demo/feasyblue-ios/BLEAssistant)
- [浏览 FeasyWiFi 示例源码](Demo/feasywifi-ios/FeasyWIFI)
- [下载或浏览独立 SDK](FEBluetoothSDK)

也可以使用 Git 克隆整个仓库：

```bash
git clone https://github.com/Feasycom-IT/FeasyBlue-iOS.git
```

## 2. 引入 SDK / Add the SDK

```text
FEBluetoothSDK/
├── Headers/
│   ├── FBlueSDKPublicHeader.h
│   ├── FEBluetoothSDK.h
│   ├── FEPeripheral.h
│   ├── FEOTA.h
│   └── ...
└── libFEBluetoothSDK.a
```

把 `FEBluetoothSDK` 目录添加到自己的 Xcode 工程，链接静态库，配置头文件搜索路径，并导入：

```objc
#import <CoreBluetooth/CoreBluetooth.h>
#import "FBlueSDKPublicHeader.h"
```

当前独立 SDK 静态库仅包含 **iPhone 真机 arm64**，不提供模拟器切片。蓝牙扫描、连接、数据通信、OTA 和 WiFi 接口以本仓库公开头文件为准。

详细步骤及最小扫描示例见 [中文接入文档](docs/FeasyBlue_Integration_Guide_CN.md) / [English guide](docs/FeasyBlue_Integration_Guide_EN.md)。

## 3. 打开与编译 / Build

使用 macOS 和 Xcode，选择 iPhone 真机或通用 iOS 真机目标。仓库保留 `Pods` 和锁定文件，打开 **workspace**：

```bash
open Demo/feasyblue-ios/BLEAssistant.xcworkspace
# 或打开 WiFi 示例
open Demo/feasywifi-ios/FeasyWIFI.xcworkspace
```

- FeasyBlue scheme：`BLEAssistant`；应用版本 `1.8.6`，构建号 `20260818`，主 App target 最低系统 iOS 13。
- FeasyWiFi scheme：`FeasyWIFI`；应用版本 `1.2.2`，构建号 `1`，主 App target 最低系统 iOS 10。
- 真机运行前，在 Signing & Capabilities 中选择自己的开发团队及可用的 Bundle ID（仓库已清空开发团队配置）。
- Bugly 崩溃统计默认关闭；如需启用，把 `AppDelegate.m` 中的 `YOUR_BUGLY_APP_ID` 替换为自己的 App ID。
- 如需重新安装依赖，在相应 Demo 目录中运行 `pod install`，并使用更新后的 `.xcworkspace`。
- 主 App target 的最低系统要求与历史 Podfile 声明不同，请以应用 target 为准。

可用下面的命令进行不签名的真机目标构建：

```bash
xcodebuild -workspace Demo/feasyblue-ios/BLEAssistant.xcworkspace \
  -scheme BLEAssistant -configuration Debug \
  -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
```

本次仓库整理验证了目录、SDK 架构、Podfile 语法和工程识别；未完成 App 编译或真机功能验收。

## 4. 应用信息 / App info

- FeasyBlue Bundle ID：`com.feasycom.BLEAssistant`
- FeasyWiFi Bundle ID：`com.feasycom.feasywifi`
- 应用层：Objective-C / UIKit；第三方依赖由 CocoaPods 管理。
- SDK 版本记录：[FBlueReadMe.md](FEBluetoothSDK/Headers/FBlueReadMe.md)
- FeasyBlue 应用版本记录：[readme.md](Demo/feasyblue-ios/readme.md)
- FeasyWiFi 应用版本记录：[readme.md](Demo/feasywifi-ios/readme.md)

## 5. 文档 / Documents

- [中文 SDK 接入说明](docs/FeasyBlue_Integration_Guide_CN.md)
- [English SDK integration guide](docs/FeasyBlue_Integration_Guide_EN.md)
- [公开头文件与 API 注释](FEBluetoothSDK/Headers)
- [SDK 交付说明](FEBluetoothSDK/README.md)

## 6. 目录结构 / Layout

```text
.
├── FEBluetoothSDK/             # 独立 SDK 静态库与公开头文件
├── Demo/
│   ├── feasyblue-ios/           # FeasyBlue App 源码、workspace 与 Pods
│   └── feasywifi-ios/           # FeasyWiFi App 源码、workspace 与 Pods
├── docs/                       # 中英文接入说明
├── .gitignore
└── README.md
```

## 7. 说明 / Notes

- 本仓库保留 Demo 内各自配套的 SDK 文件。接入新项目可从根目录的 `FEBluetoothSDK/` 开始；不要在未核对 API 和二进制兼容性的情况下互换不同 Demo 的 SDK。
- 设备通信需要对应的飞易通模块及匹配的固件；OTA 固件格式、模块型号及升级流程应与示例代码和接口注释一致。
- 蓝牙、定位和局域网能力所需的权限应根据实际功能配置，现有 Demo 的 Info.plist 可作为工程参考。
- 下载资料包在 Releases 中；仓库主分支直接提供可浏览、克隆的源码与 SDK。
