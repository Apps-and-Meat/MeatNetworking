//
//  DetailView.swift
//  MeatNetworkingExample
//
//  Created by Karl Söderberg on 2020-01-20.
//

import SwiftUI
import UIKit
import Combine

class DetailViewModel: ObservableObject {
    var cancellable = Set<AnyCancellable>()
    
    @Published var breedName: String
    
    @Published var image: UIImage?
    @Published var error: Error?
    @Published var hasError: Bool = false
    
    init(breedName: String) {
        self.breedName = breedName
        
        $error
            .receive(on: RunLoop.main)
            .map { $0 != nil }
            .assign(to: \.hasError, on: self)
            .store(in: &cancellable)
    }
    
    func getImage() {
        apiClient.getBreedImage(breedName: breedName)
            .receive(on: RunLoop.main)
            .sinkResult {
                do {
                    self.image = try $0.get()
                } catch {
                    self.error = error
                }
            }
            .store(in: &cancellable)
    }
}

struct DetailView: View {
    @ObservedObject var viewModel: DetailViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.breedName.capitalized)
                .font(.largeTitle)
                .padding()
            
            if viewModel.image != nil {
                Image(uiImage: viewModel.image!)
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 200, height: 200, alignment: .center)
                    .shadow(radius: 10)
                    .padding()
                
            } else {
                HStack {
                    Text("Loading")
                    ActivityIndicator(isAnimating: true)
                }
            }
        }.onAppear(perform: viewModel.getImage)
        .alert(isPresented: $viewModel.hasError) {
            Alert(title: Text("Something went wrong"), message: Text(viewModel.error!.localizedDescription), dismissButton: .default(Text("Dam it!")))
        }
    }
    
    init(breedName: String) {
        self.viewModel = DetailViewModel(breedName: breedName)
    }
    
    
}

struct ActivityIndicator: UIViewRepresentable {
    
    typealias UIView = UIActivityIndicatorView
    var isAnimating: Bool
    fileprivate var configuration = { (indicator: UIView) in }
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView { UIView() }
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
        configuration(uiView)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(breedName: "Test")
    }
}
