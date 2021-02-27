
import Foundation
import ObjectMapper

private let locationGroup = "Location"

protocol InsertableCacherType: MappableCacherType {
    func insertObject<T: Mappable>(_ object: T)
}

class LocationCacher: SqliteCacher {
    static var location = LocationCacher(name: locationGroup)
    
    override init(name: String?, group: String = locationGroup) {
        let name = name ?? locationGroup
        super.init(name: name, group: group)
    }
}

extension LocationCacher: InsertableCacherType {
    func insertObject<T: Mappable>(_ object: T) {
        var array = getArray(of: T.self).array
        array.append(object)
        saveArray(array)
    }
}
