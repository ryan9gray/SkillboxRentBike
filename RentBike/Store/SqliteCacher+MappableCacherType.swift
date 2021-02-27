
import ObjectMapper
import SQLite

extension SqliteCacher: MappableCacherType {
    
    // MARK: - MappableCacherType

    func saveObject<T: Mappable>(_ object: T) {
        if let jsonString = Mapper<T>().toJSONString(object) {
            saveString(jsonString, forMappableName: String(describing: T.self))
        }
    }

    func getObject<T: Mappable>(of type: T.Type) -> T? {
        if let stringValue = getString(forMappableName: String(describing: T.self)),
            let object = Mapper<T>().map(JSONString: stringValue) {
            return object
        }
        return nil
    }

    func saveObject<T: Mappable>(_ object: T, withId identifier: String) {
        if let jsonString = Mapper<T>().toJSONString(object) {
            saveString(jsonString, forMappableName: identifier)
        }
    }

    func getObject<T: Mappable>(of type: T.Type, withId identifier: String) -> T? {
        if let stringValue = getString(forMappableName: identifier),
            let object = Mapper<T>().map(JSONString: stringValue) {
            return object
        }
        return nil
    }

    func saveArray<T: Mappable>(_ array: [T]) {
        if let jsonString = Mapper<T>().toJSONString(array) {
            saveString(jsonString, forMappableName: String(describing: T.self))
        }
    }

    func saveArray<T: Mappable>(_ array: [T], withId identifier: String) {
        if let jsonString = Mapper<T>().toJSONString(array) {
            saveString(jsonString, forMappableName: identifier)
        }
    }

    /// Возвращает массив и признак необходимости перезапросить данные
    func getArray<T: Mappable>(of type: T.Type, withId identifier: String?) -> (array: [T], needReload: Bool) {

        var needReloadData: Bool = true
        do {
            let connection = try databaseConnection()
            let table = try mappableTable(withConnection: connection)
            let select = table.select(dataColumn, expirationColumn).where(nameColumn == identifier ?? String(describing: T.self))
            for result in try connection.prepare(select) {

                if try result.get(expirationColumn) > Date() {
                    needReloadData = try result.get(expirationColumn).dateByAddingDays(-1) <= Date()
                }
                else {
                    print("\(String(describing: T.Type.self)) cache need reload")
                }
                let stringValue = try result.get(dataColumn)
                if let array = Mapper<T>().mapArray(JSONString: stringValue) {
                    return (array, needReloadData)
                }
            }
        } catch let error as NSError {
            print(error.description)
        }
        return ([], needReloadData)
    }
    func getArray<T>(of type: T.Type) -> (array: [T], needReload: Bool) where T : Mappable {
        return self.getArray(of: type, withId: nil)
    }

    func cacheExpired<T: Mappable>(for type: T.Type) -> Bool {
        let needReloadData: Bool = true
        do {
            let connection = try databaseConnection()
            let table = try mappableTable(withConnection: connection)
            let select = table.select(expirationColumn).where(nameColumn == String(describing: T.self))
            for result in try connection.prepare(select) {
                if try result.get(expirationColumn) < Date() {
                    return needReloadData
                } else {
                    return try result.get(expirationColumn).dateByAddingDays(-1) <= Date()
                }
            }
        } catch let error as NSError {
            print(error.description)
        }
        return needReloadData
    }

    func removeValue<T: Mappable>(of type: T.Type) {
        removeString(forMappableName: String(describing: T.self))
    }

    func removeValue(forIdentifier identifier: String) {
        removeString(forMappableName: identifier)
    }

}
extension Date {
    func dateByAddingDays(_ days: Int) -> Date {
        return dateByAdding(component: .day, value: days)
    }

    private func dateByAdding(component: NSCalendar.Unit, value: Int) -> Date {
        return (Calendar.current as NSCalendar).date(
            byAdding: component,
            value: value,
            to: self,
            options: []
            ) ?? self
    }
}
