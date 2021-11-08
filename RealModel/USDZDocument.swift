//
//  USDZDocument.swift
//  RealModel
//
//  Created by yk on 2021/11/8.
//

import SwiftUI
import UniformTypeIdentifiers

struct USDZURLDocument: FileDocument {
  static var readableContentTypes: [UTType] { [.usdz] }

  var documentName: String

  init(name: String) {
    documentName = name
  }

  init(configuration: ReadConfiguration) throws {
    documentName = ""
  }

  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    return try FileWrapper(url: URL(fileURLWithPath: "\(documentName).usdz"), options: .immediate)
  }
}
