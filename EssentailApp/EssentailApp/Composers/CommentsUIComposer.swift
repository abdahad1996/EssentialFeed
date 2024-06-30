//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 27/05/2024.
//

import Foundation
import EssentialFeed
import EssentialFeediOS
import Combine

import UIKit

public final class CommentsUIComposer {
    private init(){}
    
    private typealias CommentsPresentationAdapter = LoadResourcePresentationAdapter<[ImageComment], CommentsViewAdapter>
    
    public static func commentsComposedWith(
        commentsLoader:@escaping () -> AnyPublisher<[ImageComment], Error>
    ) -> ListViewController{
      
        let loadResourcePresentationAdapter = CommentsPresentationAdapter(loader: commentsLoader)
        let commentsController = makeCommentsViewController(title: ImageCommentsPresenter.title)
        commentsController.onRefresh = loadResourcePresentationAdapter.loadResource
        
      
        loadResourcePresentationAdapter.presenter = LoadResourcePresenter(
            loadingView: WeakRefVirtualProxy(
                commentsController
            ),
            errorView: WeakRefVirtualProxy(
                commentsController
            ),
            resourceView: CommentsViewAdapter(
                controller: commentsController),
            mapper:{ImageCommentsPresenter.map($0)}
            )
        
        
        return commentsController
    }
    
    
    
    
    
    private static func makeCommentsViewController(title: String) -> ListViewController{
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.title = title
        return feedController
    }
    
    
    
}

final class CommentsViewAdapter: ResourceView {
    private weak var controller: ListViewController?

    init(controller: ListViewController) {
        self.controller = controller
    }

    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(viewModel.comments.map { viewModel in
            CellController(id: viewModel, ImageCommentCellController(model: viewModel))
        })
    }        }
