//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by macbook abdul on 10/06/2024.
//

import Foundation
public struct ImageCommentViewModel {
    public let feed: [ImageComment]
}
final public class ImageCommentsPresenter {
    
    
    public static var title: String {
            NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                tableName: "ImageComments",
                bundle: Bundle(for: Self.self),
                comment: "Title for the image comments view")
        }
    
//    public static func map(_ imageComment:[ImageComment]) -> ImageCommentViewModel{
//        ImageCommentViewModel.init(feed: imageComment)
//    }
}
