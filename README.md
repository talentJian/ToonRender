﻿# ToonRender

- 测试不同模型 不同的卡通渲染~




# 重新测试卡通Shader
## 关于描边
在MV 空间下，在M 空间下，或者MVP空间下进行法线外扩的效果是基本一致的，无需纠结。

## 采用 pixel-perfect 的描边
pixel-perfect Outline Shader
https://www.videopoetics.com/tutorials/pixel-perfect-outline-shaders-unity/

在裁剪空间上 进行计算，可以很好的保证不受缩放影响，不受透视影响

## 着色
通过snapdragon profiler，可以反编译，然后人肉分析崩坏3的着色。

https://blog.csdn.net/goodboystrong/article/details/79994666 //制作工艺

https://blog.csdn.net/u010333737/article/details/82287853 //分析崩坏3的shader