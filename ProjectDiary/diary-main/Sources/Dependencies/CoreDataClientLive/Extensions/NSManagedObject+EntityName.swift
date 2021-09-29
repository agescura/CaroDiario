//
//  NSManagedObject+entityName.swift
//  
//
//  Created by Albert Gil Escura on 24/7/21.
//

import CoreData

extension NSManagedObject {
    class var entityName: String {
        return String(describing: self).components(separatedBy: ".").last!
    }
}
