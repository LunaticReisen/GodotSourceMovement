# GodotSourceMovment

使用 Godot 4.2.1

## 如何使用

clone然后解压到你想要的位置，然后在godot导入项目即可

## 更新日志：

(老的我懒得重新写了)

### v1.2.2

现在开始可以先跳跃后在空中按左右键进行旋转跳了（以前没注意到😥

现在跳跃后不移动鼠标只按左右只能轻微移动了，并不能像以前一样加速

### v1.2.1

更改项目名称

优化变量到一个单独的类

把天花板检测物体从Raycast3d变更为Shapecast3d

更改了目前速度的计算方式（从自带函数变成了手写，数字大了点

重做了自动兔子跳

已知问题：

- 玩家可以碰撞墙壁并跳跃去获得加速

- 没有滑翔（我还在做

## Ref:

use kenny's asset

https://www.kenney.nl/assets/input-prompts

https://www.kenney.nl/assets/prototype-textures

Ported from https://github.com/WiggleWizard/quake3-movement-unity3d/blob/master/CPMPlayer.cs


https://github.com/WiggleWizard/quake3-movement-unity3d/blob/master/CPMPlayer.cs

https://www.youtube.com/watch?v=v3zT3Z5apaM&t=165s

https://adrianb.io/2015/02/14/bunnyhop.html

https://github.com/id-Software/Quake-III-Arena/blob/master/code/game/bg_pmove.c#L235

https://github.com/dwlcj/Godot-Strafe-Jumping/blob/main/Scenes/Player.gd#L161

https://github.com/AkimBowX2/Godot-4_FPS_controller/blob/main/scenes/player/player.gd
