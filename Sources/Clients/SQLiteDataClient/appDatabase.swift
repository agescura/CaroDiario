import Dependencies
import Foundation
import Models
import SQLiteData

public func appDatabase() throws -> any DatabaseWriter {
  var configuration = Configuration()
  configuration.prepareDatabase { db in
    #if DEBUG
    db.trace {
      print($0.expandedDescription)
    }
    #endif
  }
  let database = try SQLiteData.defaultDatabase(configuration: configuration)
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
      "dayDate" TEXT,
      "updatedAt" TEXT,
      "message" TEXT NOT NULL DEFAULT ''
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

extension DatabaseWriter {
  public func seed() throws {
    try write { db in
      try db.seed {
        @Dependency(\.date.now) var now
        
        Entry.Draft(id: UUID(1), createdAt: now, updatedAt: now, message: "This is a message")
        Entry.Draft(id: UUID(2), createdAt: now, updatedAt: now, message: "This is another message")
        Entry.Draft(id: UUID(3), createdAt: now, updatedAt: now, message: "This is a random message")
        Entry.Draft(id: UUID(4), createdAt: now.addingTimeInterval(-5*24*60*60), updatedAt: now.addingTimeInterval(-5*24*60*60), message: "This is the last message")
      }
    }
  }
}
