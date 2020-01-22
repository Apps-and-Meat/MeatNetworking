//
//  TestExampleApi.swift
//  MeatNetworkingExample
//
//  Created by Karl Söderberg on 2020-01-20.
//

import Foundation
import UIKit
import MeatNetworking

var apiClient: DogApiClient = {
    let configuration = NetworkingConfiguration(baseURL: "https://dog.ceo/api",
                                                      headerFields: [:],
                                                      queryParameters: [],
                                                      defaultUnathorizedAccessHandler: nil,
                                                      defaultUserCredentials: { nil })
    return DogApiClient(configuration: configuration)
}()


class DogApiClient: APIClient {
        
    enum Path: URLPath {
        case breedList
        case image(String)
        
        var requiresAuthentication: Bool { false }
        
        var toString: String {
            switch self {
            case .breedList:
                return "breeds/list"
            case .image(let breed):
                return "breed/\(breed)/images/random"
            }
        }
    }
    
    func getBreedsList() -> Future<BreedsResponse> {
        return Future {
            try self.method(.get).path(Path.breedList).run(expecting: BreedsResponse.self)
        }
    }
    
    func getBreedData(breedName: String) -> Future<BreedImageResponse> {
        return Future {
            try self.method(.get).path(Path.image(breedName)).run(expecting: BreedImageResponse.self)
        }
    }
    
    func getBreedImage(breedName: String) -> Future<UIImage> {
        return Future {
            let imageDataResponse = try self.getBreedData(breedName: breedName).runSynchronous()
            let imageData = try Data(contentsOf: URL(string: imageDataResponse.imageUrl)!)
            guard let image = UIImage(data: imageData) else {
                throw FutureError.noData
            }
            return image
        }
        
    }
}

struct BreedsResponse: Decodable {
    let breedNames: [String]

    enum CodingKeys: String, CodingKey {
        case breedNames = "message"
    }
}

struct BreedImageResponse: Decodable {
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case imageUrl = "message"
    }
}

struct Breed: Hashable {
    let name: String
    var image: UIImage?
}
