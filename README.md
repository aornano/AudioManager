## AudioManager
>A strong shared instance to manage your audio files based to AVAudioFoundation framework

[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)
[![Build Status](https://travis-ci.org/Alamofire/Alamofire.svg?branch=master)](https://travis-ci.org/Alamofire/Alamofire)
[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![License](https://img.shields.io/cocoapods/l/BadgeSwift.svg?style=flat)](/LICENSE)

Sequentially bouncing zoom animation:

![demo](demo.jpg) 

**AudioManager** is a library written in Swift to correctly handle your audio inside your project. It's based to the ```AVAudioFoundation``` framework so you can use it with your iOS project (using ```UIKit```, ```SpriteKit```, etc..).
With a shared instance class called ```AudioManager``` you can handle a background music player (``AVAudioPlayer`` property  and 30 effects (always based to ``AVAudioPlayer`` class) or more , if you need to increase it you can but it's recommended to use the actual value..

- [Features](#features)
- [ToDo](#todo)
- [Requirements](#requirements)
- [Communication](#communication)
- [Installation](#installation)
- [Usage](#usage)
- [License](#license)


## Features

Creating a New Label Node:

```
    - audioManager.playBackgroundMusic(filename: "backgroundMusic.mp3", musicVolume: 1.0)
      play the background music with the volume at 1.0
```

```
    - audioManager.playSoundEffect(filename: "coin.wav", effectVolume: 1.0)
      play the sound effect with the volume at 1.0
```

- [x] asyncronous running in a background thread to not disturb the main thread.
- [x] they can be paused, resumed or stopped anytime.
- [x] fadeIn and fadeOut effects
- [x] each audio player have a custom volume setting
- [x] each audio could be looped infinitely
- [x] intelligent effects queue: if the called effect was already initialized, it will be re-called to play without initialize a new instance. If we have a full queue and we need to add a new effect, the first player will be removed to leave available space to the new effect.
- [x] global methods to pause , resume or stop all effects in one shot.


## ToDo
- [x] improve memory handling (already good for now..)
- [x] improve sound effect list abilities

## Requirements

- iOS 8.0+
- Xcode 9.2+
- Swift 4.0+

## Communication

- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Installation

Add the source file ```AudioManager.swift``` to your project and use it.

Call the shared instance with this line:

```let audioManager = AudioManager.sharedInstance```

## Usage

```
audioManager.playBackgroundMusic(filename: "backgroundMusic.mp3", musicVolume: 1.0)
audioManager.playSoundEffect(filename: "coin.wav", effectVolume: 1.0)
```

## License
AudioManager is released under the [MIT License](LICENSE)

