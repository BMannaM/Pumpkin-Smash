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

    override func didMove(to view: SKView) {
        hammer = Hammer()
        hammer.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(hammer)
    }
    
    // Touch began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        isTouching = true
        let touchLocation = touch.location(in: self)
        
        // Create dot1 at touch location
        dot1 = SKShapeNode(circleOfRadius: 5)
        dot1?.fillColor = .red
        dot1?.position = touchLocation
        dot1?.zPosition = 2
        addChild(dot1!)
        
        // Create dotted line from dot1 to the hammer's position
        drawDottedLine(from: dot1!.position, to: hammer.position)
        
        // Create dot2 at touch location (initially same as dot1)
        dot2 = SKShapeNode(circleOfRadius: 5)
        dot2?.fillColor = .blue
        dot2?.position = touchLocation
        dot2?.zPosition = 2
        addChild(dot2!)
        
        // Create solid line between dot1 and dot2
        drawSolidLine(from: dot1!.position, to: dot2!.position)
        
        // Rotate hammer based on touch input
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
    
    func rotateHammerBasedOnTouch() {
        guard let dot1 = dot1, let dot2 = dot2 else { return }
        
        let desiredAngle = atan2(dot2.position.y - dot1.position.y, dot2.position.x - dot1.position.x)
        let rotationAngle = desiredAngle + CGFloat.pi - hammer.hammerAxisAngle
        
        hammer.rotateToAngle(rotationAngle)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endTouch()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        endTouch()
    }
    
    func endTouch() {
        isTouching = false
        
        // Remove TEST UI
        dot1?.removeFromParent()
        dot2?.removeFromParent()
        dottedLine?.removeFromParent()
        solidLine?.removeFromParent()
        
        // Reset variables
        dot1 = nil
        dot2 = nil
        dottedLine = nil
        solidLine = nil
    }
    
    func drawDottedLine(from start: CGPoint, to end: CGPoint) {
        // Remove existing dotted line
        dottedLine?.removeFromParent()
        
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        let dashedPattern: [CGFloat] = [10.0, 5.0] // Dash and gap lengths
        let dashedPath = path.copy(dashingWithPhase: 0, lengths: dashedPattern)
        dottedLine = SKShapeNode(path: dashedPath)
        dottedLine?.strokeColor = .gray
        dottedLine?.lineWidth = 2
        dottedLine?.zPosition = 1
        addChild(dottedLine!)
    }
    
    func drawSolidLine(from start: CGPoint, to end: CGPoint) {
        // Remove existing solid line
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
}
