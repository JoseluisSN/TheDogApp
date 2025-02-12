//
//  DogServiceProtocol.swift
//  TheDogApp
//
//  Created by Joseluis SN on 10/02/25.
//

import Foundation
import Combine

protocol DogServiceProtocol {
    func fetchDogs(page: Int, limit: Int) -> AnyPublisher<[Dog], Error>
}
