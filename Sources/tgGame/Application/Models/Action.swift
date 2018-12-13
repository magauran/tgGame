//
//  Action.swift
//  tgGame
//
//  Created by Алексей on 12/12/2018.
//

import Foundation

struct Action {
    let fighter: Fighter
    let actionType: ActionType
    let target: Fighter?
}

extension Action: Encodable {
    enum CodingKeys: String, CodingKey {
        case fighter = "nick"
        case actionType = "action"
        case target = "target"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fighter.name, forKey: .fighter)
        try container.encode(actionType.rawValue, forKey: .actionType)
        try container.encodeIfPresent(target?.name, forKey: .target)
    }
}

extension Action: Decodable { }

extension Action {
    var json: String? {
        do {
            let jsonData = try JSONEncoder().encode(self)
            return String(bytes: jsonData, encoding: String.Encoding.utf8)
        } catch {
            return nil
        }
    }
}
