//
//  Fighter.swift
//  tgGame
//
//  Created by Алексей on 12/12/2018.
//

struct Fighter {
    let name: String
    let username: String
}

extension Fighter: Codable { }

extension Fighter: Hashable { }
