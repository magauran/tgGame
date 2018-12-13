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
    let action_status: ActionStatus
    let hits: Int?
    let target: String?
}

extension ActionResponse: Decodable { }

extension ActionResponse {
    var localizedDescription: String {
        if let fighter = Battlefield.shared.fighters[nick] {
            var targetStr = ""
            if let targetId = target {
                if let targetFighter = Battlefield.shared.fighters[targetId] {
                    targetStr = " \(targetFighter.username)"
                } else {
                    targetStr = " \(targetId)"
                }
            }
            return "\(fighter.username) \(action.localizedDescription)\(targetStr)\(action_status.localizedDescription)"
        }
        return "\(nick) \(action.localizedDescription)"
    }
}
