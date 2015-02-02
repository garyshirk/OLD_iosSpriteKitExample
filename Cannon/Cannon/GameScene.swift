// GameScene.swift
// Creates the scene, detects touches and responds to collisions
import AVFoundation
import SpriteKit

// used to identify objects for collision detection
struct CollisionCategory {
    static let Blocker : UInt32 = 1
    static let Target: UInt32 = 1 << 1 // 2
    static let Cannonball: UInt32 = 1 << 2 // 4
    static let Wall: UInt32 = 1 << 3 // 8
}

// global because no type constants in Swift classes yet
private let numberOfTargets = 9

class GameScene: SKScene, SKPhysicsContactDelegate {
    // game elements that the scene interacts with programmatically
    private var secondsLabel: SKLabelNode! = nil
    private var cannon: Canon! = nil
    
    // game state
    private var timeLeft: CFTimeInterval = 10.0
    private var elapsedTime: CFTimeInterval = 0.0
    private var previousTime: CFTimeInterval = 0.0
    private var targetsRemaining: Int = numberOfTargets
    
    // called when scene is presented
    override func didMoveToView(view: SKView) {
        self.backgroundColor = SKColor.whiteColor() // set background
        
        // helps determine game element speeds based on scene size
        var velocityMultiplier = self.size.width / self.size.height
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            velocityMultiplier = CGFloat(velocityMultiplier * 6.0)
        }
        
        // configure the physicsWorld
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0) // no gravity
        self.physicsWorld.contactDelegate = self
        
        // create border for objects colliding with screen edges
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.friction = 0.0 // no friction
        self.physicsBody?.categoryBitMask = CollisionCategory.Wall
        self.physicsBody?.contactTestBitMask = CollisionCategory.Cannonball
        
        createLabels() // display labels at scene's top-left corner
        
        // create and attach Cannon
        cannon = Canon(sceneSize: size,
            velocityMultiplier: velocityMultiplier)
        cannon.position = CGPointMake(0.0, self.frame.height / 2.0)
        self.addChild(cannon)
        
        // create and attach medium Blocker and start moving
        let blockerxPercent = CGFloat(0.5)
        let blockeryPercent = CGFloat(0.25)
        let blocker = Blocker(sceneSize: self.frame.size,
            blockerSize: BlockerSize.Medium)
        blocker.position = CGPointMake(self.frame.width * blockerxPercent,
            self.frame.height * blockeryPercent)
        self.addChild(blocker)
        blocker.startMoving(velocityMultiplier)
        
        // create and attach targets of random sizes and start moving
        let targetxPercent = CGFloat(0.6) // % across scene to 1st target
        var targetX = size.width * targetxPercent
        
        for i in 1 ... numberOfTargets {
            let target = Target(sceneSize: self.frame.size)
            target.position = CGPointMake(targetX, self.frame.height * 0.5)
            targetX += target.size.width + 5.0
            self.addChild(target)
            target.startMoving(velocityMultiplier)
        }
    }
    
    // create the text labels
    func createLabels() {
        // constants related to displaying text for time remaining
        let edgeDistance = CGFloat(20.0)
        let labelSpacing = CGFloat(5.0)
        let fontSize = CGFloat(16.0)
        
        // configure "Time remaining: " label
        let timeRemainingLabel = SKLabelNode(fontNamed: "Chalkduster")
        timeRemainingLabel.text = "Time remaining:"
        timeRemainingLabel.fontSize = fontSize
        timeRemainingLabel.fontColor = SKColor.blackColor()
        timeRemainingLabel.horizontalAlignmentMode = .Left
        let y = self.frame.height -
            timeRemainingLabel.fontSize - edgeDistance
        timeRemainingLabel.position = CGPoint(x: edgeDistance, y: y)
        self.addChild(timeRemainingLabel)
        
        // configure label for displaying time remaining
        secondsLabel = SKLabelNode(fontNamed: "Chalkduster")
        secondsLabel.text = "0.0 seconds"
        secondsLabel.fontSize = fontSize
        secondsLabel.fontColor = SKColor.blackColor()
        secondsLabel.horizontalAlignmentMode = .Left
        let x = timeRemainingLabel.calculateAccumulatedFrame().width +
            edgeDistance + labelSpacing
        secondsLabel.position = CGPoint(x: x, y: y)
        self.addChild(secondsLabel)
    }
    
    // test whether an SKPhysicsBody is the cannonball
    func isCannonball(body: SKPhysicsBody) -> Bool {
        return body.categoryBitMask & CollisionCategory.Cannonball != 0
    }
    
    // test whether an SKPhysicsBody is a blocker
    func isBlocker(body: SKPhysicsBody) -> Bool {
        return body.categoryBitMask & CollisionCategory.Blocker != 0
    }
    
    // test whether an SKPhysicsBody is a target
    func isTarget(body: SKPhysicsBody) -> Bool {
        return body.categoryBitMask & CollisionCategory.Target != 0
    }
    
    // test whether an SKPhysicsBody is a wall
    func isWall(body: SKPhysicsBody) -> Bool {
        return body.categoryBitMask & CollisionCategory.Wall != 0
    }
    
    // called when collision starts
    func didBeginContact(contact: SKPhysicsContact) {
        var cannonball: SKPhysicsBody
        var otherBody: SKPhysicsBody
        
        // determine which SKPhysicsBody is the cannonball
        if isCannonball(contact.bodyA) {
            cannonball = contact.bodyA
            otherBody = contact.bodyB
        } else {
            cannonball = contact.bodyB
            otherBody = contact.bodyA
        }
        
        // cannonball hit wall, so remove from screen
        if isWall(otherBody) || isTarget(otherBody) ||
            isBlocker(otherBody) {
                cannon.cannonBallOnScreen = false
                cannonball.node?.removeFromParent()
        }
        
        // cannonball hit blocker, so play blocker sound
        if isBlocker(otherBody) {
            let blocker = otherBody.node as Blocker
            blocker.playHitSound()
            timeLeft -= blocker.blockerTimePenalty()
        }
        
        // cannonball hit target
        if isTarget(otherBody) {
            --targetsRemaining
            let target = otherBody.node as Target
            target.removeFromParent()
            target.playHitSound()
            timeLeft += target.targetTimeBonus()
        }
    }
    
    // fire the cannon if there is not a cannonball on screen
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch in touches.allObjects as [UITouch] {
            let location = touch.locationInNode(self)
            cannon.rotateToPointAndFire(location, scene: self)
        }
    }
    
    // updates to perform in each frame of the animation
    override func update(currentTime: CFTimeInterval) {
        if previousTime == 0.0 {
            previousTime = currentTime
        }
        
        elapsedTime += (currentTime - previousTime)
        timeLeft -= (currentTime - previousTime)
        previousTime = currentTime
        
        if timeLeft < 0 {
            timeLeft = 0
        }
        
        secondsLabel.text = String(format: "%.1f seconds", timeLeft)
        
        // check whether game is over
        if targetsRemaining == 0 || timeLeft <= 0 {
            runAction(SKAction.runBlock({self.gameOver()}))
        }
    }
    
    // display the game over scene
    func gameOver() {
//        let flipTransition = SKTransition.flipHorizontalWithDuration(1.0)
//        let gameOverScene = GameOverScene(size: self.size,
//            won: targetsRemaining == 0 ? true : false,
//            time: elapsedTime)
//        gameOverScene.scaleMode = .AspectFill
//        self.view?.presentScene(gameOverScene, transition: flipTransition)
    }
}



/*************************************************************************
* (C) Copyright 2015 by Deitel & Associates, Inc. All Rights Reserved.   *
*                                                                        *
* DISCLAIMER: The authors and publisher of this book have used their     *
* best efforts in preparing the book. These efforts include the          *
* development, research, and testing of the theories and programs        *
* to determine their effectiveness. The authors and publisher make       *
* no warranty of any kind, expressed or implied, with regard to these    *
* programs or to the documentation contained in these books. The authors *
* and publisher shall not be liable in any event for incidental or       *
* consequential damages in connection with, or arising out of, the       *
* furnishing, performance, or use of these programs.                     *
*                                                                        *
* As a user of the book, Deitel & Associates, Inc. grants you the        *
* nonexclusive right to copy, distribute, display the code, and create   *
* derivative apps based on the code. You must attribute the code to      *
* Deitel & Associates, Inc. and reference the book's web page at         *
* www.deitel.com/books/ios8fp1/. If you have any questions, please email *
* at deitel@deitel.com.                                                  *
*************************************************************************/


