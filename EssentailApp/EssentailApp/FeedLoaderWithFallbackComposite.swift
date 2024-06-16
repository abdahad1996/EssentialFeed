//
//  FeedLoaderWithFallbackComposite.swift
//  EssentailApp
//
//  Created by macbook abdul on 16/06/2024.
//

import Foundation
import EssentialFeed

final public class FeedLoaderWithFallbackComposite:FeedLoader {
    
    private let primary:FeedLoader
    private let fallback:FeedLoader

    public init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func load(completion: @escaping (Result<[EssentialFeed.FeedImage], any Error>) -> Void) {
        primary.load { [weak self ] result in
            guard self != nil else {return}
            switch result {
            case .success:
                completion(result)
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}
