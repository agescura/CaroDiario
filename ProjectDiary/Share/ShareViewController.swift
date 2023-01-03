import UIKit
import Social
import MobileCoreServices
import CoreDataClient
import FileClient
import Models
import Combine
import UniformTypeIdentifiers
import AVAssetClient
import ComposableArchitecture

class ShareViewController: SLComposeServiceViewController {
    
    let coreDataClientLive: CoreDataClient = .liveValue
    let fileClientLive: FileClient = .liveValue
    let avAssetClient: AVAssetClient = .liveValue
    
    var entry: Entry?
    
    var bag = Set<AnyCancellable>()
    
    override func isContentValid() -> Bool {
        return self.textView.text.count > 0
    }
    
    override func didSelectPost() {
      processPost()
    }
    
    override func configurationItems() -> [Any]! {
        return []
    }
    
    private func processPost() {
        guard let inputItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = inputItem.attachments?.first else { return }
        
        if itemProvider.hasItemConformingToTypeIdentifier("public.movie") {
            itemProvider.loadItem(forTypeIdentifier: "public.movie") { [unowned self] videoUrl, _ in
                
                if let url = videoUrl as? URL {
                    let id = UUID()
                    let thumbnailId = UUID()
                    let date = Date()
                    let thumbnailPath = self.fileClientLive.path(thumbnailId)
                    let path = self.fileClientLive.path(id).appendingPathExtension(url.pathExtension)
                    
                    let entryVideo = EntryVideo(id: id, lastUpdated: date, thumbnail: thumbnailPath, url: path)
                    
                  Task {
                    let thumbnail = try? await self.avAssetClient.generateThumbnail(url)
                    self.fileClientLive.addVideo(url, thumbnail ?? UIImage(), entryVideo, .main)
                      .flatMap(maxPublishers: .max(1)) { [unowned self] entryVideo -> Effect<Void, Never> in
                          let entry = Entry(
                              id: UUID(),
                              date: date,
                              startDay: date,
                              text: EntryText(id: UUID(), message: self.textView.text!, lastUpdated: date),
                              attachments: [entryVideo]
                          )
                          self.entry = entry
                          return self.coreDataClientLive.createDraft(entry)
                              .eraseToEffect()
                      }
                      .flatMap(maxPublishers: .max(1)) { [unowned self] in
                          return self.coreDataClientLive.publishEntry(self.entry!)
                              .eraseToEffect()
                      }
                      .sink(receiveValue: { [unowned self] _ in
                          self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                      })
                      .store(in: &self.bag)
                  }
                }
            }
        }
        
        else if itemProvider.hasItemConformingToTypeIdentifier(UTType.jpeg.identifier as String) {
            itemProvider.loadItem(forTypeIdentifier: UTType.jpeg.identifier as String) { [unowned self] imageData, _ in
                
                if let url = imageData as? URL {
                    let image = UIImage(data: try! Data(contentsOf: url))!
                    let date = Date()
                    
                    let thumbnailId = UUID()
                    let id = UUID()
                    let thumbnailPath = self.fileClientLive.path(thumbnailId)
                    let path = self.fileClientLive.path(id)
                    
                    let entryImage = EntryImage(id: id, lastUpdated: date, thumbnail: thumbnailPath, url: path)
                    
                    self.fileClientLive.addImage(image, entryImage, .main)
                        .eraseToEffect()
                        .flatMap(maxPublishers: .max(1)) { [unowned self] entryImage -> Effect<Void, Never> in
                            let entry = Entry(
                                id: UUID(),
                                date: date,
                                startDay: date,
                                text: .init(id: UUID(), message: self.textView.text!, lastUpdated: date),
                                attachments: [entryImage]
                            )
                            self.entry = entry
                            return self.coreDataClientLive.createDraft(entry)
                                .eraseToEffect()
                        }
                        .flatMap(maxPublishers: .max(1)) { [unowned self] in
                            return self.coreDataClientLive.publishEntry(self.entry!)
                                .eraseToEffect()
                        }
                        .sink(receiveValue: { [unowned self] _ in
                            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                        })
                        .store(in: &self.bag)
                }
            }
        }
        
        else if itemProvider.hasItemConformingToTypeIdentifier("public.audio") {
            itemProvider.loadItem(forTypeIdentifier: "public.audio") { [unowned self] audioUrl, _ in
                
                if let url = audioUrl as? URL {
                    let id = UUID()
                    let date = Date()
                    let path = self.fileClientLive.path(id).appendingPathExtension(url.pathExtension)
                    
                    let entryAudio = EntryAudio(id: id, lastUpdated: date, url: path)
                    
                    self.fileClientLive.addAudio(url, entryAudio, .main)
                        .eraseToEffect()
                        .flatMap(maxPublishers: .max(1)) { [unowned self] entryAudio -> Effect<Void, Never> in
                            let entry = Entry(
                                id: UUID(),
                                date: date,
                                startDay: date,
                                text: EntryText(id: UUID(), message: self.textView.text!, lastUpdated: date),
                                attachments: [entryAudio]
                            )
                            self.entry = entry
                            return self.coreDataClientLive.createDraft(entry)
                                .eraseToEffect()
                        }
                        .flatMap(maxPublishers: .max(1)) { [unowned self] in
                            return self.coreDataClientLive.publishEntry(self.entry!)
                                .eraseToEffect()
                        }
                        .sink(receiveValue: { [unowned self] _ in
                            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                        })
                        .store(in: &self.bag)
                }
            }
        }
        
        else {
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }
    }
}
