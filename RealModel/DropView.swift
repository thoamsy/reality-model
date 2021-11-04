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

  @ViewBuilder
  var body: some View {
    NavigationView {
      if (contentURLs != nil) {
        ThumbnailGrid(contentURLs: $contentURLs)
      } else {
        HStack {
          VStack {
            Image(systemName: "photo.on.rectangle.angled")
              .font(.system(size: 120))
            Text("Drop to here")
              .font(.largeTitle)
          }
          .frame(width: 256, height: 256)
          .padding()
          .onDrop(of: [.fileURL], delegate: ModelDirectoryDelegate(contentURLs: $contentURLs))
        }.frame(width: 600)
      }
    }
  }
}

struct ModelDirectoryDelegate: DropDelegate {
  @Binding var contentURLs: [URL]?
  let fileExtension = Set(["mp4", "png", "hevc", "jpeg"])

  func performDrop(info: DropInfo) -> Bool {
    return info.itemProviders(for: [.fileURL]).first.flatMap { item in
      _ = item.loadObject(ofClass: URL.self) { pathURL, error in
        if error != nil { return }
        guard let url = pathURL else {
          return
        }
        do {
          let contents = try FileManager.default.contentsOfDirectory(atPath: url.path)
          let urls = contents
            .map { content in url.appendingPathComponent(content) }
            .filter { fileExtension.contains($0.pathExtension.lowercased()) }

          if urls.isEmpty {
            return
          }
          contentURLs = urls
          print(urls)
        } catch {
          print(error)
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
