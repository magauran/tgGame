//
//  Action.swift
//  Async
//
//  Created by Алексей on 12/12/2018.
//

struct Action {
    let fighter: Fighter
    let actionType: ActionType
    let target: Fighter?
}

extension Action: Codable { }
