//
//  ThumbnailView.swift
//  RealModel
//
//  Created by yk on 2021/11/4.
//

import SwiftUI
import AVFoundation

struct ThumbnailView: View {
  var fileURL: URL
  var thumbnailSize: Double = 128
  var thumbnail: Image?

  func generateThumbnails(url: URL) -> Image? {
    if (url.pathExtension == "mp4") {
      do {
        let asset = AVURLAsset(url: url, options: nil)
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
      print(url.path)
      if let img = NSImage(byReferencingFile: url.path), img.isValid {
        return Image(nsImage: img)
      }
      return nil
    }
  }

  init(fileURL: URL, thumbnailSize: Double = 128.0) {
    self.fileURL = fileURL
    thumbnail = generateThumbnails(url: fileURL)
    self.thumbnailSize = thumbnailSize
  }

  var body: some View {
    VStack {
      if let image = thumbnail {
        image
          .resizable()
          .scaledToFit()
          .cornerRadius(6)
      } else {
        Image(systemName: "questionmark.folder.fill")
          .resizable()
          .scaledToFit()
      }
      Text(fileURL.lastPathComponent)
        .font(.caption2)
    }
    .frame(width: thumbnailSize, height: thumbnailSize)
    .padding()
  }
}

struct ThumbnailView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ThumbnailView(fileURL: URL(string: "file:///Users/yk/Downloads/aaaa/%E8%99%8E%E7%89%99%20%E7%8C%AB%E5%B4%BD%E5%B4%BD%E4%B8%89%E5%88%86%E7%B3%96%20%E7%83%AD%E8%88%9E%E5%9B%9E%E6%94%BE%2020210729.mp4")!, thumbnailSize: 128)

      ThumbnailView(fileURL: URL(string: "file:///Users/yk/Downloads/aaaa/%E8%99%8E%E7%89%99%20%E7%8C%AB%E5%B4%BD%E5%B4%BD%E4%B8%89%E5%88%86%E7%B3%96%20%E7%83%AD%E8%88%9E%E5%9B%9E%E6%94%BE%2020210729.mp4")!, thumbnailSize: 256)
    }
  }
}
