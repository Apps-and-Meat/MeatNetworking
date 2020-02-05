//
//  TestExampleApi.swift
//  MeatNetworkingExample
//
//  Created by Karl Söderberg on 2020-01-20.
//

import Foundation
import UIKit
import MeatNetworking
import Combine

var apiClient: DogApiClient = {
    let configuration = NetworkingConfiguration(baseURL: "https://dog.ceo/api")
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
    
    func getBreedsList() -> AnyPublisher<BreedsResponse, Error> {
        return self
            .method(.get)
            .path(Path.breedList)
            .toFuture(expecting: BreedsResponse.self)
            .eraseToAnyPublisher()
    }
    
    func getBreedData(breedName: String) -> AnyPublisher<BreedImageResponse, Error> {
        return self
            .method(.get)
            .path(Path.image(breedName))
            .toFuture(expecting: BreedImageResponse.self)
            .eraseToAnyPublisher()
    }
    
    func getBreedImage(breedName: String) -> AnyPublisher<UIImage, Error> {
        self.getBreedData(breedName: breedName)
            .map { URL(string: $0.imageUrl)! }
            .flatMap(self.getImageData(url:))
            .flatMap { imageData in
                return Future<UIImage, Error> { promise in
                guard let image = UIImage(data: imageData) else {
                    promise(.failure(DummyError()))
                    return
                }
                promise(.success(image))
            }
        }.eraseToAnyPublisher()
    }
    
    private func getImageData(url: URL) -> AnyPublisher<Data, Error> {
        return Future<Data, Error> { promise in
                           do {
                               let imageData = try Data(contentsOf: url)
                               promise(.success(imageData))
                           } catch {
                               promise(.failure(error))
                           }
        }.eraseToAnyPublisher()
    }
}

struct DummyError: Error {
    
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
