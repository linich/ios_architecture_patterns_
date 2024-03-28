//
//  IconImageProvider.swift
//  ActivityListUI
//
//  Created by Maksim Linich on 28.03.24.
//

import UIKit

public class IconImageProvider: IconImageProviderProtocol {
    public func image(byName name: String) -> UIImage? {
        return UIImage(named: name)
    }
}
