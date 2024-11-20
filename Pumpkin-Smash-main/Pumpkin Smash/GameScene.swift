//
//  GameScene.swift
//  Pumpkin Smash
//
//  Created by Jack.Zhang.Z on 11/18/24.
//
import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    struct PhysicsCategory {
        static let none: UInt32 = 0
        static let hammer: UInt32 = 0b1
        static let pumpkin: UInt32 = 0b10
    }
    var hammer: Hammer!
    
    var dot1: SKShapeNode?
    var dot2: SKShapeNode?
    var dottedLine: SKShapeNode?
    var solidLine: SKShapeNode?
    var isTouching = false
    var score = 0
    let maxForceMagnitude: CGFloat = 800.0
    let bulletTimeSpeed: CGFloat = 0.2
    let pumpkinTexture = SKTexture(imageNamed: "pumpkin")
    var scoreLabel: SKLabelNode!
    var timeLabel: SKLabelNode!
    var timeRemaining = 15
    var countdownTimer: Timer?
    var isGameRunning = false
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        hammer = Hammer()
        hammer.position = CGPoint(x: size.width / 2, y: size.height / 2)
        hammer.gameScene = self
//        hammer.physicsBody = SKPhysicsBody(rectangleOf: hammer.size)
//        hammer.physicsBody?.isDynamic = true
//        hammer.physicsBody?.affectedByGravity = false
        hammer.physicsBody?.categoryBitMask = PhysicsCategory.hammer
        hammer.physicsBody?.contactTestBitMask = PhysicsCategory.pumpkin
        hammer.physicsBody?.collisionBitMask = PhysicsCategory.none
//        hammer.physicsBody?.allowsRotation = false
        addChild(hammer)
        backgroundColor = .black
        scoreLabel = self.childNode(withName: "//score") as? SKLabelNode
        timeLabel = self.childNode(withName: "//time") as? SKLabelNode
        timeLabel.text = "Time: \(timeRemaining)"
    }
    func updateScoreLabel() {
        scoreLabel.text = "Score: \(score)"
    }
    // Touch began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        if !isGameRunning {
            isGameRunning = true
            startNewRound()
    }
        isTouching = true
        enableBulletTime()
        
        // Create Red dot1 at touch location
        dot1 = SKShapeNode(circleOfRadius: 5)
        dot1?.fillColor = .red
        dot1?.position = touchLocation
        dot1?.zPosition = 2
        addChild(dot1!)
        
        // Create dotted line from dot1 to the hammer's position
        drawDottedLine(from: dot1!.position, to: hammer.position)
        
        // Create Blue dot2 at touch location (initially same as dot1)
        dot2 = SKShapeNode(circleOfRadius: 5)
        dot2?.fillColor = .blue
        dot2?.position = touchLocation
        dot2?.zPosition = 2
        addChild(dot2!)
        
        drawSolidLine(from: dot1!.position, to: dot2!.position)
        rotateHammerBasedOnTouch()
    }
    
    // Touch moved
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isTouching, let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        dot2?.position = touchLocation
        drawSolidLine(from: dot1!.position, to: dot2!.position)
        rotateHammerBasedOnTouch()
    }
    
    // Touch ended
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isTouching else { return }
        isTouching = false
        disableBulletTime()
        applyForceToHammer()
        cleanUICues()
    }
    
    // Touch cancelled
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
        disableBulletTime()
        cleanUICues()
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        let screenWidth = size.width
        let screenHeight = size.height
        
        let edgeThreshold: CGFloat = hammer.size.width / 2
        
        hammer.handleHorizontalWrapping(screenWidth: screenWidth, edgeThreshold: edgeThreshold)
        hammer.handleVerticalWrapping(screenHeight: screenHeight, edgeThreshold: edgeThreshold)
        hammer.handleDiagonalWrapping(screenWidth: screenWidth, screenHeight: screenHeight, edgeThreshold: edgeThreshold)
        
        // Update the dotted line's endpoint to the hammer's current position
        if isTouching {
            drawDottedLine(from: dot1!.position, to: hammer.position)
        }
    }
    
    // Rotate the hammer based on touch input
    func rotateHammerBasedOnTouch() {
        guard let dot1 = dot1, let dot2 = dot2 else { return }
        
        let desiredAngle = atan2(dot2.position.y - dot1.position.y, dot2.position.x - dot1.position.x)
        let rotationAngle = desiredAngle + CGFloat.pi - hammer.hammerAxisAngle
        
        hammer.rotateToAngle(rotationAngle)
    }
    
    func applyForceToHammer() {
        guard let dot1 = dot1, let dot2 = dot2 else { return }
        
        // Calculate the force vector from dot2 to dot1
        let dx = dot1.position.x - dot2.position.x
        let dy = dot1.position.y - dot2.position.y
        var forceVector = CGVector(dx: dx, dy: dy)
        
        // Calculate the magnitude of the force vector
        let forceMagnitude = sqrt(dx * dx + dy * dy)
//        print(forceMagnitude)
        
        // Avoid zero division
        guard forceMagnitude > 0 else { return }
        
        // Avoid too large force
        let scale = min(forceMagnitude, maxForceMagnitude) / forceMagnitude
        forceVector.dx *= scale
        forceVector.dy *= scale
//        print(scale)
        
        hammer.physicsBody?.applyForce(forceVector)
    }
    
    func cleanUICues() {
        dot1?.removeFromParent()
        dot2?.removeFromParent()
        dottedLine?.removeFromParent()
        solidLine?.removeFromParent()
        
        dot1 = nil
        dot2 = nil
        dottedLine = nil
        solidLine = nil
    }
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.hammer | PhysicsCategory.pumpkin {
            // Determine which node is the pumpkin
            let pumpkinNode = contact.bodyA.categoryBitMask == PhysicsCategory.pumpkin ? contact.bodyA.node : contact.bodyB.node
            
            // Remove the pumpkin from the scene
            pumpkinNode?.removeFromParent()
            
            // Increment the score
            score += 1
            updateScoreLabel()
        }
    }
    
    func drawDottedLine(from start: CGPoint, to end: CGPoint) {
        if let dottedLine = dottedLine {
            // Update the path of the existing dotted line
            let path = CGMutablePath()
            path.move(to: start)
            path.addLine(to: end)
            let dashedPattern: [CGFloat] = [10.0, 5.0]
            let dashedPath = path.copy(dashingWithPhase: 0, lengths: dashedPattern)
            dottedLine.path = dashedPath
        } else {
            // Create the dotted line if it doesn't exist
            let path = CGMutablePath()
            path.move(to: start)
            path.addLine(to: end)
            let dashedPattern: [CGFloat] = [10.0, 5.0]
            let dashedPath = path.copy(dashingWithPhase: 0, lengths: dashedPattern)
            dottedLine = SKShapeNode(path: dashedPath)
            dottedLine?.strokeColor = .gray
            dottedLine?.lineWidth = 2
            dottedLine?.zPosition = 1
            addChild(dottedLine!)
        }
    }
    
    func drawSolidLine(from start: CGPoint, to end: CGPoint) {
        if let solidLine = solidLine {
            // Update the path of the existing solid line
            let path = CGMutablePath()
            path.move(to: start)
            path.addLine(to: end)
            solidLine.path = path
        } else {
            // Create the solid line if it doesn't exist
            let path = CGMutablePath()
            path.move(to: start)
            path.addLine(to: end)
            solidLine = SKShapeNode(path: path)
            solidLine?.strokeColor = .systemGreen
            solidLine?.lineWidth = 2
            solidLine?.zPosition = 1
            addChild(solidLine!)
        }
    }
    
    func enableBulletTime() {
        self.speed = bulletTimeSpeed
        self.physicsWorld.speed = bulletTimeSpeed
    }
    
    func disableBulletTime() {
        self.speed = 1.0
        self.physicsWorld.speed = 1.0
    }
    func startNewRound() {
        isGameRunning = true
        timeRemaining = 15
        timeLabel.text = "Time: \(timeRemaining)"
        startSpawningPumpkins()
        startCountdownTimer()
    }
    
    func startSpawningPumpkins() {
        let spawn = SKAction.run {
            self.spawnPumpkin()
        }
        let wait = SKAction.wait(forDuration: 0.3, withRange: 0.2)
        let sequence = SKAction.sequence([spawn, wait])
        let continuousSpawn = SKAction.repeatForever(sequence)
        run(continuousSpawn, withKey: "spawningPumpkins")
    }
    
    func startCountdownTimer() {
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                self.timeLabel.text = "Time: \(self.timeRemaining)"
            }
            if self.timeRemaining <= 0 {
                self.countdownTimer?.invalidate()
                self.countdownTimer = nil
                self.stopGame()
            }
        }
    }
    
    func stopGame() {
        self.removeAction(forKey: "spawningPumpkins")
        isGameRunning = false
        self.enumerateChildNodes(withName: "pumpkin") { node, _ in
            node.removeFromParent()
        }
    }
    
    func spawnPumpkin() {
        let pumpkin = SKSpriteNode(texture: pumpkinTexture)
        pumpkin.size = CGSize(width: 50, height: 50)
        let randomYPosition = CGFloat.random(in: 50...(size.height - 50))
        pumpkin.position = CGPoint(x: -50, y: randomYPosition)
        pumpkin.zPosition = 1
        pumpkin.name = "pumpkin"
        pumpkin.physicsBody = SKPhysicsBody(rectangleOf: pumpkin.size)
        pumpkin.physicsBody?.isDynamic = true
        pumpkin.physicsBody?.affectedByGravity = false
        pumpkin.physicsBody?.categoryBitMask = PhysicsCategory.pumpkin
        pumpkin.physicsBody?.contactTestBitMask = PhysicsCategory.hammer
        pumpkin.physicsBody?.collisionBitMask = PhysicsCategory.none
        addChild(pumpkin)

        let moveToRight = SKAction.moveTo(x: size.width + 50, duration: 5.0)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveToRight, remove])
        pumpkin.run(sequence)
    }


}
