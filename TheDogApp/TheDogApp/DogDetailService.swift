//
//  DogDetailService.swift
//  TheDogApp
//
//  Created by Joseluis SN on 10/02/25.
//
import Foundation
import SwiftUI
import Combine

class DogDetailService: DogDetailServiceProtocol {
    func fetchDogDetail(for dogID: Int) -> AnyPublisher<DogDetail, Error> {
        guard let url = URL(string: "https://api.thedogapi.com/v1/breeds/\(dogID)") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: DogDetail.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
