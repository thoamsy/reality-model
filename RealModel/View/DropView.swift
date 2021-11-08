//
//  DropView.swift
//  RealModel
//
//  Created by yk on 2021/11/3.
//

import SwiftUI
import AppKit
import AVFoundation


struct DropView: View {
  @State private var contentURLs: [URL]?
  @AppStorage("lastFolderURL") var folderURL: URL?
  @State var isShow = false
  
  //  init() {
  //    if folderURL != nil {
  //      contentURLs = ModelDirectoryDelegate.getFilesFromDirectoryURL(dirURL: folderURL!)
  //    }
  //  }
  
  var body: some View {
    VStack {
      if (contentURLs != nil) {
        ThumbnailGrid(contentURLs: $contentURLs)
          .toolbar {
            HStack {
              Button(role: .cancel, action: {
                contentURLs = nil
                folderURL = nil
              }) {
                Image(systemName: "arrow.backward")
              }
              Spacer()
              RunButton(folderURL: folderURL)
            }
          }
      } else {
        HStack {
          Button(action: {
            isShow = true
          }) {
            VStack {
              Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 120))
              Text("Drop to here")
                .font(.largeTitle)
            }
            .frame(width: 256, height: 256)
          }
          .buttonStyle(.borderless)
          .onDrop(of: [.fileURL], delegate: ModelDirectoryDelegate(contentURLs: $contentURLs, folderURL: $folderURL))
          .fileImporter(isPresented: $isShow, allowedContentTypes: [.fileURL, .directory]) { result in
            switch result {
              case .success(let dirURL):
                let result = ModelDirectoryDelegate.getFilesFromDirectoryURL(dirURL: dirURL)
                
                if result.isEmpty {
                  return
                }
                folderURL = dirURL
                contentURLs = result
                
              case .failure:
                return
            }
          }
        }
      }
    }.frame(minWidth: 500)
  }
}

struct ModelDirectoryDelegate: DropDelegate {
  @Binding var contentURLs: [URL]?
  @Binding var folderURL: URL?
  
  static let fileExtension = Set(["mp4", "png", "hevc", "jpeg"])
  
  static func getFilesFromDirectoryURL(dirURL: URL) -> [URL] {
    let contents = try! FileManager.default.contentsOfDirectory(atPath: dirURL.path)
    return contents
      .map { content in dirURL.appendingPathComponent(content) }
      .filter { ModelDirectoryDelegate.fileExtension.contains($0.pathExtension.lowercased()) }
  }
  
  func performDrop(info: DropInfo) -> Bool {
    return info.itemProviders(for: [.fileURL]).first.flatMap { item in
      _ = item.loadObject(ofClass: URL.self) { pathURL, error in
        if error != nil { return }
        guard let url = pathURL else {
          return
        }
        let result = Self.getFilesFromDirectoryURL(dirURL: url)
        if !result.isEmpty {
          contentURLs = result
          folderURL = url
        }
      }
      return true
    } ?? false
  }
  
  func dropUpdated(info: DropInfo) -> DropProposal? {
    //    print(info)
    return nil
  }
  
  func validateDrop(info: DropInfo) -> Bool {
    print(info)
    return info.hasItemsConforming(to: [.fileURL, .directory])
  }
}

struct DropView_Previews: PreviewProvider {
  static var previews: some View {
    DropView()
  }
}
