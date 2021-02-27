
import Foundation


enum Result<Value> {
    case success(Value)
    case failure(Error)
    
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    var isFailure: Bool {
        return !isSuccess
    }
    
    var value: Value? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
    
    func map<T>(_ transform: (Value) -> T) -> Result<T> {
        switch self {
            case .success(let value):
                return .success(transform(value))
            case .failure(let error):
                return .failure(error)
        }
    }
}

extension Result where Value == Void {
    static let success: Result = .success(())
}
enum BackendError: Error, LocalizedError {
    case network(Error)
    case jsonSerialization(error: Error)
    case objectSerialization(reason: String)
    case unreachable(Error)
    case badUrl
    case unknown

    var errorDescription: String? {
        switch self {
            case .network, .unknown:
                return "Сервис недоступен. Попробуйте, пожалуйста, позднее."
            case .jsonSerialization:
                return "Неверный формат входящих данных"
            case .objectSerialization:
                return "Сервис недоступен. Попробуйте, пожалуйста, позднее."
            case .unreachable(_):
                return "Нет интернет соединения."
            case .badUrl:
                return "Неверный адрес"
        }
    }
}
