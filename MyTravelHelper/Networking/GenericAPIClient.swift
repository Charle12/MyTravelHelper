//
//  GenericAPIClient.swift
//  MyTravelHelper
//
//  Created by Prabhat Pandey on 19/11/2020.
//  Copyright © 2020 Prabhat Pandey. All rights reserved.

import Foundation
import XMLParsing

public typealias Parameters = [String : String]

protocol GenericAPIClient {
    
    var session: URLSession { get }
    func fetch<T: Decodable>(with request: URLRequest, decode: @escaping (Decodable) -> T?, completion: @escaping (Result<T, APIError>) -> Void)
    func send<T: Decodable>(with request: URLRequest, with parameter: Parameters, decode: @escaping (Decodable) -> T?, completion: @escaping (Result<T, APIError>) -> Void)
}

extension GenericAPIClient {
    typealias JSONTaskCompletionHandler = (Decodable?, APIError?) -> Void
    
    func decodingTask<T: Decodable>(with request: URLRequest, decodingType: T.Type, completionHandler completion: @escaping JSONTaskCompletionHandler) -> URLSessionDataTask {
        
        let task = session.dataTask(with: request) { data, response, error in
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, .requestFailed)
                return
            }
            if httpResponse.statusCode == 200 {
                if let data = data {
//                    let str = String(decoding: data, as: UTF8.self)
//                    print(str)
                    let model = try? XMLDecoder().decode(T.self, from: data)
                    completion(model, nil)
                } else {
                    completion(nil, .invalidData)
                }
            } else {
//                if let data = data {
//                    let str = String(decoding: data, as: UTF8.self)
//                    print(str)
//                }
                completion(nil, .responseUnsuccessful)
            }
        }
        return task
    }
    
    func fetch<T: Decodable>(with request: URLRequest, decode: @escaping (Decodable) -> T?, completion: @escaping (Result<T, APIError>) -> Void) {
        var urlRequest = request
        urlRequest.httpMethod = HttpUtils.HTTP_METHOD_GET
        let task = decodingTask(with: urlRequest, decodingType: T.self) { (json , error) in
            
            //MARK: change to main queue
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completion(Result.failure(error))
                    } else {
                        completion(Result.failure(.invalidData))
                    }
                    return
                }
                if let value = decode(json) {
                    completion(.success(value))
                } else {
                    completion(.failure(.jsonParsingFailure))
                }
            }
        }
        task.resume()
    }
    
    func send<T: Decodable>(with request: URLRequest, with parameter: Parameters, decode: @escaping (Decodable) -> T?, completion: @escaping (Result<T, APIError>) -> Void) {
        var urlRequest = request
        urlRequest.httpMethod = HttpUtils.HTTP_METHOD_POST
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        do {
            let data = try JSONSerialization.data(withJSONObject: parameter, options: .prettyPrinted)
            if let jsonString = String.init(data: data, encoding: .utf8) {
                let dataSet = Data(bytes: jsonString, count: jsonString.count)
                if urlRequest.value(forHTTPHeaderField: HttpUtils.HTTP_HEADER_CONTENT_TYPE) == nil {
                    urlRequest.setValue( HttpUtils.HTTP_HEADER_APPLICATION_JSON, forHTTPHeaderField:  HttpUtils.HTTP_HEADER_CONTENT_TYPE)
                }
                urlRequest.httpBody = dataSet
            }
        } catch {
            print("eroor")
        }
        let task = decodingTask(with: urlRequest, decodingType: T.self) { (json , error) in
            //MARK: change to main queue
            DispatchQueue.main.async {
                 guard let json = json else {
                    if let error = error {
                        completion(Result.failure(error))
                    } else {
                        completion(Result.failure(.invalidData))
                    }
                    return
                }
                if let value = decode(json) {
                    completion(.success(value))
                } else {
                    completion(.failure(.jsonParsingFailure))
                }
            }
        }
        task.resume()
    }
}
