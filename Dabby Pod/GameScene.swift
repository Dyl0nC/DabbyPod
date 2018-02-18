//
//  GameScene.swift
//  Dabby Pod
//
//  Created by Dylan Cunningham on 2/17/18.
//  Copyright © 2018 Arkdabby Inc. All rights reserved.
//

import SpriteKit
import GameplayKit

struct physicsCategory {
    static let character : UInt32 = 0x1 << 1
    static let tidePod : UInt32 = 0x1 << 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var character: SKSpriteNode!
    var tidePod: SKSpriteNode!
    var startButton: SKSpriteNode!
    var restartButton: SKSpriteNode!
    var scoreLbl: SKLabelNode!
    
    var movePod: SKAction!
    
    var scoreCounter = 0.0
    
    var gameInPlay: Bool!
    
    var moveAndDeletePod: SKAction!
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        setupCharacter()
        
        scoreLbl = childNode(withName: "scoreLbl")! as! SKLabelNode
        
        gameInPlay = false
        startButton = SKSpriteNode(imageNamed: "StartButtonDabby")
        startButton.scale(to: CGSize(width: 295, height: 95))
        startButton.position = CGPoint(x: 0, y: 0)
        addChild(startButton)
        
        restartButton = SKSpriteNode(imageNamed: "RestartButton")
        restartButton.scale(to: CGSize(width: 295, height: 95))
        restartButton.position = CGPoint(x: 1000, y: 0)
        restartButton.isHidden = true
        addChild(restartButton)
    }
    
    func runGame() {
        let spawn = SKAction.run( {
            () in
            
            self.setupTidePod()
        })
        
        let delay = SKAction.wait(forDuration: 0.9)
        let spawnDelay = SKAction.sequence([spawn, delay])
        run(SKAction.repeatForever(spawnDelay))
    }
    
    func setupCharacter() {
        character = SKSpriteNode(imageNamed: "LeftDab3")
        character.scale(to: CGSize(width: 2020 / 10, height: 2366 / 10))
        character.position = CGPoint(x:  size.width / 6, y: -size.height / 2 + 30)
        
        
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x:-character.size.width / 2 + 10, y: 0), CGPoint(x: -character.size.width / 2 + 10, y: character.size.height / 2 - 10), CGPoint(x: character.size.width / 2 - 10, y: character.size.height / 2 - 10), CGPoint(x: character.size.width / 2 - 10, y: 0)])
        path.closeSubpath()
        
        character.physicsBody = SKPhysicsBody(edgeChainFrom: path)
        
        
        //character.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 100, height: 100))
        character.physicsBody?.categoryBitMask = physicsCategory.character
        character.physicsBody?.collisionBitMask = physicsCategory.tidePod
        character.physicsBody?.contactTestBitMask = physicsCategory.tidePod
        character.physicsBody?.isDynamic = false
        character.physicsBody?.affectedByGravity = false
        
        addChild(character)
    }
    
    func setupTidePod() {
        tidePod = SKSpriteNode(imageNamed: "TIDEPOD")
        tidePod.scale(to: CGSize(width: 60, height: 60))
        
        let rand = arc4random_uniform(2)
        var x = size.width / 4
        
        if(rand == 0) {
            x = -size.width / 4
        }
        
        tidePod.position = CGPoint(x: x, y: size.height / 2 + tidePod.size.height)
        
        tidePod.physicsBody = SKPhysicsBody(rectangleOf: tidePod.size)
        tidePod.physicsBody?.categoryBitMask = physicsCategory.tidePod
        tidePod.physicsBody?.collisionBitMask = physicsCategory.character
        tidePod.physicsBody?.contactTestBitMask = physicsCategory.character
        tidePod.physicsBody?.isDynamic = true
        tidePod.physicsBody?.affectedByGravity = false
        tidePod.zPosition = 3

        tidePod.run(moveAndDeletePod)
        addChild(tidePod)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location =  touch.location(in: self)
        
        if(startButton.contains(location) && !gameInPlay) {
            gameInPlay = true
            startButton.removeFromParent()
            let dodgeBTN1 = childNode(withName: "dodge1") as! SKSpriteNode
            dodgeBTN1.removeFromParent()
            let dodgeBTN2 = childNode(withName: "dodge2") as! SKSpriteNode
            dodgeBTN2.removeFromParent()
            runGame()
        }
        
        if(restartButton.contains(location) && gameInPlay) {
            
            if let view = self.view as! SKView? {
                // Load the SKScene from 'GameScene.sks'
                if let scene = SKScene(fileNamed: "GameScene") {
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFill
                    
                    // Present the scene
                    view.presentScene(scene)
                }
                
                view.ignoresSiblingOrder = true
            }
        }
        
        let distanceToMove = size.height + 120
        let bonus = (scoreCounter / 8.0) * 0.1
        if(bonus <= 0.8) {
            movePod = SKAction.moveBy(x: 0, y: -distanceToMove, duration: 1.3 - bonus)
        } else {
            movePod = SKAction.moveBy(x: 0, y: -distanceToMove, duration: 0.5)
        }
        

        let removePod = SKAction.removeFromParent()
        
        moveAndDeletePod = SKAction.sequence([movePod, removePod])
        
        
        if(location.x >= 0 && character.position.x < 0) {
            character.position = CGPoint(x:  size.width / 6, y: -size.height / 2 + 30)
            character.texture = SKTexture(imageNamed: "LeftDab3")
            scoreCounter += 1
        } else if(location.x < 0 && character.position.x > 0) {
            character.position = CGPoint(x: -size.width / 6, y: -size.height / 2 + 30)
            character.texture = SKTexture(imageNamed: "RightDab3")
            scoreCounter += 1
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        self.view?.isPaused = true
        
        restartButton.position = CGPoint(x: 0, y: 0)
        restartButton.isHidden = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        scoreLbl.text = String(Int(scoreCounter))
    }
}
