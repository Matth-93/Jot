//
//  JotAppApp.swift
//  JotApp
//
//  Created by Kat Canavan on 8/21/23.
//

import SwiftUI

@main
struct JotAppApp: App {
    var body: some Scene {
        MenuBarExtra("Jot", systemImage: "square.and.pencil") {
            ContentView()
        }
        .menuBarExtraStyle(.window)

        Window("Jot", id: "jot-pinned") {
            PinnedWindowContent()
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 320, height: 380)
    }
}
