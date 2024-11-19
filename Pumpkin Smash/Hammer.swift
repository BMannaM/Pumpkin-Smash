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
    
    init() {
        let texture = SKTexture(imageNamed: "hammer")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.anchorPoint = CGPoint(x: 0, y: 0)
        self.zPosition = 1
        
        // Make hammer initially vertical
        self.zRotation = CGFloat.pi / 4
        hammerAxisAngle = CGFloat.pi / 4
        
        // Adjust the physics body to match the new anchor point
        let physicsBodySize = self.size
        let physicsBodyCenter = CGPoint(
            x: physicsBodySize.width * (0.5 - self.anchorPoint.x),
            y: physicsBodySize.height * (0.5 - self.anchorPoint.y)
        )
        self.physicsBody = SKPhysicsBody(rectangleOf: physicsBodySize, center: physicsBodyCenter)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        
        // TEST: handleEndPoint
        handleEndPoint = SKShapeNode(circleOfRadius: 5)
        handleEndPoint.fillColor = .yellow
        handleEndPoint.zPosition = 2
        handleEndPoint.position = CGPoint(x: 0, y: 0)
        addChild(handleEndPoint)
        
        // TEST: hammerTopPoint
        hammerTopPoint = SKShapeNode(circleOfRadius: 5)
        hammerTopPoint.fillColor = .purple
        hammerTopPoint.zPosition = 2
        hammerTopPoint.position = CGPoint(x: size.width, y: size.height)
        addChild(hammerTopPoint)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Rotate in radian
    func rotateToAngle(_ angle: CGFloat) {
        self.zRotation = angle
    }
    
    // Align hammer's axis and world's axis
    func calculateHammerAxisVector(in scene: SKScene) -> CGVector {
        // Convert to positions world's axis
        let hammerTopPositionInScene = self.convert(hammerTopPoint.position, to: scene)
        let handleEndPositionInScene = self.convert(handleEndPoint.position, to: scene)
        
        let hammerAxisVector = CGVector(dx: hammerTopPositionInScene.x - handleEndPositionInScene.x,
                                        dy: hammerTopPositionInScene.y - handleEndPositionInScene.y)
        return hammerAxisVector
    }
}
