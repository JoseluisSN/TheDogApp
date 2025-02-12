//
//  DogDetailServiceProtocol.swift
//  TheDogApp
//
//  Created by Joseluis SN on 10/02/25.
//

import Combine

protocol DogDetailServiceProtocol {
    func fetchDogDetail(for dogID: Int) -> AnyPublisher<DogDetail, Error>
}
