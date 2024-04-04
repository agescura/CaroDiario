import Foundation
import CoreData


extension AudioMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AudioMO> {
        return NSFetchRequest<AudioMO>(entityName: "AudioMO")
    }

    @NSManaged public var url: URL?
}
