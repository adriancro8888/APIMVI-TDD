//
//  BlogIntentions.swift
//  APIMVI
//
//  Created by Dinesh IIINC on 29/10/18.
//  Copyright © 2018 kite.work. All rights reserved.
//

import Foundation
import RxSwift

class BlogIntentions {

  private var retryIntention: Observable<Void>!
  private var searchIntention: Observable<String>!

  init(
    _ retryIntention: Observable<Void>,
    _ searchIntention: Observable<String>
  ) {
    self.retryIntention = retryIntention
    self.searchIntention = searchIntention
  }

  func retry() -> Observable<Void> {
    return retryIntention
  }

  func search() -> Observable<String> {
    return searchIntention
  }
}
