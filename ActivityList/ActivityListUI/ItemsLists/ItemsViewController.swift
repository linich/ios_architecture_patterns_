//
//  ItemsViewController.swift
//  ActivityListUITests
//
//  Created by Maksim Linich on 25.04.24.
//

import UIKit

public protocol ItemsServiceProtocol {
    func readItems() async throws -> [ItemData]
}

final public class ItemsViewController<IS: ItemsServiceProtocol>: UIViewController{

    override public var title: String? {
        didSet { updateButtonAndLabels()}
    }
    
    public var emptyListMessage: String? {
        didSet { updateButtonAndLabels()}
    }
    
    public var addItemButtonText: String? {
        didSet { updateButtonAndLabels()}
    }
    
    private func updateButtonAndLabels() {
        if let itemsView = self.itemsView {
            itemsView.title = self.title
            itemsView.emptyListMessage = self.emptyListMessage
            itemsView.addButtonText = self.addItemButtonText
        }
    }
    
    @IBOutlet public weak var itemsView: ItemsView! {
        didSet { updateButtonAndLabels() }
    }

    public var itemsService: IS?

    public convenience init(itemsService: IS) {
        self.init(nibName: "ItemsViewController", bundle: Bundle(for: ItemsViewController.self))
        self.itemsService = itemsService
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
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
