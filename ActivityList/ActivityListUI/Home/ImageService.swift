//
//  IconImageProvider.swift
//  ActivityListUI
//
//  Created by Maksim Linich on 28.03.24.
//

import UIKit
import ActivityListDomain

public class ImageService: ImageServiceProtocol {
    let bundle: Bundle
    public init() {
        bundle = Bundle.init(for: ImageService.self)
    }
    public func getImage(byKind kind: ActivityType) -> UIImage {
        return UIImage.init(named: kind.iconName, in: bundle, with: nil)!
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
        case .undefined:
            return "undefined"
        }
    }
}
