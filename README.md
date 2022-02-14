# AirController
AirController是一个通过无线网络连接对安卓设备文件进行远程管理的桌面应用，其受启发于[HandShaker](https://www.smartisan.com/apps/#/handshaker).
由于罗老师的锤子科技出现了问题，该产品已经在18年停止开发。因此，我在使用的时候发生了经常无故退出奔溃的问题。
这么好的产品放弃维护实在是一个遗憾，尤其是在Mac平台上，对Android设备支持有限的情况下。因此，我决定仿制一个出来，满足自己的需求，这就是该产品设计的初衷。

# 产品截图
![手机端准备就绪状态](https://raw.githubusercontent.com/yuanhoujun/material/main/AirController/images/mobile_ready_status.jpeg)

![桌面端准备就绪状态](https://raw.githubusercontent.com/yuanhoujun/material/main/AirController/images/desktop_search_page.png)

![手机端已连接状态](https://raw.githubusercontent.com/yuanhoujun/material/main/AirController/images/mobile_connect_status.jpeg)

![桌面端图片列表页](https://raw.githubusercontent.com/yuanhoujun/material/main/AirController/images/desktop_image_list_page.png)

![桌面端视频列表页](https://raw.githubusercontent.com/yuanhoujun/material/main/AirController/images/desktop_video_list_page.png)

# 使用步骤
> 如果你已经使用过HandShaker，以下内容可跳过，其使用方式与HandShaker几乎完全一致。

1）在手机端下载并安装AirController应用

打开以下链接，选择最新版本apk文件下载安装即可。

[https://github.com/air-controller/air-controller-mobile/releases](https://github.com/air-controller/air-controller-mobile/releases)

2）下载最新版本的AirController桌面应用并安装

打开以下链接，下载对应操作系统最新版本应用安装即可。

[https://github.com/air-controller/air-controller-desktop/releases](https://github.com/air-controller/air-controller-desktop/releases)

* Windows用户请下载exe格式文件
* Linux用户请下载AppImage格式文件
* MacOS用户请下载dmg格式文件

3）安装成功后，在桌面端打开AirController应用

* Windows与MacOS平台用户直接双击安装后运行即可
* Linux用户可先尝试双击运行AppImage格式文件，如果提示无法运行，请先执行命令`chmod +x AirController...AppImage`再尝试双击运行

4）将手机与电脑连接至同一网络，并在手机端打开AirController应用。
如果你使用台式机，请确保台式机与手机连接到了同一路由器，或者手机与电脑处于同一网段。

以上操作如果全部正确的话，你将看到类似上面应用截图中的画面。在雷达扫描的区域会出现一个闪动的手机图标，点击上方连接即可连接。
接下来你就可以使用你的电脑管理手机中的文件了，Enjoying!

# 编译运行
1）该应用使用[Flutter](https://flutter.dev/)框架进行开发，你需要先参考Flutter官方文档完成Flutter开发环境设置，请确保：

* 你已经安装了最新版本Flutter SDK
* 你已经安装了最新版本Dart SDK
* 使用`flutter doctor`命令检查正常

2）配置好开发环境之后，你需要安装[Android Studio](https://developer.android.com/studio)，并在Android Studio中安装Flutter插件。

接下来你就可以正常进行开发了，如果你只是需要编译成指定平台二进制文件。那么，你不需要安装Android Studio工具。

使用步骤进行编译即可：

1) 使用如下命令安装依赖

```
flutter pub get
```

2）添加桌面支持

```
flutter config --enable-<platform>-desktop
```

中间的`<platform>`使用对应平台替换即可，Windows平台替换为`windows`, Linux平台替换为`linux`，MacOS平台替换为`macos`。

3）编译

编译命令: `flutter build <platform>`

同样的，这里的`<platform>`，替换为目标平台。

**注意：编译到不同平台需要到指定平台电脑上进行**

# 捐赠
该应用完全开源，并承诺永久免费。如果你觉得该应用对你应用，请提供支持，你的支持对我非常重要。目前，最简单的支持就是点亮项目上方star。

除此之外，由于该应用目前是由我一个人开发完成，我并不会UI设计，如果你是一个UI设计者，有更好的UI设计建议，请联系我提供UI设计图。
或者帮助设计一个更好的图标，也不胜感激。

# 问题反馈
如果你在使用过程中，遇到了任何问题，可点击以下链接，提交问题详情，我会第一时间关注并尝试修复。

[https://github.com/air-controller/air-controller-desktop/issues](https://github.com/air-controller/air-controller-desktop/issues)

# 功能建议
如果你期望应用提供一些你想要的功能，也可以使用上述连接，通过提交issue的方式给我反馈。

# 联系开发者
邮箱: `ouyangfeng2016@gmail.com` OR `626306805@qq.com`

# Ubuntu
该应用的主要目标平台是Ubuntu与MacOS，对我而言，Ubuntu平台的重要性甚至超过了MacOS，非常欢迎使用Ubuntu平台的同学提供建议及反馈，我会尽可能确保
其在Ubuntu平台运行良好。