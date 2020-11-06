//
//  GameScene.swift
//  Milestone 16-18 SpriteKit Bird Shooting Game
//
//  Created by Edil Ashimov on 5/2/20.
//  Copyright © 2020 Edil Ashimov. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    var weapon: SKSpriteNode!
    var fingerLocation = CGPoint()
    var ballBullet: SKSpriteNode!
    var bird:SKSpriteNode!
    var birdsCount = 0
    var gameTimer:Timer!
    
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.zPosition = -1
        background.blendMode = .replace
        background.position = CGPoint(x: 512, y: 384)
        addChild(background)
        
        weapon = SKSpriteNode(imageNamed: "weapon")
        weapon.zPosition = 1
        weapon.position = CGPoint(x: 512, y: 100)
        weapon.name = "weapon"
        //        weapon.physicsBody = SKPhysicsBody(texture: weapon.texture!, size: weapon.size)
        //        weapon.physicsBody?.angularVelocity = 0
        //        weapon.physicsBody?.linearDamping = 0
        //        weapon.physicsBody?.angularDamping = 0
        addChild(weapon)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        
        
        gameTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Int.random(in: 2...4)), target: self, selector: #selector(bringBirdsOut), userInfo: nil, repeats: true)
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let tappedNotes = nodes(at: touch.location(in: self))
        for touch: AnyObject in touches { fingerLocation = touch.location(in: self) }
        for node in tappedNotes {
            if node.name == "weapon" || node.name == "ballBullet"{
                weapon.position = CGPoint(x: weapon.position.x, y: weapon.position.y-20)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        for touch: AnyObject in touches { fingerLocation = touch.location(in: self) }
        let tappedNotes = nodes(at: touch.location(in: self))
        for node in tappedNotes {
            if node.name == "weapon" {
                let radians = atan2(fingerLocation.x - weapon.position.x, fingerLocation.y - weapon.position.y)
                weapon.zRotation = -radians//this rotate
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let tappedNotes = nodes(at: touch.location(in: self))
        for node in tappedNotes {
            if node.name == "weapon" || node.name == "ballBullet" {
                shootAt(touch.location(in: self))
                weapon.position = CGPoint(x: weapon.position.x, y: weapon.position.y+20)
            }
            
            
        }
    }
    
    func shootAt(_ location: CGPoint) {
        
        ballBullet = SKSpriteNode(imageNamed: "ball")
        ballBullet.position = CGPoint(x: location.x, y: location.y)
        ballBullet.zPosition = 2
        ballBullet.physicsBody = SKPhysicsBody(texture: ballBullet.texture!, size: ballBullet.size)
        ballBullet.physicsBody?.categoryBitMask = 1
        ballBullet.run(SKAction.move(by: CGVector(dx: location.x - weapon.position.x, dy: 1000), duration: 0.2))
        
        ballBullet.physicsBody?.angularVelocity = 1
        ballBullet.physicsBody?.linearDamping = 0
        ballBullet.physicsBody?.angularDamping = 0
        ballBullet.name = "ballBullet"
        addChild(ballBullet)
    }
    
    @objc func bringBirdsOut () {
        if birdsCount < 6 {
            let monsterWalkTextures = [SKTexture(imageNamed: "bird1"),SKTexture(imageNamed: "bird2")]
            let walkAnimation = SKAction.repeatForever(SKAction.animate(with: monsterWalkTextures,
                                                                        timePerFrame: 0.2))
            bird = SKSpriteNode(imageNamed: "bird1")
            bird.position = CGPoint(x: 1000, y: 670)
            bird.physicsBody = SKPhysicsBody(texture: bird.texture!, size: bird.size)
            bird.physicsBody?.contactTestBitMask = 1
            bird.physicsBody?.angularVelocity = 0
            bird.physicsBody?.linearDamping = 0
            bird.physicsBody?.angularDamping = 0
            bird.zPosition = 2
            
            bird.name = "bird"
            addChild(bird)
            bird.run(walkAnimation)
            bird.run(SKAction.repeat(SKAction.move(to: CGPoint(x: -200, y: 700), duration: 2.5), count: 5))
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let bodyA = contact.bodyA.node else { return }
        guard let bodyB = contact.bodyB.node else { return }
        
        if bodyA.name == "bird"  || bodyB.name == "bird" {
            createExplosion()
            birdsCount += 1
        }
    }
    
    func createExplosion() {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = bird.position
        addChild(explosion)
        bird.removeFromParent()
        ballBullet.removeFromParent()
        run(SKAction.playSoundFileNamed("explosionSFX.mp3", waitForCompletion: false))
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if let bird = self.childNode(withName: "bird") {
            if !intersects(bird) {
                print("out of screen")
            }
            
        }
    }
}
