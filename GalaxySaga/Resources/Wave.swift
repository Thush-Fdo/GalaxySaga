//
//  Wave.swift
//  GalaxySaga
//
//  Created by Thush-Fdo on 2022/10/10.
//

import SpriteKit

struct Wave: Codable{
    struct WaveEnemy: Codable {
        let position: Int
        let xOffset: CGFloat
        let moveStraight: Bool
    }
    
    let name: String
    let enemies: [WaveEnemy]
}
