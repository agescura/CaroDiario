import Dependencies
import Foundation
import Models
import OSLog
import SQLiteData

public func appDatabase() throws -> any DatabaseWriter {
  @Dependency(\.context) var context
  let database: any DatabaseWriter
  
  var configuration = Configuration()
  configuration.prepareDatabase { db in
    #if DEBUG
    db.trace(options: .profile) {
      if context == .preview {
        print("\($0.expandedDescription)")
      } else {
        logger.debug("\($0.expandedDescription)")
      }
    }
    #endif
  }
  
  switch context {
  case .live:
    let path = URL.documentsDirectory.appending(component: "db.sqlite").path()
    logger.info("open \(path)")
    database = try DatabasePool(path: path, configuration: configuration)
  case .preview, .test:
    database = try DatabaseQueue(configuration: configuration)
  }
  
  var migrator = DatabaseMigrator()
  #if DEBUG
  migrator.eraseDatabaseOnSchemaChange = true
  #endif
  migrator.registerMigration("Create 'entries'") { db in
    try #sql(
     """
     CREATE TABLE "entries" (
      "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
      "createdAt" TEXT,
      "isDraft" INTEGER NOT NULL DEFAULT 0,
      "updatedAt" TEXT,
      "message" TEXT NOT NULL DEFAULT ''
     ) STRICT
     """
    )
    .execute(db)
    
    try #sql(
     """
     CREATE TABLE "assets" (
      "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
      "pathUrl" TEXT NOT NULL,
      "format" TEXT
     ) STRICT
     """
    )
    .execute(db)
    
    try #sql(
     """
     CREATE TABLE "entryAssets" (
      "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
      "assetID" TEXT NOT NULL REFERENCES "assets"("id") ON DELETE CASCADE,
      "entryID" TEXT NOT NULL REFERENCES "entries"("id") ON DELETE CASCADE
     ) STRICT
     """
    )
    .execute(db)
  }
  
  try migrator.migrate(database)
  return database
}

extension DependencyValues {
  public mutating func bootstrapDatabase() throws {
    defaultDatabase = try appDatabase()
  }
}

#if DEBUG
extension DatabaseWriter {
  public func seed() throws {
    try write { db in
      try db.seed {
        @Dependency(\.date.now) var now
        
        Entry.Draft(id: UUID(1), createdAt: now, isDraft: false, updatedAt: now, message: "This is a message")
        Entry.Draft(id: UUID(2), createdAt: now, isDraft: false, updatedAt: now, message: "This is another message")
        Entry.Draft(id: UUID(3), createdAt: now, isDraft: false, updatedAt: now, message: "This is a random message")
        Entry.Draft(id: UUID(4), createdAt: now.addingTimeInterval(-5*24*60*60), isDraft: false, updatedAt: now.addingTimeInterval(-5*24*60*60), message: "This is the last message")
      }
    }
  }
}
#endif

private nonisolated let logger = Logger(subsystem: "Entries", category: "Database")
