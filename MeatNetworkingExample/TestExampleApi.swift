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
    APIClient.configuration = NetworkingConfiguration(baseURL: "https://dog.ceo/api",
                                                      headerFields: [:],
                                                      queryParameters: [],
                                                      defaultUnathorizedAccessHandler: nil,
                                                      defaultUserCredentials: { nil })
    return DogApiClient()
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
    
    //func getBreedData(for breed: Breed, onCompletion: @escaping (Result<Bool, Error>) -> Void) {
    //    getBreedImageUrl(named: breed.name) { result in
    //        switch result {
    //        case let .success(url):
    //            getBreedImage(url: url) { imageResult in
    //                switch imageResult {
    //                case let .success(imageData):
    //                    breed.saveImageData(data: imageData)
    //                    onCompletion(.success(true))
    //                case let .failure(error):
    //                    onCompletion(.failure(error))
    //                }
    //            }
    //        case let .failure(error):
    //            onCompletion(.failure(error))
    //        }
    //    }
    //}
    
    
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
