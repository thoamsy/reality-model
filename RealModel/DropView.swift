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

  func generateThumbnails(path: URL) -> Image? {
    do {
      let asset = AVURLAsset(url: path, options: nil)
      let imgGenerator = AVAssetImageGenerator(asset: asset)
      imgGenerator.appliesPreferredTrackTransform = true

      let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
      let thumbnail = NSImage(cgImage: cgImage, size: NSSize(width: 128, height: 128))

      return Image(nsImage: thumbnail)
    } catch {
      print("*** Error generating thumbnail: \(error.localizedDescription)")
      return nil
    }
  }

  @ViewBuilder
  var body: some View {
    if (contentURLs != nil) {
      List(contentURLs!, id: \.self) {
        if let image = generateThumbnails(path: $0) {
          image.frame(width: 128, height: 128)
        }
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

  func performDrop(info: DropInfo) -> Bool {
    return info.itemProviders(for: [.fileURL]).first.flatMap { item in
      _ = item.loadObject(ofClass: URL.self) { pathURL, error in
        if error != nil { return }
        guard let url = pathURL else {
          return
        }
        do {
          let contents = try FileManager.default.contentsOfDirectory(atPath: url.path)
          let urls = contents.map{ content in url.appendingPathComponent(content) }.filter { $0.pathExtension == "mp4" }
          print(urls)
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
