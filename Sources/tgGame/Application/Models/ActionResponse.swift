//
//  ActionResponse.swift
//  tgGame
//
//  Created by Алексей on 13/12/2018.
//

import Foundation

struct ActionResponse {
    let nick: String
    let action: ActionType
    let action_status: Int
    let hits: Int
}

extension ActionResponse: Decodable { }

extension ActionResponse {
    var localizedDescription: String {
        if let fighter = Battlefield.shared.fighters[nick] {
            return "\(fighter.username) \(action.localizedDescription)"
        }
        return "\(nick) \(action.localizedDescription)"
    }
}
