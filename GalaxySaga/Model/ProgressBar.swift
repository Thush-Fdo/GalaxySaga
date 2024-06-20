//
//  ProgressBar.swift
//  GalaxySaga
//
//  Created by 101 on 2022/10/14.
//

import SpriteKit

class ProgressBar : SKNode{
    //private var progress = CGFloat(0)
    //private var maxprogress = CGFloat(9)
    private var maxProgressBarWidth = CGFloat(0)
    
    private var progressBar = SKSpriteNode()
    private var progressBarContainer = SKSpriteNode()
    
    private var progressContainerTexture = SKTexture(imageNamed: "progressbarbg")
    
    private var sceneFrame = CGRect()
    
    override init() {
        super.init()
    }
    
    func getSceneFrame(sceneFrame: CGRect){
        self.sceneFrame = sceneFrame
        maxProgressBarWidth = sceneFrame.width * 0.18
    }
    
    func buildProgressBar(texture: SKTexture) {
        progressBarContainer = SKSpriteNode(texture: progressContainerTexture, size: progressContainerTexture.size())
        progressBarContainer.size.width = sceneFrame.width * 0.18
        progressBarContainer.size.height = sceneFrame.height * 0.04
        progressBarContainer.drawBorder(color: .white, width: 1)
        
        progressBar = SKSpriteNode(texture: texture, size: texture.size())
        progressBar.size.width = sceneFrame.width * 0.18
        progressBar.size.height = sceneFrame.height * 0.03
        progressBar.position.x = -maxProgressBarWidth / 2
        progressBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        
        addChild(progressBar)
        addChild(progressBarContainer)
    }
    
    func updateProgressBar(progress: CGFloat) {
        if progress > 100  { return }
        
        progressBar.run(SKAction.resize(toWidth: CGFloat(maxProgressBarWidth / 100) * progress, duration: 0.2))
        
    }
    
    func updateNextHealthProgressBar(progress: CGFloat) {
        if progress < 0  { return }
        
        progressBar.run(SKAction.resize(toWidth: CGFloat(maxProgressBarWidth / 100) * progress, duration: 0.2))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SKNode {
    func drawBorder(color: UIColor, width: CGFloat) {
        let shapeNode = SKShapeNode(rect: frame)
        shapeNode.fillColor = .clear
        shapeNode.strokeColor = color
        shapeNode.lineWidth = width
        addChild(shapeNode)
    }
}
