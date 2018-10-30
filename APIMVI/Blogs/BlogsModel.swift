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

    let viewCreatedState = viewCreatedUseCase(lifecycle, networkManager)
    let refreshIntentionState = retryIntentionUseCase(intentions, networkManager)
    let searchIntentionState = searchIntentionUseCase(intentions, states)

    return Observable.merge(
      viewCreatedState,
      refreshIntentionState,
      searchIntentionState
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
    return intentions.getRetryIntention()
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

    return intentions.getSearchIntention()
      .withLatestFrom(states, resultSelector: { (query, state) in
        let filteredBlogs = state.allBlogs.filter { $0.title.contains(query) }
        return BlogState(allBlogs: state.allBlogs, filteredBlogs: filteredBlogs, searchQuery: query, status: .success)
      })
  }
}
