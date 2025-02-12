//
//  DogDetailViewModel.swift
//  TheDogApp
//
//  Created by Joseluis SN on 7/02/25.
//

import Foundation
import Combine

class DogDetailViewModel: ObservableObject {
    @Published var dogDetail: DogDetail?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let service: DogDetailServiceProtocol

    init(service: DogDetailServiceProtocol = DogDetailService()) {
        self.service = service
    }

    func fetchDogDetail(for dogID: Int) {
        isLoading = true

        service.fetchDogDetail(for: dogID)
            .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = "Error: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] detail in
                self?.dogDetail = detail
            })
            .store(in: &cancellables)
    }
}
