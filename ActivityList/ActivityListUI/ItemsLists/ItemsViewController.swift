//
//  ItemsViewController.swift
//  ActivityListUITests
//
//  Created by Maksim Linich on 25.04.24.
//

import UIKit
import ActivityListUI

public protocol ItemsServiceProtocol {
    func readItems() async throws -> [ItemData]
}

final public class ItemsViewController<IS: ItemsServiceProtocol>: UIViewController{
    
    @IBOutlet public weak var itemsView: ItemsView!
    public var itemsService: IS?
    
    public convenience init(itemsService: IS) {
        self.init(nibName: "ItemsViewController", bundle: Bundle(for: ItemsViewController.self))
        self.itemsService = itemsService
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
//        itemsView.title = "My To Do List"
//        itemsView.emptyListMessage = "Press 'Add List' to start"
//        itemsView.addListButtonText = "Add List"
        
        if let itemsService = self.itemsService {
            Task { [weak self] in
                do {
                    let items = try await itemsService.readItems()
                    guard let self = self else {
                        return
                    }
                    self.update(items: items)
                } catch {
                    self?.itemsView.isHidden = true
                }
            }
        }
    }
    
    @MainActor
    private func update(items: [ItemData]) {
        if let itemsView = self.itemsView {
            itemsView.items = items
        }
    }
}
