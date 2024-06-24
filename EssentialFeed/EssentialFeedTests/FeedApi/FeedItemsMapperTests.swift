//
//  FeedItemsMapperTests.swift
//  EssentialFeedTests
//
//  Created by macbook abdul on 24/06/2024.
//

import Foundation
import EssentialFeed
import XCTest


class FeedItemsMapperTests:XCTest{
    
    func test_map_throwsErrorOnNon200HttpResponses() throws {
        
       let json = makeItemsJSON([])
       let samples = [199,201,300,400,500]
        
       try samples.enumerated().forEach { index,code in

            XCTAssertThrowsError(
               
                try FeedItemsMapper.map(json, HTTPURLResponse(statusCode: code))
            
            )
            
        }
       
    }
    
    func test_map_throwsErronOn200HttpUrlResponseWithInvalidJson(){
        let invalidJSON = Data("invalid json".utf8)

             XCTAssertThrowsError(
                
                 try FeedItemsMapper.map(invalidJSON, HTTPURLResponse(statusCode: 200))
             
             )
    }
    
    func test_map_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() throws{
        let json = makeItemsJSON([])
        let items = try FeedItemsMapper.map(json, HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(items, [])

       
        
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() throws {

        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "http://a-url.com")!)
        
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "http://another-url.com")!)
        
        let json = makeItemsJSON([item1.json,item2.json])

        let items = try FeedItemsMapper.map(json, HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(items, [])
        
    }
    // MARK: - Helpers
    
    fileprivate func makeItem(id:UUID,description: String? = nil,location:String? = nil,imageURL:URL) -> (model:FeedImage,json:[String:Any]) {
        
        let item = FeedImage(id: id, description: description, location: location, imageURL: imageURL)
        
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }
        

        return (item,json)
        
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    
}


private extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
