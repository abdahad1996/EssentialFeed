//
//  HttpClient.swift
//  EssentialFeed
//
//  Created by Abdul Ahad on 23.12.23.
//

import Foundation

public enum HttpClientResult {
    case success(Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HttpClient{
    func get(from url:URL,completion:@escaping (HttpClientResult)->Void)
    
}
