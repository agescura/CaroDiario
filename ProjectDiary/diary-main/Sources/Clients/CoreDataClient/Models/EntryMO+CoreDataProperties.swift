import Foundation
import CoreData


extension EntryMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntryMO> {
        return NSFetchRequest<EntryMO>(entityName: "EntryMO")
    }

    @NSManaged public var created: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isDraft: Bool
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var startDay: Date?
    @NSManaged public var text: TextMO?
    @NSManaged public var attachments: NSSet?

}

extension EntryMO {

    @objc(addAttachmentsObject:)
    @NSManaged public func addToAttachments(_ value: AttachmentMO)

    @objc(removeAttachmentsObject:)
    @NSManaged public func removeFromAttachments(_ value: AttachmentMO)

    @objc(addAttachments:)
    @NSManaged public func addToAttachments(_ values: NSSet)

    @objc(removeAttachments:)
    @NSManaged public func removeFromAttachments(_ values: NSSet)

}
