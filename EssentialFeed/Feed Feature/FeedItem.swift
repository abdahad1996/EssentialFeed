//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Abdul Ahad on 17.12.23.
//

import Foundation

public struct FeedItem:Equatable {
    let Id: UUID
    let description: String?
    let location: String?
    let imageURL: String
}
