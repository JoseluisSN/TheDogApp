//
//  DogService.swift
//  TheDogApp
//
//  Created by Joseluis SN on 10/02/25.
//

import Foundation
import Combine

class DogService: DogServiceProtocol {
    func fetchDogs(page: Int, limit: Int) -> AnyPublisher<[Dog], Error> {
        guard let url = URL(string: "https://api.thedogapi.com/v1/breeds?limit=\(limit)&page=\(page)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Dog].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
