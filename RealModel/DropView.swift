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
  let thumbnailSize: Double = 128

  // optimaze for just run once
  func generateThumbnails(path: URL) -> Image? {
    if (path.pathExtension == "mp4") {

      do {
        let asset = AVURLAsset(url: path, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true

        let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
        let thumbnail = NSImage(cgImage: cgImage, size: NSSize(width: thumbnailSize, height: thumbnailSize))

        return Image(nsImage: thumbnail)
      } catch {
        print("*** Error generating thumbnail: \(error.localizedDescription)")
        return nil
      }
    } else {
      if let img = NSImage(contentsOf: path) {
        return Image(nsImage: img)
      }
      return nil
    }
  }

  @ViewBuilder
  var body: some View {
    if (contentURLs != nil) {
      ScrollView {
        LazyVGrid(columns: Array(repeating: .init(.fixed(thumbnailSize)), count: 4)) {
          ForEach(contentURLs!, id: \.self) { url in
            if let image = generateThumbnails(path: url) {
              image
                .resizable()
                .scaledToFit()
                .frame(width: thumbnailSize, height: thumbnailSize)
                .padding()
            }
          }
        }.padding()
      }
    } else {
      VStack {
        VStack {
          Text("Drop here")
            .font(.largeTitle)
          Image(systemName: "photo.on.rectangle.angled")
            .font(.system(size: 80))
        }
        .padding()
        .background(Rectangle().fill(Color.gray).cornerRadius(4))
      }
      .frame(width: 500, height: 320)
      .onDrop(of: [.fileURL], delegate: ModelDirectoryDelegate(contentURLs: $contentURLs))
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
          contentURLs = urls
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
