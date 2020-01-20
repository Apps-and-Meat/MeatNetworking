//
//  DetailView.swift
//  MeatNetworkingExample
//
//  Created by Karl Söderberg on 2020-01-20.
//

import SwiftUI
import UIKit

struct DetailView: View {
    var breedName: String
    
    @State var image: UIImage?
    @State var hasError: Bool = false
    
    var body: some View {
        VStack {
            Text(breedName)
                .font(.largeTitle)
                .padding()
            
            if image != nil {
                Image(uiImage: image!)
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 200, height: 200, alignment: .center)
                    .padding()
                
            } else {
                HStack {
                    Text("Loading")
                    ActivityIndicator(isAnimating: true)
                }
            }
        }
        .onAppear(perform: self.viewDidLoad)
        .alert(isPresented: $hasError) {
            Alert(title: Text("Something went wrong"), message: nil, dismissButton: .default(Text("Dam it!")))
        }
    }
    
    func viewDidLoad() {
        apiClient.getBreedImage(breedName: breedName).run { response in
            do {
                self.image = try response()
            } catch {
                self.hasError = true
            }
        }
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
