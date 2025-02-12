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
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false 
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 1
    private let service: DogServiceProtocol

    init(service: DogServiceProtocol = DogService()) {
        self.service = service
    }

    func fetchDogs() {
        service.fetchDogs(page: currentPage, limit: 10)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch dogs: \(error.localizedDescription)"
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
