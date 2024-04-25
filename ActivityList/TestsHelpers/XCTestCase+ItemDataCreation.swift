//
//  XCTestCase+ItemDataCreation.swift
//  ActivityListUI
//
//  Created by Maksim Linich on 25.04.24.
//

import XCTest
import ActivityListDomain
import ActivityListUI

extension XCTestCase {
    func makeItemData(title: String = "title_\(#line)", subtitle: String = "subtitile_\(#line)", icon: UIImage = UIImage()) -> ItemData {
        return ItemData(title: title, subtitle: subtitle, icon: icon)
    }
}
