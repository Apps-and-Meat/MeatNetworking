//
//  ContentView.swift
//  MeatNetworkingExample
//
//  Created by Karl Söderberg on 2020-01-20.
//

import SwiftUI

struct ContentView: View {
    @State var breedList: [Breed] = []
    var body: some View {
        NavigationView {
            List(breedList, id: \.self) { breed in
                HStack {
                    Text(breed.name)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
