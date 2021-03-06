//
//  RealModelApp.swift
//  RealModel
//
//  Created by yk on 2021/11/3.
//

import SwiftUI

@main
struct RealModelApp: App {
  @StateObject var store = Store()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(store)
        .frame(minWidth: 600, minHeight: 350)
    }.commands {
      RunCommands(store: store)
    }

    Settings {
      SettingView()
        .frame(minWidth: 600, minHeight: 350)
    }
  }
}
