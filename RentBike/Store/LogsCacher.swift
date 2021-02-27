
import Foundation
import SQLite

final class LogsCacher: CacherType {
    
    static var common = LogsCacher.init()
    
    private static var storedConnection: Connection?
    private static var storedLogsTable: Table?
    private static var timerIsOn = false
    private static let serialQueue = DispatchQueue(label: "responseLogsCacherQueue", qos: .background)
    
    private let name: String = "logs"
    private let maxRowsNumber = 10000
    private let dbWriteDelay = 5.0
    
    
    private static var logsBuffer: [LogsCacheModel] = []
    
    private let requestIDColumn = Expression<Int64>("REQUEST_ID")
    private let requestMethodColumn = Expression<String>("REQUEST_METHOD")
    private let requestInfoColumn = Expression<String>("REQUEST_INFO")
    private let responseInfoColumn = Expression<String>("RESPONSE_INFO")
    private let requestTimeColumn = Expression<Date>("REQUEST_TIME")
    private let responseTimeColumn = Expression<Date>("RESPONSE_TIME")
    
    private init() {}
    
    // MARK: - CacherType
    
    func clearAllCache() {
        LogsCacher.storedConnection = nil
        FileManager.default.removeItemIfExistsAtURL(cacheDatabase)
    }
    
    // MARK: - interface methods
    
    
    func addLog(logModel: LogsCacheModel) {
        
        LogsCacher.serialQueue.async {
        LogsCacher.logsBuffer.append(logModel)
        
        guard LogsCacher.timerIsOn == false else{
            return
        }
        
        LogsCacher.timerIsOn = true
            LogsCacher.serialQueue.asyncAfter(deadline: .now() + self.dbWriteDelay, execute: {
            self.releaseBuffer()
            LogsCacher.timerIsOn = false
        })
        }
    }
    
    func getLogs(count: Int, offset: Int, offsetFrom initialRowId: Int64) -> [LogsCacheModel] {
        var logs: [LogsCacheModel] = []
        do {
            let connection = try databaseConnection()
            let table = try logsTable(withConnection: connection)
            let orderedTable = table.order(requestIDColumn.desc).filter(requestIDColumn <= initialRowId).limit(count, offset: offset)
            
            for request in try connection.prepare(orderedTable) {
                let log = LogsCacheModel(requestMethod: try request.get(requestMethodColumn),
                                           responseText: try request.get(responseInfoColumn),
                                           requestText: try request.get(requestInfoColumn),
                                           requestTime: try request.get(requestTimeColumn),
                                           responseTime: try request.get(responseTimeColumn))
                logs.append(log)
            }
        }
        catch let error as NSError {
            print(error.description)
        }
        return logs
    }
    
    func getLogs(count: Int) -> [LogsCacheModel] {
        var logs: [LogsCacheModel] = []
        do {
            let connection = try databaseConnection()
            let table = try logsTable(withConnection: connection)
            let orderedTable = table.order(requestIDColumn.desc).limit(count)
            for request in try connection.prepare(orderedTable) {
                let log = LogsCacheModel(dataBaseRowId: try request.get(requestIDColumn),
                                           requestMethod: try request.get(requestMethodColumn),
                                           responseText: try request.get(responseInfoColumn),
                                           requestText: try request.get(requestInfoColumn),
                                           requestTime: try request.get(requestTimeColumn),
                                           responseTime: try request.get(responseTimeColumn))
                logs.append(log)
            }
        } catch let error as NSError {
            print(error.description)
        }
        return logs
    }

	func getAllLogs() -> [LogsCacheModel] {
		var logs: [LogsCacheModel] = []
		do {
			let connection = try databaseConnection()
			let table = try logsTable(withConnection: connection)
			let orderedTable = table.order(requestIDColumn.desc)
			for request in try connection.prepare(orderedTable) {
				let log = LogsCacheModel(dataBaseRowId: try request.get(requestIDColumn),
										   requestMethod: try request.get(requestMethodColumn),
										   responseText: try request.get(responseInfoColumn),
										   requestText: try request.get(requestInfoColumn),
										   requestTime: try request.get(requestTimeColumn),
										   responseTime: try request.get(responseTimeColumn))
				logs.append(log)
			}
		} catch let error as NSError {
			print(error.description)
		}
		return logs
	}
    
    // MARK: - private methods
    
    private var cacheDatabase: URL {
        let group = "Common"
        let typeString = String(describing: type(of: self))
        let path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        let libraryDirectory = URL(fileURLWithPath: path, isDirectory: true)
        let baseUrl = libraryDirectory.appendingPathComponent(typeString)
        return baseUrl.appendingPathComponent(group).appendingPathComponent(name + ".sqlite3")
    }
    
    private func databaseConnection() throws -> Connection {
        if let storedConnection = LogsCacher.storedConnection {
            return storedConnection
        } else {
            FileManager.default.createDirectoryForFileUrl(cacheDatabase)
            let connection = try Connection(cacheDatabase.path)
            LogsCacher.storedConnection = connection
            return connection
        }
    }
    
    private func logsTable(withConnection connection: Connection) throws -> Table {
        if let table = LogsCacher.storedLogsTable {
            return table
        } else {
            let table = Table("LOGS")
            try connection.run(table.create(temporary: false, ifNotExists: true) { (tableBuilder) in
                tableBuilder.column(requestIDColumn, primaryKey: .autoincrement)
                tableBuilder.column(requestMethodColumn)
                tableBuilder.column(requestInfoColumn)
                tableBuilder.column(responseInfoColumn)
                tableBuilder.column(requestTimeColumn)
                tableBuilder.column(responseTimeColumn)
            })
            return table
        }
    }
    
    private func removeOldLogsIfNeed() {
        do {
            let connection = try databaseConnection()
            let table = try logsTable(withConnection: connection)
            let rowsCount = try connection.scalar(table.count)
            if rowsCount > maxRowsNumber {
                let rowsToDelete = table.order(requestIDColumn).limit(1000)
                try connection.run(rowsToDelete.delete())
            }
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    private func releaseBuffer() {
        do {
            let connection = try databaseConnection()
            let table = try logsTable(withConnection: connection)
            
            removeOldLogsIfNeed()
            
            for logModel in LogsCacher.logsBuffer {
                let insert = table.insert(
                    or: .replace,
                    requestMethodColumn <- logModel.requestMethod,
                    requestInfoColumn <- logModel.requestText,
                    requestTimeColumn <- logModel.requestTime,
                    responseInfoColumn <- logModel.responseText,
                    responseTimeColumn <- logModel.responseTime
                )
                _ = try connection.run(insert)
            }
            
            LogsCacher.logsBuffer = []
        } catch let error as NSError {
            print(error.description)
        }
    }
}

final class LogsCacheModel {
    var dataBaseRowId: Int64?
    var requestMethod: String
    var responseText: String
    var requestText: String
    var requestTime: Date
    var responseTime: Date

    init(requestMethod: String, responseText: String, requestText: String, requestTime: Date, responseTime: Date) {
        self.requestMethod = requestMethod
        self.responseText = responseText
        self.requestText = requestText
        self.requestTime = requestTime
        self.responseTime = responseTime
    }

    init(dataBaseRowId: Int64, requestMethod: String, responseText: String, requestText: String, requestTime: Date, responseTime: Date) {
        self.dataBaseRowId = dataBaseRowId
        self.requestMethod = requestMethod
        self.responseText = responseText
        self.requestText = requestText
        self.requestTime = requestTime
        self.responseTime = responseTime
    }

    var requestTimeString: String {
        return convertDateToString(date: requestTime)
    }

    var responseTimeString: String {
        return convertDateToString(date: responseTime)
    }

    var duration: String  {
        return String(format: "%.3f", responseTime.timeIntervalSince(requestTime))
    }

    private func convertDateToString(date: Date) -> String {
        let outputFormatter = DateFormatter()
        outputFormatter.timeZone = TimeZone.current
        outputFormatter.dateFormat = "dd.MM.yy, HH:mm:ss"
        return outputFormatter.string(from: date)
    }
}
