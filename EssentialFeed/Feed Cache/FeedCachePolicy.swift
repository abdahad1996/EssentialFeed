//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by macbook abdul on 15/04/2024.
//

import Foundation

 final class CachePolicy {
    
    private static let calendar = Calendar(identifier: .gregorian)
    
    private init(){
        
    }

    private static var maxCacheAgeInDays:Int {
        return 7
    }

   static func validateCache(_ timeStamp:Date,against date:Date) -> Bool{
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timeStamp) else {
            return false
        }
      

        return date < maxCacheAge
    }
}
