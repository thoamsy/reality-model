//
//  Store.swift
//  RealModel
//
//  Created by yk on 2021/11/9.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class Store: ObservableObject {
  @Published var errorMessage = ""
  @Published var folderURL: URL?
  @Published var contentURLs: [URL]?
  @Published var isProgressing = false
}
