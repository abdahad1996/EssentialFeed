////
////  RemoteFeedLoader.swift
////  EssentialFeed
////
////  Created by Abdul Ahad on 18.12.23.
////
//
//import Foundation
//
//public class RemoteLoader<Resource>{
//    
//    private let url:URL
//    private let client:HTTPClient
//    private let mapper:Mapper
//    
//    public typealias Mapper = (_ data: Data, _ response: HTTPURLResponse) throws -> Resource
//    
//    public enum Error:Swift.Error{
//        case connectivity
//        case invalidData
//    }
//    
//    public typealias Result = Swift.Result<Resource, Swift.Error>
//    
//    public init(url: URL, client: HTTPClient, mapper:@escaping Mapper) {
//        self.url = url
//        self.client = client
//        self.mapper = mapper
//    }
//   
//    
//    public func load(completion:@escaping (Result) -> Void){
//    
//        client.get(from: url, completion: {[weak self] result in
//            guard let self = self else{return}
//            switch result {
//            case .success((let data,let response)):
//                completion(self.map(data, response))
//             
//            case .failure(_):
//                completion(.failure(Error.connectivity))
//            }
//            
//        })
//    }
//    
//     func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
//        do {
//            return .success(try mapper(data, response))
//        }
//        catch  {
//          return .failure(Error.invalidData)
//        }
//     }
//   
//}
//
//
