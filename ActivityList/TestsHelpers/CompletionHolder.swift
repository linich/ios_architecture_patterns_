//
//  CompletionHolder.swift
//  ActivityList
//
//  Created by Maksim Linich on 2.04.24.
//

import Foundation

internal class CompletionHolder<T> {
    var completion: ((T) -> Void)?
    
    public init(completion: ((T) -> Void)?) {
        self.completion = completion
    }
}
