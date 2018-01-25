//
//  ViewController.swift
//  AudioManager
//
//  Created by Alessandro Ornano on 25/01/2018.
//  Copyright © 2018 Alessandro Ornano. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let audioManager = AudioManager.sharedInstance
    
    @IBOutlet weak var backgroundMusicBtn: UIButton!
    @IBOutlet weak var coinBtn: UIButton!
    @IBOutlet weak var laughingBtn: UIButton!
    @IBOutlet weak var levelUpBtn: UIButton!
    @IBOutlet weak var gameOverBtn: UIButton!
    @IBOutlet weak var generateRandomBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func backgroundMusicBtnTap(_ sender: Any) {
        audioManager.playBackgroundMusic(filename: "backgroundMusic.mp3", musicVolume: 1.0)
    }

    @IBAction func cointBtnTap(_ sender: Any) {
        audioManager.playSoundEffect(filename: "coin.wav", effectVolume: 1.0)
    }
    
    @IBAction func laughingBtnTap(_ sender: Any) {
        audioManager.playSoundEffect(filename: "laughing.mp3", effectVolume: 1.0)
    }
    
    @IBAction func levelBtnTap(_ sender: Any) {
        audioManager.playSoundEffect(filename: "levelUp.wav", effectVolume: 1.0)
    }
    
    @IBAction func gameOverBtnTap(_ sender: Any) {
        audioManager.playSoundEffect(filename: "gameOver.wav", effectVolume: 1.0)
    }
    
    
}

