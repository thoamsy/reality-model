//
//  ContentView.swift
//  RealModel
//
//  Created by yk on 2021/11/3.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
      NavigationView {
        DropView()
          .navigationTitle("lalla")
      }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
