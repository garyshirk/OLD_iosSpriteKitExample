//
//  Blocker.swift
//  Cannon

import SpriteKit
import AVFoundation

enum BlockerSize: CGFloat {
    case Small = 1.0
    case Medium = 2.0
    case Large = 3.0
}

class Blocker: SKSpriteNode {
    
    private let blockerWidthPercent = CGFloat(0.025)
    private let blockerHeightPercent = CGFloat(0.125)
    private let blockerSpeed = CGFloat(5.0)
    private let blockerSize: BlockerSize
    
    init(sceneSize: CGSize, blockerSize: BlockerSize) {
        
        self.blockerSize = blockerSize
        
        super.init(texture: SKTexture(imageNamed: "blocker"),
            color: nil,
            size: CGSizeMake(sceneSize.width * blockerWidthPercent, sceneSize.height * blockerHeightPercent * blockerSize.rawValue))
        
        // physics body
        self.physicsBody = SKPhysicsBody(texture: self.texture, size: self.size)
        self.physicsBody?.friction = 0.0
        self.physicsBody?.restitution = 1.0
        self.physicsBody?.linearDamping = 0.0
        self.physicsBody?.allowsRotation = true
        self.physicsBody?.usesPreciseCollisionDetection = true
        //self.physicsBody?.categoryBitMask = CollisionCategory.Blocker
        //self.physicsBody?.contactTestBitMask = CollisionCategory.Cannonball
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // apply impulse to blocker
    func startMoving(velocityMultiplier: CGFloat) {
        self.physicsBody?.applyImpulse(CGVectorMake(0.0, velocityMultiplier * blockerSpeed * blockerSize.rawValue))
    }
    
    // play blocker hit sound
    func playHitSound() {
        blockerHitSound.play()
    }
    
    // time penalty
    func blockerTimePenalty() -> CFTimeInterval {
        return CFTimeInterval(BlockerSize.Small.rawValue)
    }
}
