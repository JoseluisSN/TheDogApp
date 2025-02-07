//
//  DogModel.swift
//  TheDogApp
//
//  Created by Joseluis SN on 7/02/25.
//

import Foundation

struct Dog: Codable, Identifiable {
    let id: Int
    let name: String
    let bredFor: String?
    let breedGroup: String?
    let lifeSpan: String
    let temperament: String?
    let image: DogImage?

    enum CodingKeys: String, CodingKey {
        case id, name
        case bredFor = "bred_for"
        case breedGroup = "breed_group"
        case lifeSpan = "life_span"
        case temperament, image
    }
}

struct DogImage: Codable {
    let url: String
}
