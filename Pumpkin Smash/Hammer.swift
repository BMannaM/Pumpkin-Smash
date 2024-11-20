//
//  Hammer.swift
//  Pumpkin Smash
//
//  Created by Jack.Zhang.Z on 11/18/24.
//

import SpriteKit

class Hammer: SKSpriteNode {
    
    var handleEndPoint: SKShapeNode!
    var hammerTopPoint: SKShapeNode!
    var hammerAxisAngle: CGFloat = 0.0
    
    var duplicateHorizontal: Hammer?
    var duplicateVertical: Hammer?
    var duplicateDiagonal: Hammer?
    
    weak var gameScene: SKScene?
    
    init() {
        let texture = SKTexture(imageNamed: "hammer")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.anchorPoint = CGPoint(x: 0, y: 0)
        self.zPosition = 1
        
        // Set initial angle to show as vertical hammer
        self.zRotation = CGFloat.pi / 4
        hammerAxisAngle = CGFloat.pi / 4
        
        self.physicsBody = SKPhysicsBody(texture: texture, size: self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = true
        self.physicsBody?.friction = 0.3
        self.physicsBody?.linearDamping = 1.0
        self.physicsBody?.angularDamping = 1.0
        self.physicsBody?.mass = 0.01
        
        // TEST: Orange handleEndPoint
        handleEndPoint = SKShapeNode(circleOfRadius: 5)
        handleEndPoint.fillColor = .systemOrange
        handleEndPoint.zPosition = 2
        handleEndPoint.position = CGPoint(x: 0, y: 0)
        addChild(handleEndPoint)
        
        // TEST: Purple hammerTopPoint
        hammerTopPoint = SKShapeNode(circleOfRadius: 5)
        hammerTopPoint.fillColor = .purple
        hammerTopPoint.zPosition = 2
        hammerTopPoint.position = CGPoint(x: size.width, y: size.height)
//        addChild(hammerTopPoint)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Rotate in radians
    func rotateToAngle(_ angle: CGFloat) {
        self.zRotation = angle
    }
    
    func handleHorizontalWrapping(screenWidth: CGFloat, edgeThreshold: CGFloat) {
        // Remove existing duplicate if exists
        duplicateHorizontal?.removeFromParent()
        duplicateHorizontal = nil
        
        // Check if hammer is near the right edge
        if position.x > screenWidth - edgeThreshold {
            // Create a duplicate on the left side
            createDuplicateHorizontal(offsetX: -screenWidth)
        }
        // Check if hammer is near the left edge
        else if position.x < edgeThreshold {
            // Create a duplicate on the right side
            createDuplicateHorizontal(offsetX: screenWidth)
        }
        
        // Wrap the hammer around when it moves beyond the screen boundaries
        if position.x > screenWidth {
            position.x -= screenWidth
        } else if position.x < 0 {
            position.x += screenWidth
        }
    }
    
    func createDuplicateHorizontal(offsetX: CGFloat) {
        duplicateHorizontal = Hammer()
        guard let duplicate = duplicateHorizontal else { return }
        
        // Set the duplicate's position and rotation to match the original
        duplicate.position = CGPoint(x: position.x + offsetX, y: position.y)
        duplicate.zRotation = zRotation
        
        duplicate.physicsBody = nil
        duplicate.alpha = alpha
        gameScene?.addChild(duplicate)
    }
    
    // Handle vertical wrapping
    func handleVerticalWrapping(screenHeight: CGFloat, edgeThreshold: CGFloat) {
        // Remove existing duplicate if any
        duplicateVertical?.removeFromParent()
        duplicateVertical = nil
        
        // Check if hammer is near the top edge
        if position.y > screenHeight - edgeThreshold {
            // Create a duplicate at the bottom
            createDuplicateVertical(offsetY: -screenHeight)
        }
        // Check if hammer is near the bottom edge
        else if position.y < edgeThreshold {
            // Create a duplicate at the top
            createDuplicateVertical(offsetY: screenHeight)
        }
        
        // Wrap the hammer around when it moves beyond the screen boundaries
        if position.y > screenHeight {
            position.y -= screenHeight
        } else if position.y < 0 {
            position.y += screenHeight
        }
    }
    
    func createDuplicateVertical(offsetY: CGFloat) {
        duplicateVertical = Hammer()
        guard let duplicate = duplicateVertical else { return }
        
        // Set the duplicate's position and rotation to match the original
        duplicate.position = CGPoint(x: position.x, y: position.y + offsetY)
        duplicate.zRotation = zRotation
        
        // The duplicate should not have a physics body
        duplicate.physicsBody = nil
        
        // Set the same alpha as the original hammer
        duplicate.alpha = alpha
        
        // Add the duplicate to the scene
        gameScene?.addChild(duplicate)
    }
    
    // Handle diagonal wrapping (when near corners)
    func handleDiagonalWrapping(screenWidth: CGFloat, screenHeight: CGFloat, edgeThreshold: CGFloat) {
        // Remove existing duplicate if any
        duplicateDiagonal?.removeFromParent()
        duplicateDiagonal = nil
        
        // Check if hammer is near a corner
        let nearRightEdge = position.x > screenWidth - edgeThreshold
        let nearLeftEdge = position.x < edgeThreshold
        let nearTopEdge = position.y > screenHeight - edgeThreshold
        let nearBottomEdge = position.y < edgeThreshold
        
        if (nearRightEdge && nearTopEdge) {
            createDuplicateDiagonal(offsetX: -screenWidth, offsetY: -screenHeight)
        } else if (nearRightEdge && nearBottomEdge) {
            createDuplicateDiagonal(offsetX: -screenWidth, offsetY: screenHeight)
        } else if (nearLeftEdge && nearTopEdge) {
            createDuplicateDiagonal(offsetX: screenWidth, offsetY: -screenHeight)
        } else if (nearLeftEdge && nearBottomEdge) {
            createDuplicateDiagonal(offsetX: screenWidth, offsetY: screenHeight)
        }
    }
    
    func createDuplicateDiagonal(offsetX: CGFloat, offsetY: CGFloat) {
        duplicateDiagonal = Hammer()
        guard let duplicate = duplicateDiagonal else { return }
        
        // Set the duplicate's position and rotation to match the original
        duplicate.position = CGPoint(x: position.x + offsetX, y: position.y + offsetY)
        duplicate.zRotation = zRotation
        
        // The duplicate should not have a physics body
        duplicate.physicsBody = nil
        
        // Set the same alpha as the original hammer
        duplicate.alpha = alpha
        
        // Add the duplicate to the scene
        gameScene?.addChild(duplicate)
    }
}
