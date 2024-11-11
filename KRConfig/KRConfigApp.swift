//
//  KRConfigApp.swift
//  KRConfig
//
//  Created by vince on 11/11/2024.
//

import SwiftUI

@main
struct KRConfigApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .errorHandling()
                .alertHandling()
        }
    }
}
