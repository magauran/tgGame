//
//  ActionType.swift
//  Async
//
//  Created by Алексей on 12/12/2018.
//

enum ActionType: Int {
    case hit = 0
    case dodge = 1
    case join = 2
    case escape = 3
}

extension ActionType: Codable { }
