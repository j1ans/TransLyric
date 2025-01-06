# TransLyric
![Static Badge](https://img.shields.io/badge/build_arch-arm64e-blue)

![Static Badge](https://img.shields.io/badge/for-roothide-blue)

![Static Badge](https://img.shields.io/badge/License-MIT-yellow)

![Static Badge](https://img.shields.io/badge/Verifed_iOS-16.6-green)

一款能翻译Apple Music歌词的越狱插件

## 适配须知

> [!CAUTION]
>
> 目前开源的代码是基于roothide开发的，如果需要在rootless设备上运行，请在tweak.xm里将rootjb函数和对roothide头文件的引用去掉

## 存在的BUG

目前歌词适配度不是很好，存在多数英文歌词，少数日韩文歌词无法匹配到译文的现象

以笔者的Apple Music日区为例:

| 语言    | 歌词匹配正确概率 |
| ------- | ---------------- |
| 英文    | 60%              |
| 日/韩文 | 90%              |

> [!IMPORTANT]
>
> Apple Music区域不同会导致搜索结果不同

比如很多英文歌曲会变成假名从而无法搜索到。

## 请注意

为了适配android亦或者是web 插件仅作向服务器发送请求的作用

Server仓库在[TransLyric_Server](https://github/j1ans/TransLyric_Server)
