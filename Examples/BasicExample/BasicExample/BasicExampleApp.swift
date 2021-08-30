//
//  BasicExampleApp.swift
//  BasicExample
//
//  Created by Alexander van der Werff on 29/08/2021.
//

import SwiftUI
import BasedClient

@main
struct BasicExampleApp: App {
    
    let client = Based(config: BasedConfig(url: "wss://localhost:9100"))
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
