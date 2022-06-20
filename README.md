# ![](https://raw.githubusercontent.com/yuanhoujun/material/main/AirController/images/logo.png)

![GitHub (pre-)release](https://img.shields.io/github/release/air-controller/air-controller-desktop/all.svg?style=flat-square)
![Release date](https://img.shields.io/github/release-date/air-controller/air-controller-desktop)
![Total lines](https://img.shields.io/tokei/lines/github.com/air-controller/air-controller-desktop)
![Total downloads](https://img.shields.io/github/downloads/air-controller/air-controller-desktop/total.svg)
[![](https://img.shields.io/github/issues/air-controller/air-controller-desktop)](https://github.com/air-controller/air-controller-desktop/issues)
[![](https://img.shields.io/github/license/air-controller/air-controller-desktop)](https://github.com/air-controller/air-controller-desktop/blob/master/LICENSE)

[中文文档](https://github.com/air-controller/air-controller-desktop/blob/master/README_zh_CN.md)

AirController is a powerful, handy, and cross-platform desktop application, it can manage your android phone easily without connecting to a computer.

Inspired by HandShaker, I hope it becomes your favorite android assistant app on Linux and macOS.

![Preview](https://raw.githubusercontent.com/yuanhoujun/material/main/AirController/images/demo.gif)


# How to use

1. Install the latest AirController mobile app on your Android phone.

Open the link below and choose the latest version apk file to install.

[https://github.com/air-controller/air-controller-mobile/releases](https://github.com/air-controller/air-controller-mobile/releases)

2. Install the latest AirController desktop app on your computer.

Open the link below and choose the latest file to install.

[https://github.com/air-controller/air-controller-desktop/releases](https://github.com/air-controller/air-controller-desktop/releases)

* Windows users choose the exe suffix file, please.

* Linux users choose the AppImage suffix file, please.

* macOS users choose the dmg suffix file, please.

3. Open the desktop application

4. Make sure your phone and computer have been connected to the same network, and open the application on your phone.

**That's all, enjoy it!**

# Build and run.

1. Install the latest Flutter SDK on your computer.

This project is developed with the Flutter framework, You should install Flutter first on your computer.

Make sure:

* You have installed the latest Flutter SDK.

* You have installed the latest Dart SDK.

* Run command "flutter doctor" and no errors are output.



2. Install dependencies and add desktop support.

Use the command `flutter pub get` to install dependencies.

Use the command `flutter config --enable-<platform>-desktop` to add desktop support.



Use a specific platform name to replace the string "-<platform>-" in the middle.

Eg: `flutter config -enable-linux-desktop` to add support for the Linux platform.


3. Build

The build command is `flutter build <platform>`.

Same as above, use a specific platform name to replace the string "<platform>", then you will get the final binary file.

Attention: you need to build it on the computer running the same platform. Eg: Building a Windows platform binary file needs to use a Windows PC.

# Feedback

If you have any questions when using this app, please click the link below and submit the issue detail, I will fix it quickly.

[https://github.com/air-controller/air-controller-desktop/issues](https://github.com/air-controller/air-controller-desktop/issues)

# Feature Suggestion

If you want more features, just tell me by issue, please.

[https://github.com/air-controller/air-controller-desktop/issues](https://github.com/air-controller/air-controller-desktop/issues)


# Support

I will really appreciate it if you want to support me. For now, just star me please, that's a big support for me.

If you are a UI designer, and you can provide me with a better design resource, that will be perfect.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/I2I04VU09)

[![Support Me](https://raw.githubusercontent.com/yuanhoujun/material/main/Sponsor/aifadian.png)](https://afdian.net/@ouyangfeng2016)

![](https://raw.githubusercontent.com/yuanhoujun/material/main/Pay/wechat_alipay.png)

# Stay In Touch
QQ Group: [329673958](https://im.qq.com/index)

Telegram Channel: [AirController](https://t.me/aircontroller2022)

Email: [ouyangfeng2016@gmail.com](mailto:ouyangfeng2016@gmail.com)

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

