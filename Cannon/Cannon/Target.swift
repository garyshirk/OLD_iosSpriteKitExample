//
//  Target.swift
//  Cannon
//
import AVFoundation
import SpriteKit

enum TargetSize: CGFloat {
    case Small = 1.0
    case Medium = 1.5
    case Large = 2.0
}

enum TargetColor: String {
    case Red = "target_red"
    case Green = "target_green"
    case Blue = "target_blue"
}

private let targetColors = [TargetColor.Red, TargetColor.Green, TargetColor.Blue]
private let targetSizes = [TargetSize.Small, TargetSize.Medium, TargetSize.Large]

class Target: SKSpriteNode {
    
    private let targetWidthPercent = CGFloat(0.025)
    private let targetHeightPercent = CGFloat(0.1)
    private let targetSpeed = CGFloat(2.0)
    private let targetColor: TargetColor
    private let targetSize: TargetSize
    
    init(sceneSize: CGSize) {
        
        self.targetSize = targetSizes[Int(arc4random_uniform(UInt32(targetSizes.count)))]
        self.targetColor = targetColors[Int(arc4random_uniform(UInt32(targetColors.count)))]
        
        super.init(texture: SKTexture(imageNamed: targetColor.rawValue),
            color: nil,
            size: CGSizeMake(sceneSize.width * targetWidthPercent, sceneSize.height * targetHeightPercent * targetSize.rawValue))
        
        self.physicsBody = SKPhysicsBody(texture: self.texture, size: self.size)
        self.physicsBody?.friction = 0.0
        self.physicsBody?.restitution = 1.0
        self.physicsBody?.linearDamping = 0.0
        self.physicsBody?.allowsRotation = true
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = CollisionCategory.Target
        self.physicsBody?.contactTestBitMask = CollisionCategory.Cannonball
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // apply impulse to target
    func startMoving(velocityMultiplier: CGFloat) {
        self.physicsBody?.applyImpulse(CGVectorMake(0.0, velocityMultiplier * targetSize.rawValue * (targetSpeed + CGFloat(arc4random_uniform(UInt32(targetSpeed) + 5)))))
    }
    
    // play target hit sound
    func playHitSound() {
        targetHitSound.play()
    }
    
    // return time bonus for hitting a target
    func targetTimeBonus() -> CFTimeInterval {
        switch targetSize {
            case .Small:
                return 3.0
            case .Medium:
                return 2.0
            case .Large:
                return 1.0
        }
    }
}
