//
//  Canon.swift
//  Cannon

import AVFoundation
import SpriteKit

class Canon: SKNode {
    
    // constants
    private let cannonSizePercent = CGFloat(0.15)
    private let cannonballSizePercent = CGFloat(0.075)
    private let cannonBarrelWidthPercent = CGFloat(0.075)
    private let cannonBarrelLengthPercent = CGFloat(0.15)
    private let cannonballSpeed: CGFloat
    private let cannonBallSpeedMultiplier = CGFloat(0.15)
    private let barrelLength: CGFloat
    
    private var barrelAngle = CGFloat(0.0)
    private var cannonball: SKSpriteNode!
    
    var cannonBallOnScreen = false
    
    init(sceneSize: CGSize, velocityMultiplier: CGFloat) {
        cannonballSpeed = cannonBallSpeedMultiplier * velocityMultiplier
        barrelLength = sceneSize.height * cannonBarrelLengthPercent
        super.init()
        
        // configure cannon barrel
        let barrel = SKShapeNode(rectOfSize: CGSizeMake(barrelLength, sceneSize.height * cannonBarrelWidthPercent))
        barrel.fillColor = SKColor.blackColor()
        self.addChild(barrel)

        // configure cannon base
        let cannonBase = SKSpriteNode(imageNamed: "base")
        cannonBase.size = CGSizeMake(sceneSize.height * cannonSizePercent, sceneSize.height * cannonSizePercent)
        self.addChild(cannonBase)
        
        // position barrel based on cannon base
        barrel.position = CGPointMake(cannonBase.size.width / 2.0, 0.0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func rotateToPointAndFire(point: CGPoint, scene: SKScene) {
        
        let deltaX = point.x
        let deltaY = point.y
        barrelAngle = CGFloat(atan2f(Float(deltaY), Float(deltaX)))
        
        // rotate cannon barrel to touch point, then fire
        let rotateAction = SKAction.rotateToAngle(barrelAngle, duration: 0.25, shortestUnitArc: true)
        
        // perform rotate, then fire
        self.runAction(rotateAction, completion: {
            if !self.cannonBallOnScreen {
                self.fireCannonball(scene)
            }
        })
    }
    
    private func fireCannonball(scene: SKScene) {
        
        cannonBallOnScreen = true
        
        // determine starting point for cannonball based on barrelLength and current barrelAngle
        let x = cos(barrelAngle) * barrelLength
        let y = sin(barrelAngle) * barrelLength
        let cannonball = createCannonball(scene.frame.size)
        cannonball.position = CGPointMake(x, self.position.y + y)
        
        let velocityVector = CGVectorMake(x * cannonballSpeed, y * cannonballSpeed)
        
        // put cannonball on screen, move it and play fire sound
        scene.addChild(cannonball)
        cannonball.physicsBody?.applyImpulse(velocityVector)
        cannonFireSound.play()
        
    }
    
    func createCannonball(sceneSize: CGSize) -> SKSpriteNode {
        cannonball = SKSpriteNode(imageNamed: "ball")
        cannonball.size =
            CGSizeMake(sceneSize.height * cannonballSizePercent,
                sceneSize.height * cannonballSizePercent)
        
        // set up physicsBody
        cannonball.physicsBody =
            SKPhysicsBody(circleOfRadius: cannonball.size.width / 2.0)
        cannonball.physicsBody?.friction = 0.0
        cannonball.physicsBody?.restitution = 1.0
        cannonball.physicsBody?.linearDamping = 0.0
        cannonball.physicsBody?.allowsRotation = true
        cannonball.physicsBody?.usesPreciseCollisionDetection = true
        cannonball.physicsBody?.categoryBitMask = CollisionCategory.Cannonball
        cannonball.physicsBody?.contactTestBitMask = CollisionCategory.Target | CollisionCategory.Blocker | CollisionCategory.Wall
        return cannonball
    }

}
