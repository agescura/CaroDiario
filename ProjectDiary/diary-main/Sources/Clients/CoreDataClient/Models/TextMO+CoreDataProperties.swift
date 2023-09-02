import Foundation
import CoreData


extension TextMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TextMO> {
        return NSFetchRequest<TextMO>(entityName: "TextMO")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var message: String?
    @NSManaged public var entry: EntryMO?

}
