//
//  DogViewModel.swift
//  TheDogApp
//
//  Created by Joseluis SN on 7/02/25.
//

import Foundation
import Combine

class DogViewModel: ObservableObject {
    @Published var dogs: [Dog] = []
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1 

    func fetchDogs() {
        guard let url = URL(string: "https://api.thedogapi.com/v1/breeds?limit=10&page=\(currentPage)") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Dog].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching dogs: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] newDogs in
                self?.dogs.append(contentsOf: newDogs)
                self?.currentPage += 1
            })
            .store(in: &cancellables)
    }
}
