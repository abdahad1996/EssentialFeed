//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Abdul Ahad on 18.12.23.
//

import Foundation

public enum HttpClientResult {
    case success(Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HttpClient{
    func get(from url:URL,completion:@escaping (HttpClientResult)->Void)
    
}

public class RemoteFeedLoader{
    
    private let url:URL
    private let client:HttpClient
    public enum Error:Swift.Error{
        case connectivity
        case invalidData
    }
    
    public enum Result:Equatable{
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HttpClient) {
        self.url = url
        self.client = client
    }
   
    
    public func load(completion:@escaping (Result) -> Void){
    
        client.get(from: url, completion: {result in
            switch result {
            case .success(let data,let response):
                do {
                   let items = try FeedItemsMapper.map(data, response)
                    completion(.success(items))
                }catch{
                    completion(.failure(.invalidData))

                }
                 
                
            case .failure(_):
                completion(.failure(.connectivity))
            }
            
        })
    }
}

private class FeedItemsMapper{
    private struct Root: Decodable {
        let items: [Item]
    }
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    static var OK_200: Int { return 200 }

    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else{
            throw RemoteFeedLoader.Error.invalidData
        }
        
     let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map{$0.item}
    }
}

