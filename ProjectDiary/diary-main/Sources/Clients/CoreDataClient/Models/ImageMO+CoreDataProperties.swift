import Foundation
import CoreData


extension ImageMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageMO> {
        return NSFetchRequest<ImageMO>(entityName: "ImageMO")
    }

    @NSManaged public var url: URL?
    @NSManaged public var thumbnail: URL?

}
