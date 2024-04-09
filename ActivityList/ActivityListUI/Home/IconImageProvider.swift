//
//  IconImageProvider.swift
//  ActivityListUI
//
//  Created by Maksim Linich on 28.03.24.
//

import UIKit
import ActivityListDomain

public class IconImageProvider: ImageProviderProtocol {
    public init() {
        
    }
    public func getImage(byKind kind: ActivityType) -> UIImage {
        return UIImage(named:  kind.iconName)!
    }
}


extension ActivityType {
    var iconName: String {
        switch (self){
        case .airplane:
            return "airplane"
        case .american_football:
            return "american-football"
        case .baseball:
            return "baseball"
        case .fight:
            return "fight"
        case .game:
            return "game"
        case .gym:
            return "gym"
        case .shop:
            return "shop"
        case .skiing:
            return "skiing"
        case .swimming:
            return "swimming"
        case .none:
            return "none"
        }
    }
}
