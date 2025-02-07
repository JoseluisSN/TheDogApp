//
//  DogDetailModel.swift
//  TheDogApp
//
//  Created by Joseluis SN on 7/02/25.
//

 import Foundation

struct DogDetail: Codable {
    let id: Int
    let name: String
    let bredFor: String?
    let breedGroup: String?
    let lifeSpan: String
    let temperament: String?
    let origin: String?
    let weight: MeasurementUnit
    let height: MeasurementUnit
    let referenceImageId: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case bredFor = "bred_for"
        case breedGroup = "breed_group"
        case lifeSpan = "life_span"
        case temperament, origin, weight, height
        case referenceImageId = "reference_image_id"
    }
}

struct MeasurementUnit: Codable {
    let imperial: String
    let metric: String
}
