---
typora-copy-images-to: ./images
---

# TransLyric 使用教程

TransLyric是一款插件，可以用来将Apple Music 的歌词翻译成中文。

请加入官方QQ群 1023217857 以获得最新版本的更新以及教程所需文件

> [!WARNING]
>
> TransLyric 是一个 个人开发者项目，项目的更新有可能会缓慢。



## 安装方法

#### 提取"音乐"

我已经提取了一部分"音乐"的IPA安装包。可在群文件查看。系统版本一样而机型不同是可以通用的。

如果您找不到您所需版本的"音乐"IPA安装包且无法通过Filza等文件管理软件提取并打包IPA。下文将会带您通过IPSW 固件来获取“音乐”安装包

##### 下载对应的 IPSW 固件

从ipsw.me找到您机型对应的所需固件并下载。笔者实例为iPhone 14 Pro Max，系统为iOS 18.1 (22B83)

![](C:\Users\rick\Desktop\images\QQ_1738565161526.png)

点击"Download"按钮，等待固件下载完成。

> [!TIP]
>
> 使用"爱思助手"下载 IPSW 文件也一样可行。



##### 提取系统 ROOTFS 文件

![QQ_1738591564304](C:\Users\rick\Desktop\images\QQ_1738591564304.png)

现在我们已经下载完 IPSW 文件。将后缀名改为 .zip，并用解压缩软件打开。

![QQ_1738591643172](C:\Users\rick\Desktop\images\QQ_1738591643172.png)

我们选择大小最大的文件解压出来。在这里文件是**044-05779-125.dmg.aea**。

##### 解密.dmg.aea文件(iOS18+)

> iOS 18 开始，Apple 对 ipsw 文件里面的 dmg 进行的加密处理，加密后的文件类型是 `dmg.aea`
>
> 有大牛已经做出来了加密工具：https://github.com/blacktop/ipsw/releases
>
> Source:https://lvv.me/posts/2024/10/04_decrypt_dmg_aea/

所以我们需要解密.dmg.aea文件，如果是iOS 18 以下解压出来直接为.dmg文件，无需解密。

这里需要的解密工具是blacktop 的 ipsw 工具 推荐使用3.1.564版本 其他版本也许会出现EOF错误

https://github.com/blacktop/ipsw/releases

Windows Release: https://github.com/blacktop/ipsw/releases/download/v3.1.564/ipsw_3.1.564_windows_x86_64.zip

群文件已经上传ipsw工具。 

![QQ_1738592303622](C:\Users\rick\Desktop\images\QQ_1738592303622.png)

下载后的ipsw工具如图所示。

解压它并使用命令提示符(cmd) cd 到解压的位置。笔者解压的位置是E:\ipsw_3.1.564_windows_x86_64

```
cd /d E:\ipsw_3.1.564_windows_x86_64
ipsw.exe fw aea [刚刚解压的.dmg.aea] -o .
```

在此笔者的命令是

```
ipsw.exe fw aea E:\044-05779-125.dmg.aea -o .
```

随后我们会在E:\ipsw_3.1.564_windows_x86_64下发现已经解密好的.dmg文件。

##### 打开并提取"音乐"IPA

我们使用"7z"来打开 DMG 文件 https://www.7-zip.org/

![QQ_1738593220927](C:\Users\rick\Desktop\images\QQ_1738593220927.png)

打开后的DMG文件。

我们打开private->var->staged_system_apps->Music.app

解压到您喜欢的任意路径。![QQ_1738593997733](C:\Users\rick\Desktop\images\QQ_1738593997733.png)

大功告成！您已经提取了"音乐"的IPA文件。



## Credit