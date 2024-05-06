//
//  HttpClient.swift
//  EssentialFeed
//
//  Created by Abdul Ahad on 23.12.23.
//

import Foundation

public protocol HTTPClient{
    typealias Result = Swift.Result<(Data,HTTPURLResponse),Error>
    func get(from url:URL,completion:@escaping (Result)->Void)
    
}
