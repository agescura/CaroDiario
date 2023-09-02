import Foundation
import CoreData


extension AttachmentMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AttachmentMO> {
        return NSFetchRequest<AttachmentMO>(entityName: "AttachmentMO")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var entry: EntryMO?

}
