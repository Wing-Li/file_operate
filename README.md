# file_operate

使用 Flutter 开发的一款 Mac 应用，该应用可以对文件进行批量移动操作。

## 预览图

![image](https://github.com/Wing-Li/file_operate/blob/master/preview/file_opt.png)

***

## 打包方式

1. 在命令行中进入Flutter项目的根目录，运行以下命令将应用程序构建为Release版本：

```
flutter build macos --release
```

2. 将生成的Release版本应用程序文件
（例如：build/macos/Build/Products/Release/YourAppName.app）复制到/Applications目录下。

3. 打开终端，点击图标 或 输入以下命令以打开应用程序：

```
open /Applications/YourAppName.app
```

4. 此时，应用程序应该已经成功打开并运行。