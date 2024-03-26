//
//  TaskRepositoryProtocol.swift
//  ActivityListDomain
//
//  Created by Maksim Linich on 25.03.24.
//

public protocol TaskListRepositoryProtocol {
    
    func readTasks(completion: @escaping (Result<[TaskListModel], Error>) -> Void)
    
}
