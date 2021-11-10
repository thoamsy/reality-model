//
//  PhotogrammetrySessionSetting.swift
//  RealModel
//
//  Created by yk on 2021/11/7.
//

import SwiftUI
import RealityKit

struct PhotogrammetrySessionSetting: View {
  @AppStorage("featureSensitivity") var featureSensitivity = PhotogrammetrySession.Configuration.FeatureSensitivity.normal
  @AppStorage("sampleOrdering") var sampleOrdering = PhotogrammetrySession.Configuration.SampleOrdering.sequential
  @AppStorage("detailLevel") var detailLevel = PhotogrammetrySession.Request.Detail.reduced

  var featureSensitivityComment: String {
    if featureSensitivity == .normal {
      return "The session uses the default algorithm to detect landmarks."
    } else {
      return "The session uses a slower, more sensitive algorithm to dAccording to the product positioning, this device is left in the kitchen alone and supports voice control. So I think it's reasonable to play the next video automatically.etect landmarks."
    }
  }

  var sampleOrderingComment: String {
    sampleOrdering == .unordered ? "Images aren’t in sequential order." : "Images are in sequential order."
  }

  var detailLevelComment: String {
    switch detailLevel {
      case .preview:
        return "Triangles < 25k, file size < 5MB"
      case .reduced:
        return "Triangles < 50k, file size < 10MB"
      case .medium:
        return "Triangles < 100k, file size < 30MB"
      case .full:
        return "Triangles < 250k, file size < 100MB"
      case .raw:
        return "Triangles < 30M, file size no limit"
      @unknown default:
        return ""
    }
  }

  var body: some View {
    Form {
      Picker("Sample Ordering", selection: $sampleOrdering) {
        Text("Unordered").tag(PhotogrammetrySession.Configuration.SampleOrdering.unordered)
        Text("Sequential").tag(PhotogrammetrySession.Configuration.SampleOrdering.sequential)
      }.pickerStyle(.radioGroup)
      Text(sampleOrderingComment)
        .foregroundColor(.secondary)
      Picker("Feature Sensitivity", selection: $featureSensitivity) {
        Text("Normal").tag(PhotogrammetrySession.Configuration.FeatureSensitivity.normal)
        Text("High").tag(PhotogrammetrySession.Configuration.FeatureSensitivity.high)
      }.pickerStyle(.radioGroup)
      Text(featureSensitivityComment)
        .foregroundColor(.secondary)

      Picker("Detail Level", selection: $detailLevel) {
        Text("Preview").tag(PhotogrammetrySession.Request.Detail.preview)
        Text("Reduced").tag(PhotogrammetrySession.Request.Detail.reduced)
        Text("Medium").tag(PhotogrammetrySession.Request.Detail.medium)
        Text("Full").tag(PhotogrammetrySession.Request.Detail.full)
        Text("Raw").tag(PhotogrammetrySession.Request.Detail.raw)
      }
        .pickerStyle(.automatic)
        .frame(width: 200)

      VStack(alignment: .leading) {
        Text("Higher levels of detail take longer, require more memory and processing power to generate, and create objects with more complex geometry. ")
          .lineLimit(3)
        Text(detailLevelComment)
      }
      .foregroundColor(.secondary)
    }.padding()
  }
}

struct PhotogrammetrySessionConfigForm_Previews: PreviewProvider {
  static var previews: some View {
    PhotogrammetrySessionSetting()
  }
}


extension PhotogrammetrySession.Configuration.SampleOrdering: RawRepresentable {
  public init?(rawValue: String) {
    switch rawValue.lowercased() {
      case "unordered":
        self = .unordered
      case "sequential":
        self = .sequential
      default:
        return nil
    }
  }

  public var rawValue: String {
    return self == .unordered ? "unordered" : "sequential"
  }

  public typealias RawValue = String
}

extension PhotogrammetrySession.Configuration.FeatureSensitivity: RawRepresentable {
  public init?(rawValue: String) {
    switch rawValue.lowercased() {
      case "normal":
        self = .normal
      case "high":
        self = .high
      default:
        return nil
    }
  }

  public var rawValue: String {
    return self == .normal ? "normal" : "high"
  }

  public typealias RawValue = String
}

//extension PhotogrammetrySession.Request.Detail: CaseIterable {
//  public typealias AllCases = [Int]
//}


/// Error thrown when an illegal option is specified.
private enum IllegalOption: Swift.Error {
  case invalidDetail(String)
  case invalidSampleOverlap(String)
  case invalidSampleOrdering(String)
  case invalidFeatureSensitivity(String)
}
