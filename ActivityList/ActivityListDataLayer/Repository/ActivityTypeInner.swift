//
//  ActivityTypeInner.swift
//  ActivityListDataLayer
//
//  Created by Maksim Linich on 1.04.24.
//
import ActivityListDomain

internal enum ActivityTypeInner: Int16 {
    case none
    case game
    case gym
    case fight
    case airplane
    case shop
    case baseball
    case american_football
    case skiing
    case swimming
    
    static func from(activityType: ActivityType) -> ActivityTypeInner {
        switch activityType {
        case .undefined:
            return .none
        case .game:
            return .game
        case .gym:
            return .gym
        case .fight:
            return .fight
        case .airplane:
            return .airplane
        case .shop:
            return .shop
        case .baseball:
            return .baseball
        case .american_football:
            return .american_football
        case .skiing:
            return .skiing
        case .swimming:
            return .swimming
        }
    }
    
    func toDomainType() -> ActivityType {
        switch self {
        case .none:
            return .undefined
        case .game:
            return .game
        case .gym:
            return .gym
        case .fight:
            return .fight
        case .airplane:
            return .airplane
        case .shop:
            return .shop
        case .baseball:
            return .baseball
        case .american_football:
            return .american_football
        case .skiing:
            return .skiing
        case .swimming:
            return .swimming
        }
    }
}

