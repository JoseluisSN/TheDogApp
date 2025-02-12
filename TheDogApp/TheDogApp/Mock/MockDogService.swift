//
//  MockDogService.swift
//  TheDogApp
//
//  Created by Joseluis SN on 10/02/25.
//

import Foundation
import Combine

class MockDogService: DogServiceProtocol {
    var shouldReturnError = false
    var responseDogs: [Dog] = [
        Dog(id: 1, name: "Golden Retriever", bredFor: "Companionship", breedGroup: "Sporting", lifeSpan: "10 - 12 years", temperament: "Friendly", image: DogImage(url: "https://example.com/dog1.jpg")),
        Dog(id: 2, name: "Labrador Retriever", bredFor: "Water retrieving", breedGroup: "Sporting", lifeSpan: "10 - 14 years", temperament: "Loyal", image: DogImage(url: "https://example.com/dog2.jpg"))
    ]

    func fetchDogs(page: Int, limit: Int) -> AnyPublisher<[Dog], Error> {
        if shouldReturnError {
            return Fail(error: URLError(.badServerResponse))
                .delay(for: .milliseconds(500), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        } else {
            return Just(responseDogs)
                .setFailureType(to: Error.self)
                .delay(for: .milliseconds(500), scheduler: RunLoop.main)  
                .eraseToAnyPublisher()
        }
    }
}
