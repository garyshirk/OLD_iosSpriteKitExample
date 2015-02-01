//  GameViewController.swift
//  Cannon

import AVFoundation
import UIKit
import SpriteKit

var blockerHitSound: AVAudioPlayer!
var targetHitSound: AVAudioPlayer!
var cannonFireSound: AVAudioPlayer!

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load sounds
        blockerHitSound = AVAudioPlayer(contentsOfURL:NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("blocker_hit", ofType: "wav")!), error: nil)
        targetHitSound = AVAudioPlayer(contentsOfURL:NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("target_hit", ofType: "wav")!), error: nil)
        cannonFireSound = AVAudioPlayer(contentsOfURL:NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("cannon_fire", ofType: "wav")!), error: nil)
        
        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .AspectFill
        
        let skView = view as SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
    }

//    override func shouldAutorotate() -> Bool {
//        return true
//    }
//
//    override func supportedInterfaceOrientations() -> Int {
//        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
//            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
//        } else {
//            return Int(UIInterfaceOrientationMask.All.rawValue)
//        }
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Release any cached data, images, etc that aren't in use.
//    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
