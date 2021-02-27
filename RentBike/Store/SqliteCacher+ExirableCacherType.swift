

import SQLite

extension SqliteCacher: ExpirableCacherType {

    // MARK: - MappableCacherType

    func expirableTable(withConnection connection: Connection) throws -> Table {
        let table = Table("EXPIRABLE")
        try connection.run(table.create(temporary: false, ifNotExists: true) { (tableBuilder) in
            tableBuilder.column(nameColumn, primaryKey: true)
            tableBuilder.column(categoryColumn)
            tableBuilder.column(dataColumn)
            tableBuilder.column(expirationColumn)
        })
        return table
    }

    func saveValue(forId identifier: String, value: String, expiration: Date) {
        saveValue(forId: identifier, value: value, expiration: expiration, category: nil)
    }

    func saveValue(forId identifier: String, value: String, expiration: Date, category: String?) {
        do {
            let connection = try databaseConnection()
            let table = try expirableTable(withConnection: connection)
            let insert = table.insert(
                or: .replace,
                nameColumn <- identifier,
                dataColumn <- value,
                categoryColumn <- category,
                expirationColumn <- expiration)
            try connection.run(insert)
        } catch let error as NSError {
            print(error.description)
        }
    }

    func getValue(forId identifier: String) -> String? {
        return self.getValue(forId: identifier, shoudDelete: true)
    }
    func getValue(forId identifier: String, shoudDelete: Bool) -> String? {

        do {
            let connection = try databaseConnection()
            let table = try expirableTable(withConnection: connection)
            let select = table.select(dataColumn, expirationColumn).where(nameColumn == identifier)
            for result in try connection.prepare(select) {
                if try result.get(expirationColumn) < Date() {
                    if shoudDelete {
                        removeValue(forId: identifier)
                    }
                } else {
                    return try result.get(dataColumn)
                }
            }
        } catch let error as NSError {
            print(error.description)
        }
        return nil
    }

    func getForceValue(forId identifier: String) -> String? {
        do {
            let connection = try databaseConnection()
            let table = try expirableTable(withConnection: connection)
            let select = table.select(dataColumn, expirationColumn).where(nameColumn == identifier)
            for result in try connection.prepare(select) {
                return try result.get(dataColumn)
            }
        } catch let error as NSError {
            print(error.description)
        }
        return nil
    }

    func removeValue(forId identifier: String) {
        do {
            let connection = try databaseConnection()
            let table = try expirableTable(withConnection: connection)
            let delete = table.filter(nameColumn == identifier).delete()
            try connection.run(delete)
        } catch let error as NSError {
            print(error.description)
        }
    }

    func removeValues(forCategory category: String?) {
        do {
            let connection = try databaseConnection()
            let table = try expirableTable(withConnection: connection)
            let delete = table.filter(categoryColumn == category).delete()
            try connection.run(delete)
        } catch let error as NSError {
            print(error.description)
        }
    }

    func clearAllExpirable() {
        do {
            let connection = try databaseConnection()
            let table = try expirableTable(withConnection: connection)
            let delete = table.delete()
            try connection.run(delete)
        } catch let error as NSError {
            print(error.description)
        }
    }

}
