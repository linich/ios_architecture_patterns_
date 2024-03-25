//
//  TaskRepositoryProtocol.swift
//  ActivityListDomain
//
//  Created by Maksim Linich on 25.03.24.
//

public protocol TaskRepositoryProtocol {
    
    func readTasks(completion: @escaping (Result<[TaskListModel], Error>) -> Void)
    
}
