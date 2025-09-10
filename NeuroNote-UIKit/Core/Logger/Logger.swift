//
//  Logger.swift
//  NeuroNote
//
//  Created by Eclipse on 09/09/25.
//

import Foundation

public typealias Fields = [String: Any]

final class Logger {
    
    static let shared = Logger()
    private let dateFormatter: DateFormatter
    
    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    // MARK: - Public Log Functions
    
    func info(
        _ message: String,
        fields: Fields = [:],
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .info, message: message, error: nil, fields: fields, file: file, function: function, line: line)
    }
    
    func debug(
        _ message: String,
        fields: Fields = [:],
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .debug, message: message, error: nil, fields: fields, file: file, function: function, line: line)
    }
    
    func warn(
        _ message: String,
        error: Error? = nil,
        fields: Fields = [:],
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .warn, message: message, error: error, fields: fields, file: file, function: function, line: line)
    }
    
    func error(
        _ message: String,
        error: Error? = nil,
        fields: Fields = [:],
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .error, message: message, error: error, fields: fields, file: file, function: function, line: line)
    }
    
    // MARK: - Core Logger
    
    private func log(
        level: LogLevel,
        message: String,
        error: Error?,
        fields: Fields,
        file: String,
        function: String,
        line: Int
    ) {
        var logData: [String: Any] = [
            "timestamp": Int(Date().timeIntervalSince1970),
            "level": level.rawValue,
            "message": message,
            "file": file,
            "function": function,
            "line": line
        ]
        
        if let error = error {
            logData["error"] = error.localizedDescription
            logData["errorType"] = String(describing: type(of: error))
        }
        
        fields.forEach { key, value in
            logData[key] = value
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: logData, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        } else {
            print("Logger: Failed to serialize log data")
        }
    }
}
