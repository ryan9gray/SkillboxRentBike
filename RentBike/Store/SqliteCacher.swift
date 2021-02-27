
import SQLite

class SqliteCacher: CacherType {
    
    private static var userCacher: SqliteCacher?
    static var common = SqliteCacher.init(name: "sessionKey")
    
    private var storedConnection: Connection?
    var group: String
    var name: String
    
    internal let nameColumn = Expression<String>("NAME")
    internal let categoryColumn = Expression<String?>("CATEGORY")
    internal let dataColumn = Expression<String>("DATA")
    internal let expirationColumn = Expression<Date>("EXPIRATION")
    
    init(name: String? = "Common", group: String = "Common") {
        self.name = name ?? "Common"
        self.group = group
    }
    
    private var cacheDatabase: URL {
        
        let typeString = String(describing: type(of: self))
        let path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        let libraryDirectory = URL(fileURLWithPath: path, isDirectory: true)
        let baseUrl = libraryDirectory.appendingPathComponent(typeString)
        
        return baseUrl
            .appendingPathComponent(group)
            .appendingPathComponent(name + ".sqlite3")
    }
    
    internal func databaseConnection() throws -> Connection {
        if let storedConnection = storedConnection {
            return storedConnection
        } else {
            FileManager.default.createDirectoryForFileUrl(cacheDatabase)
            let connection = try Connection(cacheDatabase.path)
            storedConnection = connection
            return connection
        }
    }
    
    // MARK: - CacherType
    
    func clearAllCache() {
        storedConnection = nil
        FileManager.default.removeItemIfExistsAtURL(cacheDatabase)
    }
    
    // MARK: - mappable cacher
    
    func mappableTable(withConnection connection: Connection) throws -> Table {
        let table = Table("MAPPABLE")
        try connection.run(table.create(temporary: false, ifNotExists: true) { (tableBuilder) in
            tableBuilder.column(nameColumn, primaryKey: true)
            tableBuilder.column(dataColumn)
            tableBuilder.column(expirationColumn)
        })
        return table
    }
    
    func saveString(_ string: String, forMappableName name: String) {
        do {
            let connection = try databaseConnection()
            let table = try mappableTable(withConnection: connection)
            let insert = table.insert(
                or: .replace,
                nameColumn <- name,
                dataColumn <- string,
                expirationColumn <- Date().dateByAddingDays(2)
            )
            try connection.run(insert)
        } catch let error as NSError {
            print(error.description)
        }
    }
    func saveString(_ string: String, exp: Date, forMappableName name: String) {
        do {
            let connection = try databaseConnection()
            let table = try mappableTable(withConnection: connection)
            let insert = table.insert(
                or: .replace,
                nameColumn <- name,
                dataColumn <- string,
                expirationColumn <- exp
            )
            try connection.run(insert)
        } catch let error as NSError {
            print(error.description)
        }
    }
    func getString(forMappableName name: String) -> String? {
        do {
            let connection = try databaseConnection()
            let table = try mappableTable(withConnection: connection)
            let select = table.select(dataColumn).where(nameColumn == name)
            for result in try connection.prepare(select) {
                return try result.get(dataColumn)
            }
        } catch let error as NSError {
            print(error.description)
        }
        return nil
    }
    
    func removeString(forMappableName name: String) {
        do {
            let connection = try databaseConnection()
            let table = try mappableTable(withConnection: connection)
            let delete = table.filter(nameColumn == name).delete()
            try connection.run(delete)
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func clearAllMappable() {
        do {
            let connection = try databaseConnection()
            let table = try mappableTable(withConnection: connection)
            let delete = table.delete()
            try connection.run(delete)
        } catch let error as NSError {
            print(error.description)
        }
    }
    
}

extension FileManager {

    func fileExistsAtURL(_ url: URL) -> Bool {
        return fileExists(atPath: url.path)
    }

    func removeItemIfExistsAtURL(_ url: URL) {
        do {
            if fileExistsAtURL(url) {
                try removeItem(at: url)
            }
        } catch let error {
            print(String(describing: error))
        }
    }

    func createDirectoryForFileUrl(_ url: URL) {
        do {
            let directoryUrl = url.deletingLastPathComponent()
            if !fileExistsAtURL(directoryUrl) {
                try createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
            }
        } catch {
        }
    }
}
