//
//  GameScene.swift
//  GalaxySaga
//
//  Created by Thush-Fdo on 21/06/2024.
//

import SpriteKit

enum CollisionType : UInt32{
    case player = 1
    case playerWeapon = 2
    case enemy = 4
    case enemyWeapon = 8
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKSpriteNode(imageNamed: "player")
    let healthIcon = SKSpriteNode(imageNamed: "healthicon")
    let nextHealthIcon = SKSpriteNode(imageNamed: "energy")
    let scoreIcon = SKSpriteNode(imageNamed: "score")
    
    let healthProgressTexture = SKTexture(imageNamed: "healthprogress")
    let nextHealthProgressTexture = SKTexture(imageNamed: "nexthealth")
    
    let scoreLabel = SKLabelNode(fontNamed: "Courier")
    
    let healthProgressBar = ProgressBar()
    let healthLabel = SKLabelNode(fontNamed: "Courier")
    
    let nextHealthProgressBar = ProgressBar()
    let nextHealthLabel = SKLabelNode(fontNamed: "Courier")
    
    let winner = SKLabelNode(fontNamed: "Chalkduster")
    
    let waves = Bundle.main.decode([Wave].self, from: "waves.json")
    let enemyTypes = Bundle.main.decode([EnemyType].self, from: "enemy-types.json")
    
    var isPlayerAlive = true
    var levelNumber = 0
    var waveNumber = 0
    var playerShields = 10.0
    var playerScore = 0.0
    var healthRefilMargin = 0.0
    var playerNextHealthPack = 5000.0
    var playerHitDamage = 0.334
    var playerEnemyDamageScore = 50.0
    var playerGainHealthPack = 0.334 * 5
    
    var touchCoordinates = CGFloat()
    
    let positions = Array(stride(from: -320, through: 320, by: 80))
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        if let particles = SKEmitterNode(fileNamed: "StarField"){
            particles.position = CGPoint(x: 1080, y: 0)
            particles.zPosition = -1
            particles.advanceSimulationTime(60)
            addChild(particles)
        }
        
        player.name = "player"
        player.position.x = frame.minX + 75
        player.zPosition = 1
        addChild(player)
        
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: (player.texture!.size()))
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        player.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        
        player.physicsBody?.isDynamic = false
        
        //score Icon
        scoreIcon.position = CGPoint(x: frame.minX + 65, y: frame.maxY - 65)
        scoreIcon.zPosition = 1
        addChild(scoreIcon)
        
        //score label
        scoreLabel.text = String(format: "%.1f%", 0.0)
        scoreLabel.fontColor = SKColor.white
        scoreLabel.fontSize = 25
        scoreLabel.position = CGPoint(x: scoreIcon.frame.maxX + 75, y: frame.maxY - 75)
        addChild(scoreLabel)
        
        //healthPack Icon
        nextHealthIcon.position = CGPoint(x: -150, y: frame.maxY - 65)
        nextHealthIcon.zPosition = 1
        addChild(nextHealthIcon)
        
        //healthPack Bar
        nextHealthProgressBar.getSceneFrame(sceneFrame: frame)
        nextHealthProgressBar.buildProgressBar(texture: nextHealthProgressTexture)
        nextHealthProgressBar.position = CGPoint(x: -35, y: frame.maxY - 65)
        addChild(nextHealthProgressBar)
        
        //healthPack label
        nextHealthLabel.text = String(format: "%.1f%", self.playerNextHealthPack)
        nextHealthLabel.fontColor = SKColor.white
        nextHealthLabel.fontSize = 25
        nextHealthLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 75)
        addChild(nextHealthLabel)
        
        //health Icon
        healthIcon.position = CGPoint(x: frame.maxX - 300, y: frame.maxY - 65)
        healthIcon.zPosition = 1
        addChild(healthIcon)
        
        //health Bar
        healthProgressBar.getSceneFrame(sceneFrame: frame)
        healthProgressBar.buildProgressBar(texture: healthProgressTexture)
        healthProgressBar.position = CGPoint(x: frame.maxX - 175, y: frame.maxY - 65)
        addChild(healthProgressBar)
        
        //health label
        healthLabel.text = String(format: "%.1f%%", 100.0)
        healthLabel.fontColor = SKColor.white
        healthLabel.fontSize = 20
        healthLabel.position = CGPoint(x: frame.maxX - 45, y: frame.maxY - 75)
        addChild(healthLabel)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        //setupHud()
        
        if player.position.y < frame.minY {
            player.position.y = frame.minY
        } else if player.position.y > frame.maxY {
            player.position.y = frame.maxY
        }
        
        for child in children{
            if child.frame.maxX < 0{
                if !frame.intersects(child.frame){
                    child.removeFromParent()
                }
            }
        }
        
        let activeEnemies = children.compactMap { $0 as? EnemyNode }
        
        if activeEnemies.isEmpty {
            createWave()
        }
        
        for enemy in activeEnemies {
            guard frame.intersects(enemy.frame) else { continue }
            if enemy.lastFireTime + 1  < currentTime {
                enemy.lastFireTime = currentTime
                
                if Int.random(in: 0...6) == 0 || Int.random(in: 0...6) == 3{
                    enemy.fire()
                }
            }
        }
    }
    
    func createWave(){
        guard isPlayerAlive else { return }
        
        if waveNumber == waves.count {
            levelNumber += 1
            waveNumber = 0
        }
        
        let currentWave = waves[waveNumber]
        waveNumber += 1
        
        let maximumEnemyType = min(enemyTypes.count, levelNumber + 1)
        let enemyType = Int.random(in: 0..<maximumEnemyType)
        
        let enemyOffsetX : CGFloat = 100
        let enemyStartX = 600
        
        if currentWave.enemies.isEmpty {
            for (index, position) in positions.shuffled().enumerated() {
                let enemy = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: enemyStartX, y: position), xOffset: enemyOffsetX * CGFloat(index * 3), moveStraight: true)
                addChild(enemy)
            }
        } else {
            for enemy in currentWave.enemies {
                let node = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: enemyStartX, y: positions[enemy.position]), xOffset: enemyOffsetX * enemy.xOffset, moveStraight: enemy.moveStraight)
                addChild(node)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        guard let touch = touches.first else {
        //            return
        //        }
        for t in touches {
            player.position.y = t.location(in: self).y
        }
        //player.position.y = touch.location(in: self).y
        
        //        debugPrint("\(location.x) is X and \(location.y) is Y")
        //        debugPrint("\(frame.minY) is Frame Min y and \(frame.maxY) is Frame Max Y")
        
        //touchCoordinates.y = location.y
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isPlayerAlive else { return }
        
        for t in touches {
            player.position.y = t.location(in: self).y
        }
        
        let shot = SKSpriteNode(imageNamed: "playerWeapon")
        shot.name = "playerWeapon"
        shot.position = player.position
        
        shot.physicsBody = SKPhysicsBody(rectangleOf: shot.size)
        shot.physicsBody?.categoryBitMask = CollisionType.playerWeapon.rawValue
        shot.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        shot.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        addChild(shot)
        
        let movement = SKAction.move(to: CGPoint(x: 1900, y: shot.position.y), duration: 5)
        let sequence = SKAction.sequence([movement, .removeFromParent()])
        shot.run(sequence)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        let sortedNodes = [nodeA, nodeB].sorted { $0.name ?? "" < $1.name ?? "" }
        let firstNode = sortedNodes[0]
        let secondNode = sortedNodes[1]
        
        if secondNode.name == "player" {
            guard isPlayerAlive else { return }
            
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = firstNode.position
                addChild(explosion)
            }
            playerShields -= playerHitDamage
            healthLabel.text = String(format: "%.1f%%", self.playerShields * 10)
            healthProgressBar.updateProgressBar(progress: self.playerShields * 10)
            
            if ((playerShields/10) * 100 > 35){
                healthLabel.fontColor = SKColor.white
            }else{
                healthLabel.fontColor = SKColor.red
            }
            
            if playerShields <= 0.0 {
                gameOver()
                playerShields = 0.0
                secondNode.removeFromParent()
            }
            
            firstNode.removeFromParent()
        } else if let enemy = firstNode as? EnemyNode {
            enemy.shields -= 1
            
            playerScore += playerEnemyDamageScore
            scoreLabel.text = String(format: "%.1f%", self.playerScore)
            
            healthRefilMargin += playerEnemyDamageScore
            nextHealthLabel.text = String(format: "%.1f%", self.playerNextHealthPack - healthRefilMargin)
            nextHealthProgressBar.updateNextHealthProgressBar(progress: (self.playerNextHealthPack - healthRefilMargin) / playerNextHealthPack)
            
            if enemy.shields == 0 {
                if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                    explosion.position = enemy.position
                    addChild(explosion)
                    playerScore += Double(enemy.scoreLevel) * playerEnemyDamageScore
                    healthRefilMargin += Double(enemy.scoreLevel) * playerEnemyDamageScore
                }
                
                scoreLabel.text = String(format: "%.1f%", self.playerScore)
                nextHealthLabel.text = String(format: "%.1f%", self.playerNextHealthPack - healthRefilMargin)
                nextHealthProgressBar.updateNextHealthProgressBar(progress: (self.playerNextHealthPack - healthRefilMargin) / playerNextHealthPack)
                enemy.removeFromParent()
            }
            
            if(healthRefilMargin >= playerNextHealthPack){
                healthRefilMargin = healthRefilMargin - playerNextHealthPack
                playerNextHealthPack = 5000.0
                playerShields += playerGainHealthPack
                
                if(playerShields >= 10.0){
                    playerShields = 10.0
                }
                
                healthLabel.text = String(format: "%.1f%%", self.playerShields * 10)
                healthProgressBar.updateProgressBar(progress: self.playerShields * 10)
                nextHealthLabel.text = String(format: "%.1f%", self.playerNextHealthPack - healthRefilMargin)
                nextHealthProgressBar.updateNextHealthProgressBar(progress: (self.playerNextHealthPack - healthRefilMargin) / playerNextHealthPack)
            }
            
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = enemy.position
                addChild(explosion)
            }
            
            secondNode.removeFromParent()
        } else {
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = secondNode.position
                addChild(explosion)
            }
            
            firstNode.removeFromParent()
            secondNode.removeFromParent()
        }
    }
    
    func gameOver() {
        isPlayerAlive = false
        
        healthLabel.text = String(format: "%.1f%%", 0.0)
        healthProgressBar.updateProgressBar(progress: self.playerShields * 10)
        
        if let explosion = SKEmitterNode(fileNamed: "Explosion") {
            explosion.position = player.position
            addChild(explosion)
        }
        
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        addChild(gameOver)
    }
}
