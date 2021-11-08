//
//  ExportTest.swift
//  RealModel
//
//  Created by yk on 2021/11/8.
//

import SwiftUI
import UniformTypeIdentifiers

struct ExportTest: View {
  @State var export = false
  var body: some View {
    Button(action: {
      export = true
    }) {
      Text("Click me")
    }.fileExporter(isPresented: $export, document: USDZURLDocument(name: "test"), contentType: .usdz) { result in
      if case .success(let file) = result {
        print(file)
      } else {
        print(result)
      }
    }
  }
}


struct ExportTest_Previews: PreviewProvider {
  static var previews: some View {
    ExportTest()
  }
}
