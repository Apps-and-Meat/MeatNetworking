//
//  ContentView.swift
//  MeatNetworkingExample
//
//  Created by Karl Söderberg on 2020-01-20.
//

import SwiftUI
import Combine

extension Publisher {
    public func sinkSuccess(_ receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        self.sink(receiveCompletion: {_ in }, receiveValue: receiveValue)
    }
    public func sinkResult(_ receiveResult: @escaping ((Result<Self.Output, Self.Failure>) -> Void)) -> AnyCancellable {
        self.sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                receiveResult(.failure(error))
            default:
                break
            }
        }) { output in
            receiveResult(.success(output))
        }
    }
}


class ContentViewModel: ObservableObject {
    private var cancellable = Set<AnyCancellable>()
    
    @Published var breedList: [String] = []
    @Published var error: Error?
    @Published var hasError = false
    
    func updateBreddList() {
        apiClient.getBreedsList()
            .receive(on: RunLoop.main)
            .map { $0.breedNames }
            .sinkResult { result in
                do {
                    self.breedList = try result.get()
                } catch {
                    self.error = error
                }
            }.store(in: &cancellable)
    }
    
    init() {
        $error
            .receive(on: DispatchQueue.main)
            .map { $0 != nil }
            .assign(to: \.hasError, on: self)
            .store(in: &cancellable)
        
        updateBreddList()
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.breedList, id: \.self) { breed in
                HStack {
                    NavigationLink(breed, destination: DetailView(breedName: breed))
                }
            }
            .navigationBarTitle("Meat networking Example", displayMode: .inline)
            .alert(isPresented: $viewModel.hasError) {
                Alert(title: Text("Error"),
                      message: Text(viewModel.error?.localizedDescription ?? ""),
                      dismissButton: Alert.Button.default(Text("OK")))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
