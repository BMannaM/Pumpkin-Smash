//
//  GameScene.swift
//  Pumpkin Smash
//
//  Created by Jack.Zhang.Z on 11/18/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var hammer: Hammer!
    
    var dot1: SKShapeNode?
    var dot2: SKShapeNode?
    var dottedLine: SKShapeNode?
    var solidLine: SKShapeNode?
    var isTouching = false

    let maxForceMagnitude: CGFloat = 800.0
    let bulletTimeSpeed: CGFloat = 0.2
    
    override func didMove(to view: SKView) {
        hammer = Hammer()
        hammer.position = CGPoint(x: size.width / 2, y: size.height / 2)
        hammer.gameScene = self
        addChild(hammer)
    }
    
    // Touch began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        isTouching = true
        let touchLocation = touch.location(in: self)
        
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
        
        // Determine the maximum allowable force magnitude
//        let maxForce = maxForceMagnitude
        
        // Avoid too large force
        let scale = min(forceMagnitude, maxForceMagnitude) / forceMagnitude
        forceVector.dx *= scale
        forceVector.dy *= scale
//        print(scale)
        
        // Apply the force to the hammer's physics body
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
    
    func drawDottedLine(from start: CGPoint, to end: CGPoint) {
        // Remove dotted line if exists
        dottedLine?.removeFromParent()
        
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
    
    func drawSolidLine(from start: CGPoint, to end: CGPoint) {
        // Remove solid line if exists
        solidLine?.removeFromParent()
        
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        
        solidLine = SKShapeNode(path: path)
        solidLine?.strokeColor = .green
        solidLine?.lineWidth = 2
        solidLine?.zPosition = 1
        addChild(solidLine!)
    }
    
    func enableBulletTime() {
        self.speed = bulletTimeSpeed
        self.physicsWorld.speed = bulletTimeSpeed
    }
    
    func disableBulletTime() {
        self.speed = 1.0
        self.physicsWorld.speed = 1.0
    }
}
