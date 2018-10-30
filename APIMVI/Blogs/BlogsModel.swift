//
//  BlogsModel.swift
//  APIMVI
//
//  Created by Dinesh IIINC on 26/10/18.
//  Copyright © 2018 kite.work. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxAlamofire
import Alamofire

class BlogsModel {
  static func bind(
    _ lifecycle: Observable<MviLifecycle>,
    _ networkManager: NetworkManager,
    _ intentions: BlogIntentions,
    _ states: Observable<BlogState>
  ) -> Observable<BlogState> {

    let viewCreatedStates = viewCreatedUseCase(lifecycle, networkManager)
    let refreshIntentionStates = retryIntentionUseCase(intentions, networkManager)
    let searchIntentionStates = searchIntentionUseCase(intentions, states)

    return Observable.merge(
      viewCreatedStates,
      refreshIntentionStates,
      searchIntentionStates
    )
  }

  private static func viewCreatedUseCase(
    _ lifecycle: Observable<MviLifecycle>,
    _ networkManager: NetworkManager
  ) -> Observable<BlogState> {
    return lifecycle
      .filter{ $0 == .created }
      .flatMapLatest({ _ -> Observable<BlogState> in
        let loadingState = Observable.just(BlogState.initial())
        let networkAPIState = networkManager.fetchBlogs()
          .map({ blogs in
            return BlogState.success(blogs: blogs)
          })
          .catchError({ error in
            print(error.localizedDescription)
            return Observable.just(BlogState.failure())
          })

        return Observable.concat(loadingState, networkAPIState)
      })
  }

  private static func retryIntentionUseCase(
    _ intentions: BlogIntentions,
    _ networkManager: NetworkManager
  ) -> Observable<BlogState> {
    return intentions.retry()
      .flatMapLatest({ (_) -> Observable<BlogState> in
        let loadingState = Observable.just(BlogState.initial())
        let networkAPIState = networkManager.fetchBlogs()
          .map({ blogs in
            return BlogState.success(blogs: blogs)
          })
          .catchError({ error in
            print(error.localizedDescription)
            return Observable.just(BlogState.failure())
          })

        return Observable.concat(loadingState, networkAPIState)
      })
  }

  private static func searchIntentionUseCase(
    _ intentions: BlogIntentions,
    _ states: Observable<BlogState>
  ) -> Observable<BlogState> {
    return intentions.search()
      .withLatestFrom(states, resultSelector: { (query, state) in
        // Filtered (allBlogs: [Blog]) from previous state and return new state with the filtered blogs.
        let filteredBlogs = state.allBlogs.filter { $0.title.contains(query) }
        return BlogState(allBlogs: state.allBlogs, filteredBlogs: filteredBlogs, searchQuery: query, status: .success)
      })
  }
}
