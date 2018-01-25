//
//  AudioManager.swift
//  iFred
//                                                         \|/
//                                                         @ @
//  +--------------------------------------------------oOO-(_)-OOo---+
//  Created by Alessandro Ornano on 14/11/2016.
//  Copyright © 2016 Alessandro Ornano. All rights reserved.
//

import Foundation
import AVFoundation

struct SoundEffect {
    var player: AVAudioPlayer! = AVAudioPlayer()
    var effectFilename :String! = String()
    var wasSoundEffectPaused:Bool = false
}
// Singletone
class AudioManager: NSObject {
    static let sharedInstance = AudioManager()
    var backgroundMusicPlayer: AVAudioPlayer!
    var musicFilename: String!
    var wasBackgroundMusicPaused: Bool = false
    var soundEffects: [SoundEffect]! = [SoundEffect]()
    let maxSoundEffects : Int = 30 // Max number of SoundEffects allocated (so max number of AVAudioPlayer + 1 (backgroundMusic))
    let backgroundQueue = DispatchQueue(label: "com.app.queue", qos: .background, target: nil)
    
    override init() {
        super.init()
        print("---")
        print("❊ Audio Manager initialization .. (singletone) -> \(type(of: self))")
        print("---")
    }
    
    // #-#-#-#-#-#-#-#-#-#-#-#-#-#-#
    //MARK: - BACKGROUND MUSIC
    // #-#-#-#-#-#-#-#-#-#-#-#-#-#-#
    
    // Play a background music
    func playBackgroundMusic(filename: String, musicVolume:Float, startingWithFadeIn:Bool = true) {
        backgroundQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else { return }
            strongSelf.musicFilename = filename
            do { strongSelf.backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: nil) }
            catch { print(error.localizedDescription) }
            
            if let player = strongSelf.backgroundMusicPlayer {
                if startingWithFadeIn  { player.fadeIn(vol: musicVolume) } else { player.volume = musicVolume }
                player.numberOfLoops = -1
                player.prepareToPlay()
                player.play()
            }
        }
    }
    // Change the background music volume
    func changeBackgroundMusicVolume(musicVolume:Float) {
        if let player = backgroundMusicPlayer {
            if player.isPlaying {
                player.volume = musicVolume
            }
        }
    }
    // Pause the background music
    func pauseBackgroundMusic() {
        if let player = backgroundMusicPlayer {
            if player.isPlaying {
                wasBackgroundMusicPaused = true
                player.pause()
            }
        }
    }
    // Resume the background music
    func resumeBackgroundMusic(musicVolume:Float) {
        if let player = backgroundMusicPlayer {
            if !player.isPlaying && wasBackgroundMusicPaused {
                player.playInBackground(volume:musicVolume)
                wasBackgroundMusicPaused = false
            }
        }
    }
    // Stop the background music
    func stopBackgroundMusic() {
        if let player = backgroundMusicPlayer {
            if player.isPlaying {
                player.stop()
                wasBackgroundMusicPaused = false
                backgroundMusicPlayer = nil
            }
        }
    }
    // Reset the background music
    func resetBackgroundMusicPlayer() {
        if  backgroundMusicPlayer != nil {
            if (backgroundMusicPlayer?.isPlaying)! {
                backgroundMusicPlayer?.stop()
                wasBackgroundMusicPaused = false
            }
            backgroundMusicPlayer.currentTime = 0.0
        }
    }
    
    // #-#-#-#-#-#-#-#-#-#-#-#-#-#-#
    //MARK: - GENERIC SOUND EFFECT
    // #-#-#-#-#-#-#-#-#-#-#-#-#-#-#
    
    // Get a single sound effect
    func playSingleSoundEffect(_ url: URL, _ effectVolume:Float, _ looped:Bool, completion:@escaping CompletionValue) {
        backgroundQueue.async {
            do {
                let soundEffectPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: nil)
                soundEffectPlayer.volume = effectVolume
                if !looped { soundEffectPlayer.numberOfLoops = 0 } else { soundEffectPlayer.numberOfLoops = -1 }
                
                soundEffectPlayer.prepareToPlay()
                soundEffectPlayer.playInBackground(volume: effectVolume)
                completion(["player":soundEffectPlayer])
            }
            catch {
                print(error.localizedDescription)
                completion(["player":AVAudioPlayer()])
            }
        }
    }
    // Create SoundEffect struct
    typealias CompletionValue = (_ result: Dictionary<String, Any>?) -> Void
    func addNewSoundEffect(_ filename: String,_ url: URL,_ effectVolume:Float,_ looped:Bool) {
        let wrappedCompletion: CompletionValue = {[weak self] (result: Dictionary<String, Any>?) -> Void in
            guard let strongSelf = self else { return }
            if let player = result?["player"] {
                let soundEffect:SoundEffect = SoundEffect.init(player: player as! AVAudioPlayer, effectFilename: filename, wasSoundEffectPaused: false)
                strongSelf.soundEffects.append(soundEffect)
                let _ = strongSelf.soundEffects.endIndex
                //print("- effect player number \(index): - filename: \(soundEffect.effectFilename) - isPlaying? \(soundEffect.player.isPlaying)")
            }
        }
        playSingleSoundEffect(url,effectVolume,looped,completion:wrappedCompletion)
    }
    // Select SoundEffect from filename
    func getSoundEffectFromFilename(_ filename:String)->SoundEffect{
        if soundEffects.count > 0 {
            for soundEffect in soundEffects {
                if soundEffect.effectFilename == filename {
                    return soundEffect
                }
            }
        }
        return SoundEffect()
    }
    
    
    // Play a sound effect
    func playSoundEffect(filename: String, effectVolume:Float, looped:Bool = false){
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else { return }
        if soundEffects.count >= maxSoundEffects { // too many players reset the list
            soundEffects.remove(at: 0)
        }
        if soundEffects.count == 0 {
            addNewSoundEffect(filename,url,effectVolume,looped)
        } else {
            let soundEffect = getSoundEffectFromFilename(filename)
            if !soundEffect.effectFilename.isEmpty {
                if !soundEffect.player.isPlaying && !soundEffect.wasSoundEffectPaused && soundEffect.player.numberOfLoops == 0 { // re-cycle audio player
                    resumeSoundEffect(filename,effectVolume)
                } else {
                    addNewSoundEffect(filename,url,effectVolume,looped)
                }
            } else {
                addNewSoundEffect(filename,url,effectVolume,looped)
            }
        }
    }
    // Change the sound effect volume to all current effect sound recorded to soundEffects
    func changeSoundEffectVolume(effectVolume:Float) {
        guard soundEffects.count>0 else { return }
        for soundEffect in soundEffects {
            if let player = soundEffect.player {
                player.volume = effectVolume
            }
        }
    }
    // Pause sound effect
    func pauseSoundEffect(_ filename:String) {
        var soundEffect = getSoundEffectFromFilename(filename)
        if !soundEffect.effectFilename.isEmpty {
            if soundEffect.player.isPlaying {
                soundEffect.wasSoundEffectPaused = true
                soundEffect.player.pause()
            }
        }
    }
    
    // Resume sound effect
    func resumeSoundEffect(_ filename:String,_ effectVolume:Float) {
        var soundEffect = getSoundEffectFromFilename(filename)
        if !soundEffect.effectFilename.isEmpty {
            resetSoundEffectPlayer(filename)
            if !soundEffect.player.isPlaying {
                soundEffect.player.playInBackground(volume:effectVolume)
                soundEffect.wasSoundEffectPaused = false
            }
        }
    }
    // Stop the background music
    func stopSoundEffect(_ filename:String) {
        var soundEffect = getSoundEffectFromFilename(filename)
        if !soundEffect.effectFilename.isEmpty {
            if soundEffect.player.isPlaying {
                soundEffect.player.stop()
                soundEffect.wasSoundEffectPaused = false
            }
        }
    }
    // Reset the sound effect player
    func resetSoundEffectPlayer(_ filename:String) {
        var soundEffect = getSoundEffectFromFilename(filename)
        if !soundEffect.effectFilename.isEmpty {
            if soundEffect.player.isPlaying {
                soundEffect.wasSoundEffectPaused = false
                soundEffect.player.stop()
            }
            soundEffect.player.currentTime = 0.0
        }
    }
    
    // Pause all sound effects 
    func pauseAllSoundEffects() {
        for i in 0..<soundEffects.count {
            var soundEffect = soundEffects[i]
            if !soundEffect.wasSoundEffectPaused {
                if soundEffect.player.isPlaying {
                    soundEffect.wasSoundEffectPaused = true
                    soundEffect.player.pause()
                }
            }
        }
    }
    // Resume all sound effects
    func resumeAllSoundEffects(effectVolume:Float) {
        for i in 0..<soundEffects.count {
            var soundEffect = soundEffects[i]
            if soundEffect.wasSoundEffectPaused {
                if !soundEffect.player.isPlaying {
                    soundEffect.player.playInBackground(volume: effectVolume)
                    soundEffect.wasSoundEffectPaused = false
                }
            }
        }
    }
    func stopAllSoundEffects() {
        for i in 0..<soundEffects.count {
            var soundEffect = soundEffects[i]
            if !soundEffect.wasSoundEffectPaused {
                if soundEffect.player.isPlaying {
                    soundEffect.wasSoundEffectPaused = false
                    soundEffect.player.stop()
                }
            }
        }
    }
}
// #-#-#-#-#-#-#-#-#-#-#-#-#-#-#
//MARK: - AVAudioPlayer Extensions
// #-#-#-#-#-#-#-#-#-#-#-#-#-#-#

extension AVAudioPlayer {
    func fadeOut(vol:Float) {
        if volume > vol {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.volume -= 0.01
                strongSelf.fadeOut(vol: vol)
            }
        } else {
            volume = vol
        }
    }
    func fadeIn(vol:Float) {
        if volume < vol {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.volume += 0.01
                strongSelf.fadeIn(vol: vol)
            }
        } else {
            volume = vol
        }
    }
    func playInBackground(volume:Float) {
        let backgroundQueue = DispatchQueue(label: "com.app.queue", qos: .background, target: nil)
        backgroundQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.volume = volume
            strongSelf.play()
        }
    }
}

