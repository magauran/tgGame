//
//  Fighter.swift
//  tgGame
//
//  Created by Алексей on 12/12/2018.
//

struct Fighter {
    let name: String
    let username: String
    var health: Int = 100

    init(name: String, username: String) {
        self.name = name
        self.username = username
    }
}

extension Fighter: Codable { }

extension Fighter: Hashable { }
