import Dependencies
import DependenciesMacros
import Foundation
import UIKit

extension DependencyValues {
  public var fileClient: FileClient {
    get { self[FileClient.self] }
    set { self[FileClient.self] = newValue }
  }
}

public typealias Path = String

public enum Resource {
  case image(Data, Path, Path)
  case video(URL, Path, Path)
  case audio(URL, Path, Path)
  private var documentsDirectory: URL { URL.documentsDirectory }
  
  var folder: Path {
    switch self {
    case let .image(_, path, _), let .video(_, path, _), let .audio(_, path, _): path
    }
  }
  
  var path: Path {
    switch self {
    case let .image(_, _, path), let .video(_, _, path), let .audio(_, _, path): path
    }
  }
  
  var data: Data? {
    switch self {
    case let .image(data, _, _): data
    case .video, .audio: nil
    }
  }
  
  var url: URL? {
    switch self {
    case .image: nil
    case let .video(url, _, _), let .audio(url, _, _): url
    }
  }
  
  var resourceDirectory: URL {
    documentsDirectory.appendingPathComponent(folder)
  }
  
  var fileUrl: URL {
    resourceDirectory.appendingPathComponent(path)
  }
}

@DependencyClient
public struct FileClient: Sendable {
    public var removeAttachments: @Sendable ([String]) async throws -> Void
    public var addImage: @Sendable (Resource) async throws -> Void
    public var addVideo: @Sendable (Resource) async throws -> Void
}
