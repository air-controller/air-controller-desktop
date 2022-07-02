# ![](https://raw.githubusercontent.com/yuanhoujun/material/main/AirController/images/logo.png)

![GitHub (pre-)release](https://img.shields.io/github/release/air-controller/air-controller-desktop/all.svg?style=flat-square)
![Release date](https://img.shields.io/github/release-date/air-controller/air-controller-desktop)
[![Total downloads](https://img.shields.io/github/downloads/air-controller/air-controller-desktop/total.svg)](https://github.com/air-controller/air-controller-desktop/releases)[![](https://img.shields.io/github/issues/air-controller/air-controller-desktop)](https://github.com/air-controller/air-controller-desktop/issues)
[![](https://img.shields.io/github/license/air-controller/air-controller-desktop)](https://github.com/air-controller/air-controller-desktop/blob/master/LICENSE)

AirController是一个开源版本的[HandShaker](https://www.smartisan.com/apps/#/handshaker)，如果你使用过HandShaker，
应该对AirController不会感到陌生！

![Preview](https://raw.githubusercontent.com/yuanhoujun/material/main/AirController/images/demo.gif)

# 使用步骤
由于AirController是通过无线网络连接并管理你的手机，所以，你需要先在手机端安装AirController应用。

### 在手机端下载并安装AirController应用

打开以下链接，选择apk文件下载安装即可。

[https://github.com/air-controller/air-controller-mobile/releases](https://github.com/air-controller/air-controller-mobile/releases/latest)

### 下载最新版本的AirController桌面应用并安装

打开以下链接，下载对应操作系统的应用安装即可。

[https://github.com/air-controller/air-controller-desktop/releases](https://github.com/air-controller/air-controller-desktop/releases/latest)

* Windows用户请下载exe格式文件
* Linux用户请下载AppImage格式文件
* MacOS用户请下载dmg格式文件

### 安装成功后，在桌面端打开AirController应用

* Windows与MacOS平台用户直接双击安装后运行即可
* Linux用户可先尝试双击运行AppImage格式文件，如果提示无法运行，请先执行命令`chmod +x AirController...AppImage`再尝试运行

### 将手机与电脑连接至同一网络，并在手机端打开AirController应用。
如果你使用台式机，请确保台式机与手机连接到了同一路由器，或者手机与电脑处于同一网段。

以上操作如果全部正确的话，你将看到类似上面应用截图中的画面。在雷达扫描的区域会出现一个闪动的手机图标，点击上方连接按钮即可完成连接。
接下来你就可以使用你的电脑管理手机中的文件了，Enjoying!

# 编译运行
### 该应用使用[Flutter](https://flutter.dev/)框架进行开发，你需要先参考Flutter官方文档完成Flutter开发环境设置，请确保：

* 你已经安装了最新版本Flutter SDK
* 你已经安装了最新版本Dart SDK
* 使用`flutter doctor`命令提示无异常

### 配置好开发环境之后，你需要安装[Android Studio](https://developer.android.com/studio)，并在Android Studio中安装Flutter插件。

接下来你就可以正常进行开发了，如果你只是需要编译成指定平台二进制文件。那么，你不需要安装Android Studio工具。

使用步骤进行编译即可：

### 使用如下命令安装依赖

```
flutter pub get
```

### 添加桌面支持

```
flutter config --enable-<platform>-desktop
```

中间的`<platform>`使用对应平台替换即可，Windows平台替换为`windows`, Linux平台替换为`linux`，MacOS平台替换为`macos`。

### 编译

编译命令: `flutter build <platform>`

同样的，这里的`<platform>`，替换为目标平台。

**注意：编译到不同平台需要到指定平台电脑上进行**

# 问题反馈
如果你在使用过程中，遇到了任何问题，可点击以下链接，提交问题详情，我会第一时间关注并尝试修复。

[提交问题](https://github.com/air-controller/air-controller-desktop/issues/new?assignees=&labels=&template=bug_report.md&title=)


# 功能建议
如果你期望应用提供一些你想要的功能，也可以使用上述连接，通过提交issue的方式给我反馈。

[提交功能建议](https://github.com/air-controller/air-controller-desktop/issues/new?assignees=&labels=&template=feature_request.md&title=)

# 支持
如果你喜欢这个项目，可通过以下几种方式支持我，无论是任何形式的支持，都不胜感激！

* 点击项目右上角star支持我
* 如果你是一个UI设计师，可联系我，提供更好的UI设计资源，会有回馈
* 点击下方**爱发电**或扫描微信支付宝打赏任意金额均可

[![](https://img.shields.io/badge/-%E6%9D%A5%E7%88%B1%E5%8F%91%E7%94%B5%E6%94%AF%E6%8C%81%E6%88%91-%23977ce4?style=for-the-badge&logo=buymeacoffee&logoColor=%23ffffff)](https://afdian.net/@ouyangfeng2016)

![](https://raw.githubusercontent.com/yuanhoujun/material/main/Pay/wechat_alipay.png)

# 感谢
[AndServer](https://github.com/yanzhenjie/AndServer)

[BLOC](https://github.com/felangel/bloc.git)

[window_manager](https://github.com/leanflutter/window_manager)

[contacts-android](https://github.com/vestrel00/contacts-android)

# 交流
QQ群: 329673958

小飞机: [AirController](https://t.me/aircontroller2022)

邮箱: [ouyangfeng2016@gmail.com](mailto:ouyangfeng2016@gmail.com)

# License
Copyright (c) 2022 Feng Ouyang

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
