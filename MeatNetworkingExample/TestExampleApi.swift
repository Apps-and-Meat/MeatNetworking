//
//  TestExampleApi.swift
//  MeatNetworkingExample
//
//  Created by Karl Söderberg on 2020-01-20.
//

import Foundation
import UIKit
import MeatNetworking
import MeatFutures

class DogApiError: Error, Decodable {
    let status: String
    let message: String
    let code: Int
    
    init(code: Int) {
        self.code = code
        self.message = "Could not parse from Api"
        self.status = "Something vierd"
    }
    
    var localizedDescription: String {
        "\(status), - \(message) code: \(code)"
    }    
}

var apiClient: DogApiClient = {
    var configuration = NetworkingConfiguration(baseURL: "https://dog.ceo/api")
    configuration.errorMapping = { networkingError in
        guard let data = networkingError.data else {
            return DogApiError(code: networkingError.statusCode?.rawValue ?? 404)
        }
        do {
            return try configuration.decoder.decode(DogApiError.self, from: data)
        } catch {
            return error
        }
    }
    
    return DogApiClient(configuration: configuration)
}()

extension DogApiClient: MeatNetworking.UnathorizedAccessHandler {
    
    static var maxRetryCount = 2
    
    func recover(retryCount: Int) -> Future<Bool> {
        print("Recover try \(retryCount)")
        guard retryCount < Self.maxRetryCount else {
            return Future(result: { false } )
        }
        
        print("Successful recover")
        return Future { true }
    }
    
    func afterFailedRecover() {
        print("Failed recovery")
    }
}


class DogApiClient: APIClient {
    
    override init(configuration: NetworkingConfiguration) {
        super.init(configuration: configuration)
        self.configuration.defaultUnathorizedAccessHandler = self
    }
        
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
