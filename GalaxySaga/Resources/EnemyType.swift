//
//  EnemyType.swift
//  GalaxySaga
//
//  Created by Thush-Fdo on 2022/10/7.
//

import SpriteKit

struct EnemyType : Codable{
    let name: String
    let shields: Int
    let speed: CGFloat
    let powerUpChance: Int
    let scoreFactor: Int
}
