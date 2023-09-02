import Foundation
import CoreData


extension VideoMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoMO> {
        return NSFetchRequest<VideoMO>(entityName: "VideoMO")
    }

    @NSManaged public var url: URL?
    @NSManaged public var thumbnail: URL?

}
