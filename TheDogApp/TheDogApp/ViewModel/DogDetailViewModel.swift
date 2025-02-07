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

    func fetchDogDetail(for dogID: Int) {
        guard let url = URL(string: "https://api.thedogapi.com/v1/breeds/\(dogID)") else {
            self.errorMessage = "Invalid URL"
            return
        }

        isLoading = true 

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: DogDetail.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
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
