//
//  ItemData.swift
//  ActivityListUI
//
//  Created by Maksim Linich on 25.04.24.
//

import UIKit

public struct ItemData {
    public init(title: String, subtitle: String, icon: UIImage) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }
    
    public let title: String
    public let subtitle: String
    public let icon: UIImage
}
