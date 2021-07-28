//
//  Scene.swift
//  Project2a
//
//  Created by Ryan Neil Stroud on 28/7/2021.
//

import SpriteKit
import ARKit

class Scene: SKScene {
    
    private let startTime = Date()
    private let remainingLabel = SKLabelNode()
    private var timer: Timer?
    private var targetsCreated = 0
    private var targetCount = 0 {
        didSet {
            remainingLabel.text = "Remaining: \(targetCount)"
        }
    }
    
    private func createTarget() {
        if targetsCreated == 20 {
            timer?.invalidate()
            timer = nil
            return
        }
        targetsCreated += 1
        targetCount += 1
        
        // find the scene view we are drawing into
        guard let sceneView = self.view as? ARSKView else { return }

        // create a random X rotation
        let xRotation = simd_float4x4(SCNMatrix4MakeRotation(Float.pi * 2 * Float.random(in: 0...1), 1, 0, 0))

        // create a random Y rotation
        let yRotation = simd_float4x4(SCNMatrix4MakeRotation(Float.pi * 2 * Float.random(in: 0...1), 0, 1, 0))

        // combine them together
        let rotation = simd_mul(xRotation, yRotation)

        // move forward 1.5 meters into the screen
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.5

        // combine that with our rotation
        let transform = simd_mul(rotation, translation)

        // create an anchor at the finished position
        let anchor = ARAnchor(transform: transform)
        sceneView.session.add(anchor: anchor)
    }
    
    private func gameOver() {
        remainingLabel.removeFromParent()

        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        addChild(gameOver)

        let timeTaken = Date().timeIntervalSince(startTime)
        let timeLabel = SKLabelNode(text: "Time taken: \(Int(timeTaken)) seconds")
        timeLabel.fontSize = 36
        timeLabel.fontName = "AmericanTypewriter"
        timeLabel.color = .white
        timeLabel.position = CGPoint(x: 0, y: -view!.frame.midY + 50)
        addChild(timeLabel)
    }
    
    override func didMove(to view: SKView) {
        remainingLabel.fontSize = 36
        remainingLabel.fontName = "AmericanTypewriter"
        remainingLabel.position = CGPoint(x: 0, y: 100)
        addChild(remainingLabel)
        targetCount = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            self.createTarget()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let hit = nodes(at: location)
        
        if let sprite = hit.first {
            let scaleOut = SKAction.scale(by: 2, duration: 0.2)
            let fadeOut  = SKAction.fadeOut(withDuration: 0.2)
            let group    = SKAction.group([scaleOut, fadeOut])
            let sequence = SKAction.sequence([group, SKAction.removeFromParent()])
            sprite.run(sequence)
            
            targetCount -= 1
            
            if targetsCreated >= 20 && targetCount == 0 {
                gameOver()
            }
        }
    }
}
