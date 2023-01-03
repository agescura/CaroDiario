//
//  Live.swift
//  CoredataClient
//
//  Created by Albert Gil Escura on 28/6/21.
//

import Foundation
import CoreData
import ComposableArchitecture
import Combine
import Models
import Dependencies

extension CoreDataClient: DependencyKey {
  public static var liveValue: CoreDataClient {
    let coreDataStack = CoreDataStack(modelName: "CoreDataModel")
    
    return Self(
      
      create: { id in
        Effect.run { subscriber in
          let delegate = CoreDataNotifier(
            coreDataStack: coreDataStack,
            subscriber: subscriber
          )
          
          dependencies[id] = Dependencies(
            delegate: delegate,
            subscriber: subscriber
          )
          
          return AnyCancellable {
            dependencies[id] = nil
          }
        }
      },
      
      destroy: { id in
          .fireAndForget {
            dependencies[id]?.subscriber.send(completion: .finished)
            dependencies[id] = nil
          }
      },
      
      createDraft: { entry in
        let entryMO = EntryMO(context: coreDataStack.managedContext)
        entryMO.id = entry.id
        entryMO.startDay = Calendar.current.startOfDay(for: entry.date)
        entryMO.created = entry.date
        entryMO.lastUpdated = entry.date
        entryMO.isDraft = true
        
        let textMO = TextMO(context: coreDataStack.managedContext)
        textMO.id = entry.text.id
        textMO.message = entry.text.message
        textMO.lastUpdated = entry.date
        
        entryMO.text = textMO
        
        for attachment in entry.attachments {
          if let image = attachment as? EntryImage {
            let imageMO = ImageMO(context: coreDataStack.managedContext)
            imageMO.id = image.id
            imageMO.url = image.url
            imageMO.thumbnail = image.thumbnail
            imageMO.lastUpdated = image.lastUpdated
            entryMO.addToAttachments(imageMO)
          } else if let video = attachment as? EntryVideo {
            let videoMO = VideoMO(context: coreDataStack.managedContext)
            videoMO.id = video.id
            videoMO.url = video.url
            videoMO.thumbnail = video.thumbnail
            videoMO.lastUpdated = video.lastUpdated
            entryMO.addToAttachments(videoMO)
          } else if let audio = attachment as? EntryAudio {
            let audioMO = AudioMO(context: coreDataStack.managedContext)
            audioMO.id = audio.id
            audioMO.url = audio.url
            audioMO.lastUpdated = audio.lastUpdated
            entryMO.addToAttachments(audioMO)
          }
        }
        
        coreDataStack.saveContext()
        return Effect(value: ())
      },
      
      publishEntry: { entry in
        let request = NSFetchRequest<EntryMO>(entityName: EntryMO.entityName)
        request.predicate = NSPredicate(format: "%K == %@", "id", entry.id as CVarArg)
        do {
          if let entryToPublish = try coreDataStack.managedContext.fetch(request).first {
            entryToPublish.isDraft = false
          }
        } catch let error as NSError {
          print("ERROR: \(error.localizedDescription)")
        }
        coreDataStack.saveContext()
        return Effect(value: ())
      },
      
      removeEntry: { entry in
        let request = NSFetchRequest<EntryMO>(entityName: EntryMO.entityName)
        request.predicate = NSPredicate(format: "%K == %@", "id", entry as CVarArg)
        do {
          if let entryToRemove = try coreDataStack.managedContext.fetch(request).first {
            coreDataStack.managedContext.delete(entryToRemove)
          }
        } catch let error as NSError {
          print("ERROR: \(error.localizedDescription)")
        }
        coreDataStack.saveContext()
        return Effect(value: ())
      },
      
      fetchEntry: { entry in
        let request = NSFetchRequest<EntryMO>(entityName: EntryMO.entityName)
        request.predicate = NSPredicate(format: "%K == %@", "id", entry.id as CVarArg)
        do {
          if let entryMO = try coreDataStack.managedContext.fetch(request).first,
             let entry = entryMO.toEntry() {
            return Effect(value: entry)
          }
        } catch let error as NSError {
          print("ERROR: \(error.localizedDescription)")
        }
        fatalError()
      },
      
      fetchAll: {
        let request = NSFetchRequest<EntryMO>(entityName: EntryMO.entityName)
        request.predicate = NSPredicate(format: "isDraft == false")
        request.sortDescriptors = [NSSortDescriptor(key: "lastUpdated", ascending: false)]
        
        var entriesByDay: [[Entry]] = []
        do {
          let results = try coreDataStack.managedContext.fetch(request)
          let groupResultsByDay = Dictionary(grouping: results.compactMap { $0.toEntry() }) {
            $0.startDay
          }
          entriesByDay = Array(groupResultsByDay.values).sorted(by: { $0.first?.date ?? Date() > $1.first?.date ?? Date() })
        } catch let error as NSError {
          print("ERROR: \(error.localizedDescription)")
        }
        return Effect(value: entriesByDay)
      },
      
      updateMessage: { message, entry in
        let request = NSFetchRequest<EntryMO>(entityName: EntryMO.entityName)
        request.predicate = NSPredicate(format: "%K == %@", "id", entry.id as CVarArg)
        do {
          if let entryToUpdateText = try coreDataStack.managedContext.fetch(request).first {
            entryToUpdateText.text!.message = message.message
            entryToUpdateText.text!.lastUpdated = message.lastUpdated
          }
        } catch let error as NSError {
          print("ERROR: \(error.localizedDescription)")
        }
        coreDataStack.saveContext()
        return Effect(value: ())
      },
      
      addAttachmentEntry: { attachment, entry in
        let request = NSFetchRequest<EntryMO>(entityName: EntryMO.entityName)
        request.predicate = NSPredicate(format: "%K == %@", "id", entry as CVarArg)
        do {
          if let entryMO = try coreDataStack.managedContext.fetch(request).first,
             let image = attachment as? EntryImage {
            let imageMO = ImageMO(context: coreDataStack.managedContext)
            imageMO.id = image.id
            imageMO.url = image.url
            imageMO.thumbnail = image.thumbnail
            imageMO.lastUpdated = image.lastUpdated
            entryMO.addToAttachments(imageMO)
          } else if let entryMO = try coreDataStack.managedContext.fetch(request).first,
                    let video = attachment as? EntryVideo {
            let videoMO = VideoMO(context: coreDataStack.managedContext)
            videoMO.id = video.id
            videoMO.url = video.url
            videoMO.thumbnail = video.thumbnail
            videoMO.lastUpdated = video.lastUpdated
            entryMO.addToAttachments(videoMO)
          } else if let entryMO = try coreDataStack.managedContext.fetch(request).first,
                    let audio = attachment as? EntryAudio {
            let audioMO = AudioMO(context: coreDataStack.managedContext)
            audioMO.id = audio.id
            audioMO.url = audio.url
            audioMO.lastUpdated = audio.lastUpdated
            entryMO.addToAttachments(audioMO)
          }
        } catch let error as NSError {
          print("ERROR: \(error.localizedDescription)")
        }
        coreDataStack.saveContext()
        return Effect(value: ())
      },
      
      removeAttachmentEntry: { attachment in
        let request = NSFetchRequest<AttachmentMO>(entityName: AttachmentMO.entityName)
        request.predicate = NSPredicate(format: "%K == %@", "id", attachment as CVarArg)
        do {
          if let attachmentEntryToRemove = try coreDataStack.managedContext.fetch(request).first {
            coreDataStack.managedContext.delete(attachmentEntryToRemove)
          }
        } catch let error as NSError {
          print("ERROR: \(error.localizedDescription)")
        }
        coreDataStack.saveContext()
        return Effect(value: ())
      },
      
      searchEntries: { query in
        let request = NSFetchRequest<EntryMO>(entityName: EntryMO.entityName)
        request.predicate = NSPredicate(format: "text.message contains[c] %@", query)
        var entries: [[Entry]] = []
        do {
          let results = try coreDataStack.managedContext.fetch(request)
          let groupResultsByDay = Dictionary(grouping: results.compactMap { $0.toEntry() }) {
            $0.startDay
          }
          entries = Array(groupResultsByDay.values).sorted(by: { $0.first?.date ?? Date() > $1.first?.date ?? Date() })
        } catch let error as NSError {
          print("ERROR: \(error.localizedDescription)")
        }
        return Effect(value: entries)
      },
      
      searchImageEntries: {
        let request = NSFetchRequest<ImageMO>(entityName: ImageMO.entityName)
        var entries: [[Entry]] = []
        do {
          let results = try coreDataStack.managedContext.fetch(request)
          let entriesMO = results
            .compactMap { $0.entry }
            .unique { $0.id == $1.id }
          let groupResultsByDay = Dictionary(grouping: entriesMO.compactMap { $0.toEntry() }) {
            $0.startDay
          }
          entries = Array(groupResultsByDay.values).sorted(by: { $0.first?.date ?? Date() > $1.first?.date ?? Date() })
        } catch let error as NSError {
          print("ERROR: \(error.localizedDescription)")
        }
        return Effect(value: entries)
      },
      
      searchVideoEntries: {
        let request = NSFetchRequest<VideoMO>(entityName: VideoMO.entityName)
        var entries: [[Entry]] = []
        do {
          let results = try coreDataStack.managedContext.fetch(request)
          let entriesMO = results
            .compactMap { $0.entry }
            .unique { $0.id == $1.id }
          let groupResultsByDay = Dictionary(grouping: entriesMO.compactMap { $0.toEntry() }) {
            $0.startDay
          }
          entries = Array(groupResultsByDay.values).sorted(by: { $0.first?.date ?? Date() > $1.first?.date ?? Date() })
        } catch let error as NSError {
          print("ERROR: \(error.localizedDescription)")
        }
        return Effect(value: entries)
      },
      
      searchAudioEntries: {
        let request = NSFetchRequest<AudioMO>(entityName: AudioMO.entityName)
        var entries: [[Entry]] = []
        do {
          let results = try coreDataStack.managedContext.fetch(request)
          let entriesMO = results
            .compactMap { $0.entry }
            .unique { $0.id == $1.id }
          let groupResultsByDay = Dictionary(grouping: entriesMO.compactMap { $0.toEntry() }) {
            $0.startDay
          }
          entries = Array(groupResultsByDay.values).sorted(by: { $0.first?.date ?? Date() > $1.first?.date ?? Date() })
        } catch let error as NSError {
          print("ERROR: \(error.localizedDescription)")
        }
        return Effect(value: entries)
      }
    )
  }
}

struct Dependencies {
  let delegate: CoreDataNotifier
  let subscriber: Effect<CoreDataClient.Action, Never>.Subscriber
}

var dependencies: [AnyHashable: Dependencies] = [:]

class CoreDataNotifier: NSObject {
  let coreDataStack: CoreDataStack
  let subscriber: Effect<CoreDataClient.Action, Never>.Subscriber
  
  init(coreDataStack: CoreDataStack, subscriber: Effect<CoreDataClient.Action, Never>.Subscriber) {
    self.coreDataStack = coreDataStack
    self.subscriber = subscriber
    
    super.init()
    
    NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
    
    fetchTodos()
  }
  
  @objc func contextObjectsDidChange(_ notification: Notification) {
    fetchTodos()
  }
  
  private func fetchTodos() {
    let request = NSFetchRequest<EntryMO>(entityName: EntryMO.entityName)
    request.predicate = NSPredicate(format: "isDraft == false")
    request.sortDescriptors = [NSSortDescriptor(key: "lastUpdated", ascending: false)]
    
    var entriesByDay: [[Entry]] = []
    do {
      let results = try coreDataStack.managedContext.fetch(request)
      let groupResultsByDay = Dictionary(grouping: results.compactMap { $0.toEntry() }) {
        $0.startDay
      }
      entriesByDay = Array(groupResultsByDay.values).sorted(by: { $0.first?.date ?? Date() > $1.first?.date ?? Date() })
    } catch let error as NSError {
      print("ERROR: \(error.localizedDescription)")
    }
    
    subscriber.send(.entries(entriesByDay))
  }
}
