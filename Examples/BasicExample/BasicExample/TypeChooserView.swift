//
//  TypeChooserView.swift
//  BasicExample
//
//  Created by Alexander van der Werff on 18/02/2022.
//

import SwiftUI
import BasedClient

struct TypeChooserView: View {
    
    var body: some View {
        
        NavigationView {
            List {
                NavigationLink(destination: MovieListView()) {
                    Text("Movies")
                }
                
                NavigationLink(destination: ActorListView()) {
                    Text("Actors")
                }
            }
            .navigationBarTitle(Text("Choose type"))
        }
    
    }
    
}
