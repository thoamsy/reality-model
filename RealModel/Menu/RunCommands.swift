  //
  //  RunCommands.swift
  //  RealModel
  //
  //  Created by yk on 2021/11/8.
  //

import SwiftUI

struct RunCommands: Commands {
  var store: Store

  var body: some Commands {
    CommandMenu("Run") {
      RunButton()
        .environmentObject(store)
    }
  }
}

