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
        
       let samples = [199,201,300,400,500]
        
       try samples.enumerated().forEach { index,code in

            XCTAssertThrowsError(
               
                try FeedImageDataMapper.map(anyData(), HTTPURLResponse(statusCode: code))
            
            )
            
        }
       
    }
    
    func test_map_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData(){
        let emptyData = Data()

             XCTAssertThrowsError(
                
                 try FeedImageDataMapper.map(emptyData, HTTPURLResponse(statusCode: 200))
             
             )
    }
    
    
    func test_map_deliversReceivedNonEmptyDataOn200HTTPResponse() throws {

        let nonEmptyData = Data("non-empty data".utf8)
        let result = try FeedImageDataMapper.map(nonEmptyData, HTTPURLResponse(statusCode: 200))
        

        XCTAssertEqual(result, nonEmptyData)

        
        
    }
    
    
    
    
}


