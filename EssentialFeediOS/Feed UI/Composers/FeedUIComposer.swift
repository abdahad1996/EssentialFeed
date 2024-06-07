//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by macbook abdul on 27/05/2024.
//

import Foundation
import EssentialFeed
import UIKit

public final class FeedUIComposer {
    private init(){}
    
    
    public static func feedComposedWith(
        loader: FeedLoader,
        imageLoader:FeedImageLoader
    ) -> FeedViewController{
        
        let feedLoaderPresentationAdapter = FeedLoaderPresentationAdapter(loader: MainDispatchQueueDecorator(decoratee:loader))
        let feedController = FeedViewController.makeWith(delegate: feedLoaderPresentationAdapter, title: FeedPresenter.title)
        

        feedLoaderPresentationAdapter.presenter = FeedPresenter(feedLoadingView: WeakRefVirtualProxy(feedController), feedView: FeedViewAdapter(feedViewController: feedController, imageLoader: MainDispatchQueueDecorator(decoratee:imageLoader)))

      return feedController
    }
    
}

private class MainDispatchQueueDecorator<T> {
    
    let decoratee:T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
            guard Thread.isMainThread else {
                return DispatchQueue.main.async(execute: completion)
            }

            completion()
        }
    
}
extension MainDispatchQueueDecorator:FeedImageLoader where T == FeedImageLoader {
    func loadImageData(from url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> any FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
    
    
    
}

extension MainDispatchQueueDecorator:FeedLoader where T == FeedLoader {
    func load(completion: @escaping (Result<[FeedImage],Error>) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}
private extension FeedViewController {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
class FeedLoaderPresentationAdapter:FeedViewControllerDelegate {
    
    var presenter:FeedPresenter?
    let loader:FeedLoader
    
    init( loader: FeedLoader) {
       
        self.loader = loader
    }
    
    func didRequestFeedRefresh(){
        presenter?.didStartLoadingFeed()
        
        loader.load {[weak self] result in
            switch result {
            case .success(let feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
            
        }
    }
}
class WeakRefVirtualProxy<T:AnyObject>{
    
    weak var object:T?
    
    init(_ object: T?) {
        self.object = object
    }
}
extension WeakRefVirtualProxy:FeedLoadingView where T:FeedLoadingView{
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
    
}



class FeedViewAdapter:FeedView{
    
    weak var feedViewController: FeedViewController?
    let imageLoader:  FeedImageLoader
    
    init(feedViewController:FeedViewController,imageLoader: FeedImageLoader) {
        self.imageLoader = imageLoader
        self.feedViewController = feedViewController
    }
    
    func display(_ viewModel: FeedViewModel) {
        
        feedViewController?.tableModel = viewModel.feed.map({
            feed in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: feed, imageLoader: imageLoader)
            let view = FeedImageCellController(delegate: adapter)
            let presenter = FeedImagePresenter(view: WeakRefVirtualProxy(view), transformer: UIImage.init)
            adapter.presenter = presenter
            return view
        })
    }
    
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ model: FeedImageViewModel<UIImage>) {
        object?.display(model)
    }
}
class FeedImageDataLoaderPresentationAdapter<View:FeedImageView,Image>:FeedImageCellControllerDelegate where View.Image == Image {
    private var task:FeedImageDataLoaderTask?
    let imageLoader:FeedImageLoader
    let model:FeedImage
    var presenter:FeedImagePresenter<View,Image>?
    
    init(model:FeedImage,imageLoader: FeedImageLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage(){
        presenter?.didStartLoadingImageData(for: model)
        let model = self.model
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }
        
    }
    
    func didCancelImageRequest() {
            task?.cancel()
        }
}
