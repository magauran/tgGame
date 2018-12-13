//
//  ActionType.swift
//  tgGame
//
//  Created by Алексей on 12/12/2018.
//

enum ActionType: Int {
    case hit = 0
    case dodge = 1
    case join = 2
    case escape = 3
    case warmUp = 4
}

extension ActionType: Codable { }

extension ActionType {
    var localizedDescription: String {
        switch self {
        case .hit:
            return "ударил"
        case .dodge:
            return "уклонился"
        case .join:
            return "присоединился"
        case .escape:
            return "сбежал"
        case .warmUp:
            return "разминается"
        }
    }
}
