//
//  ShareViewController.swift
//  Share
//
//  Created by Albert Gil Escura on 18/9/21.
//

import UIKit
import Social
import MobileCoreServices
import CoreDataClient
import CoreDataClientLive
import FileClient
import FileClientLive
import SharedModels
import Combine
import UniformTypeIdentifiers

class ShareViewController: SLComposeServiceViewController {
    
    let coreDataClientLive: CoreDataClient = .live
    let fileClientLive: FileClient = .live
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
                    
                    self.fileClientLive.addVideo(url, entryVideo, .main)
                        .sink(receiveValue: { [unowned self] entryVideo in
                            let entry = Entry(
                                id: UUID(),
                                date: date,
                                startDay: date,
                                text: EntryText(id: UUID(), message: self.textView.text!, lastUpdated: date),
                                attachments: [entryVideo]
                            )
                            
                            self.coreDataClientLive.createDraft(entry)
                                .sink(receiveValue: { [unowned self] in
                                    self.coreDataClientLive.publishEntry(entry)
                                        .sink(receiveValue: { [unowned self] in
                                            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                                        })
                                        .store(in: &self.bag)
                                })
                                .store(in: &self.bag)
                        })
                        .store(in: &self.bag)
                }
            }
        }
        
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.jpeg.identifier as String) {
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
                        .sink(receiveValue: { [unowned self] entryImage in
                            let entry = Entry(
                                id: UUID(),
                                date: date,
                                startDay: date,
                                text: .init(id: UUID(), message: self.textView.text!, lastUpdated: date),
                                attachments: [entryImage]
                            )
                            
                            self.coreDataClientLive.createDraft(entry)
                                .sink(receiveValue: { [unowned self] in
                                    self.coreDataClientLive.publishEntry(entry)
                                        .sink(receiveValue: { [unowned self] in
                                            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                                        })
                                        .store(in: &self.bag)
                                })
                                .store(in: &self.bag)
                        })
                        .store(in: &self.bag)
                }
            }
        }
        
        if itemProvider.hasItemConformingToTypeIdentifier("public.audio") {
            itemProvider.loadItem(forTypeIdentifier: "public.audio") { [unowned self] audioUrl, _ in
                
                if let url = audioUrl as? URL {
                    let id = UUID()
                    let date = Date()
                    let path = self.fileClientLive.path(id).appendingPathExtension(url.pathExtension)
                    
                    let entryAudio = EntryAudio(id: id, lastUpdated: date, url: path)
                    
                    self.fileClientLive.addAudio(url, entryAudio, .main)
                        .sink(receiveValue: { [unowned self] entryAudio in
                            let entry = Entry(
                                id: UUID(),
                                date: date,
                                startDay: date,
                                text: EntryText(id: UUID(), message: self.textView.text!, lastUpdated: date),
                                attachments: [entryAudio]
                            )
                            
                            self.coreDataClientLive.createDraft(entry)
                                .sink(receiveValue: { [unowned self] in
                                    self.coreDataClientLive.publishEntry(entry)
                                        .sink(receiveValue: { [unowned self] in
                                            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                                        })
                                        .store(in: &self.bag)
                                })
                                .store(in: &self.bag)
                        })
                        .store(in: &self.bag)
                }
                
            }
        }
    }
}
