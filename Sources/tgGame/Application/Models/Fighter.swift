//
//  Fighter.swift
//  tgGame
//
//  Created by Алексей on 12/12/2018.
//

import Telegrammer

struct Fighter {
    let name: String
    let username: String
    var health: Int = 100
    var chatId: Int

    init(name: String, username: String, chatId: Int) {
        self.name = name
        self.username = username
        self.chatId = chatId
    }
}

extension Fighter: Codable { }

extension Fighter: Hashable { }
