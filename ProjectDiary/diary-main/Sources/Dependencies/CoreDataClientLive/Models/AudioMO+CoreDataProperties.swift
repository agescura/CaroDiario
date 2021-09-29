//
//  AudioMO+CoreDataProperties.swift
//  
//
//  Created by Albert Gil Escura on 1/8/21.
//
//

import Foundation
import CoreData


extension AudioMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AudioMO> {
        return NSFetchRequest<AudioMO>(entityName: "AudioMO")
    }

    @NSManaged public var url: URL?
}
