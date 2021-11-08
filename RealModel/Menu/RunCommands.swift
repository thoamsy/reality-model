//
//  RunCommands.swift
//  RealModel
//
//  Created by yk on 2021/11/8.
//

import SwiftUI

struct RunCommands: Commands {
    var body: some Commands {
      CommandMenu("Run") {
        // TODO: refactor folderURL to global valu
        RunButton(folderURL: .constant(nil), progress: .constant(0))
      }
    }
}

