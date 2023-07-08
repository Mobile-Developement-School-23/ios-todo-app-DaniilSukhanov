//
//  URLSession+dataTask.swift
//  ToDoList_UIKit
//
//  Created by Даниил Суханов on 03.07.2023.
//

import Foundation
import OSLog

enum URLSessionError: Error {
    case waitingTooLong
    case failureToReceiveData(Error?)
}

extension URLSession {
    fileprivate static let logger = Logger(category: String(describing: URLSession.self))
    fileprivate static let maxTimeWait = 5

    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                let networkTask = dataTask(with: urlRequest) { data, response, error in
                    if let data = data, let response = response {
                        URLSession.logger.debug("\(String.logFormat()) возрат значения")
                        continuation.resume(returning: (data, response))
                    } else {
                        URLSession.logger.error("\(String.logFormat()) неудалось получить данные")
                        continuation.resume(throwing: URLSessionError.failureToReceiveData(error))
                    }
                }
                networkTask.resume()
                DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(URLSession.maxTimeWait)) {
                    if networkTask.state == .canceling || networkTask.state == .completed {
                        return
                    }
                    networkTask.cancel()
                    URLSession.logger.debug(
                        "\(String.logFormat()) запрост \(networkTask) был отменен через \(URLSession.maxTimeWait) сек."
                    )
                    continuation.resume(throwing: URLSessionError.waitingTooLong)
                }
            }
        } onCancel: {
            URLSession.logger.info("\(String.logFormat()) задача была отменена")
        }
    }
}
