//
//  SettingView.swift
//  RealModel
//
//  Created by yk on 2021/11/8.
//

import SwiftUI

struct SettingView: View {
  private enum Tabs: Hashable {
    case general
  }
  var body: some View {
    TabView {
      PhotogrammetrySessionSetting()
        .tabItem {
          Label("Task", systemImage: "camera")
        }.tag(Tabs.general)
    }.padding()
  }
}

struct SettingView_Previews: PreviewProvider {
  static var previews: some View {
    SettingView()
  }
}
