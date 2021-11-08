//
//  RealModelApp.swift
//  RealModel
//
//  Created by yk on 2021/11/3.
//

import SwiftUI

@main
struct RealModelApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .frame(minWidth: 500, minHeight: 300)
    }
    Settings {
      SettingView()
        .frame(minWidth: 500, minHeight: 300)
    }
  }
}
