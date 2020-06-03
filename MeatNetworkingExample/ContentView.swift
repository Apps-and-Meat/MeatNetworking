//
//  ContentView.swift
//  MeatNetworkingExample
//
//  Created by Karl Söderberg on 2020-01-20.
//

import SwiftUI

struct ContentView: View {
    @State var breedList: [String] = []
    @State var error: DogApiError? {
        didSet { self.hasError = error != nil }
    }
    @State var hasError = false
    
    var body: some View {
        NavigationView {
            List(breedList, id: \.self) { breed in
                HStack {
                    NavigationLink(breed, destination: DetailView(breedName: breed))
                }
            }
            .navigationBarTitle("Meat networking Example", displayMode: .inline)
            .onAppear(perform: self.viewDidLoad)
            .alert(isPresented: $hasError) {
                 Alert(title: Text("Error"),
                                      message: Text(error?.localizedDescription ?? ""),
                                      dismissButton: Alert.Button.default(Text("OK")))
            }
        }
    }
    
    func viewDidLoad() {
        apiClient.getBreedsList().run { response in
            do {
                let breedsReponseModel = try response()
                self.breedList = breedsReponseModel.breedNames
            } catch let error as DogApiError {
                self.error = error
            } catch {
                print("something is very wrong")
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
