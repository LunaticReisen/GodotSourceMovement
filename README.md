# GodotSourceMovment

Use Godot 4.2.1

[简体中文](README/README.zh_CN.md)

## Features

- [x] BunnyHopping
- [x] Surfing
- [x] Air Strafe
- [x] Crouching
- [x] Mouse Scroll Jumpping

## HOW TO USE

Clone it and unzip it on any where you like ,then use godot to import the project, that it! Have fun!

## Update Log

### v1.3.0

More smooth hopping and... ADD SURFING!

Now, you can surfing in this project

### v1.2.2

Can jump first then move left/right in air to acclerate right now

While jumping, you can not acclerate by move left/right right now

### v1.2.1

Change the project name

Optimize variable to a separate class

Change the ceiling cast object from RayCast3D to ShapeCast3D

Change the current speed calculation

Remake auto bunny hop

known issue: 

- player can collision multiple wall to able to add speed

- no surf(still work on it)

### v1.2 

Almost done!

Add 2 line to fix werid gravity problem

Change some speed number to make it more smooth

### v1.1

Add crouch, can do a little starfe jumping in crouch, the gravity in ground movment looks weird

### v1.0 

Can strafe jumping but no crouch

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

https://www.reddit.com/r/godot/comments/16do5ua/move_and_slide_works_differently_between_35_and_4/