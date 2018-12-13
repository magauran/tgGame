//
//  ActionStatus.swift
//  Async
//
//  Created by Алексей on 13/12/2018.
//

import Foundation

enum ActionStatus: Int {
    case success = 0
    case confused = 1
    case missed = 2
    case slip = 3
    case tired = 10
    case dodged = 11
    case watched = 20
    case died = 30
}

extension ActionStatus: Codable { }

extension ActionStatus {
    var localizedDescription: String {
        switch self {
        case .success:
            return " успешно"
        case .confused:
            return ", но не того"
        case .missed:
            return ", но не попал"
        case .slip:
            return " и промахнулся, так как цель увернулась"
        case .tired:
            return " и устал"
        case .dodged:
            return ", хотя его не били"
        case .watched:
            return " и наблюдает"
        case .died:
            return ", который умер"
        }
    }
}
