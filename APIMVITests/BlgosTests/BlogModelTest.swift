//
//  BlogModelTest.swift
//  APIMVITests
//
//  Created by Dinesh IIINC on 25/10/18.
//  Copyright © 2018 kite.work. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa
import RxTest
import Cuckoo
@testable import APIMVI

class BlogModelTest: XCTestCase {

  var disposeBag: DisposeBag!
  var observer: TestableObserver<BlogState>!

  var lifecycle: PublishRelay<MviLifecycle>!
  var states: PublishRelay<BlogState>!
  var mockNetworkManager: MockNetworkManager!

  var retryIntention: PublishRelay<Void>!
  var searchIntention: PublishRelay<String>!
  var intentions: BlogIntentions!

  override func setUp() {
    disposeBag = DisposeBag()
    observer = TestScheduler(initialClock: 0)
      .createObserver(BlogState.self)

    lifecycle = PublishRelay()
    states = PublishRelay()
    mockNetworkManager = MockNetworkManager()

    retryIntention = PublishRelay()
    searchIntention = PublishRelay()
    intentions = BlogIntentions(retryIntention.asObservable(), searchIntention.asObservable())

    BlogsModel
      .bind(lifecycle.asObservable(), mockNetworkManager, intentions, states.asObservable())
      .do(onNext: { state in self.states.accept(state) })
      .subscribe(observer)
      .disposed(by: disposeBag)
  }

  func testEmitsErrorState_when_viewCreated_andAPICallFails() {

    // Setup
    stub(mockNetworkManager) { (stub) in
      when(stub.fetchBlogs())
        .thenReturn(Observable.error(NetworkError.failure))
    }

    // Act
    lifecycle.accept(.created)

    // Assert
    let expectedStates = [next(0, BlogState.initial()), next(0, BlogState.failure())]
    XCTAssertEqual(observer.events, expectedStates)
  }

  func testEmitsSuccessState_when_viewCreated_andAPICallReturnsBlogs() {
    // Setup
    let blogs = [
      Blog(userId: 1, id: 1, title: "Test", body: "Test body"),
      Blog(userId: 2, id: 2, title: "Test 2", body: "Test body 2")
    ]

    let expectedResult: Observable<[Blog]> = Observable.of(blogs)

    stub(mockNetworkManager) { (stub) in
      when(stub.fetchBlogs())
      .thenReturn(expectedResult)
    }

    // Act
    lifecycle.accept(.created)

    // Assert
    let expectedStates = [next(0, BlogState.initial()), next(0, BlogState.success(blogs: blogs))]
    XCTAssertEqual(observer.events, expectedStates)
  }

  func testEmitsErrorState_when_retryIntention_andAPICallFails() {

    // Setup
    stub(mockNetworkManager) { (stub) in
      when(stub.fetchBlogs())
        .thenReturn(Observable.error(NetworkError.failure))
    }

    // Act
    lifecycle.accept(.created)
    retryIntention.accept(())

    // Assert
    let expectedStates = [
      next(0, BlogState.initial()),
      next(0, BlogState.failure()),
      next(0, BlogState.initial()),
      next(0, BlogState.failure())
    ]
    XCTAssertEqual(observer.events, expectedStates)
  }

  func testEmitsSuccessState_when_retryIntention_andAPICallReturnsBlogs() {

    // Setup
    let blogs = [
      Blog(userId: 1, id: 1, title: "Test", body: "Test body"),
      Blog(userId: 2, id: 2, title: "Test 2", body: "Test body 2")
    ]

    let expectedResult: Observable<[Blog]> = Observable.of(blogs)

    stub(mockNetworkManager) { (stub) in
      when(stub.fetchBlogs())
        .thenReturn(Observable.error(NetworkError.failure))
        .thenReturn(expectedResult)
    }

    // Act
    lifecycle.accept(.created)
    retryIntention.accept(())

    // Assert
    let expectedStates = [
      next(0, BlogState.initial()),
      next(0, BlogState.failure()),
      next(0, BlogState.initial()),
      next(0, BlogState.success(blogs: blogs))
    ]
    XCTAssertEqual(observer.events, expectedStates)
  }

  func testEmitsFilteredState_when_searchIntention_andNoResults() {

    // Setup
    let blogs = [
      Blog(userId: 1, id: 1, title: "Test", body: "Test body"),
      Blog(userId: 2, id: 2, title: "Test 2", body: "Test body 2")
    ]

    let expectedResult: Observable<[Blog]> = Observable.of(blogs)

    stub(mockNetworkManager) { (stub) in
      when(stub.fetchBlogs())
        .thenReturn(expectedResult)
    }

    // Act
    lifecycle.accept(.created)
    searchIntention.accept("A")
    searchIntention.accept("Aa")
    searchIntention.accept("Aaa")

    // Assert
    let expectedStates = [
      next(0, BlogState.initial()),
      next(0, BlogState.success(blogs: blogs)),
      next(0, BlogState(allBlogs: blogs, filteredBlogs: [], searchQuery: "A", status: .success)),
      next(0, BlogState(allBlogs: blogs, filteredBlogs: [], searchQuery: "Aa", status: .success)),
      next(0, BlogState(allBlogs: blogs, filteredBlogs: [], searchQuery: "Aaa", status: .success))
    ]
    XCTAssertEqual(observer.events, expectedStates)
  }

  func testEmitsFilteredState_when_searchIntention_andFilteredBlogs() {

    // Setup
    let blogs = [
      Blog(userId: 1, id: 1, title: "Test", body: "Test body"),
      Blog(userId: 2, id: 2, title: "Test 2", body: "Test body 2")
    ]

    let filteredBlogs = [
      Blog(userId: 2, id: 2, title: "Test 2", body: "Test body 2")
    ]

    let expectedResult: Observable<[Blog]> = Observable.of(blogs)

    stub(mockNetworkManager) { (stub) in
      when(stub.fetchBlogs())
        .thenReturn(expectedResult)
    }

    // Act
    lifecycle.accept(.created)
    searchIntention.accept("T")
    searchIntention.accept("Te")
    searchIntention.accept("Test 2")

    // Assert
    let expectedStates = [
      next(0, BlogState.initial()),
      next(0, BlogState.success(blogs: blogs)),
      next(0, BlogState(allBlogs: blogs, filteredBlogs: blogs, searchQuery: "T", status: .success)),
      next(0, BlogState(allBlogs: blogs, filteredBlogs: blogs, searchQuery: "Te", status: .success)),
      next(0, BlogState(allBlogs: blogs, filteredBlogs: filteredBlogs, searchQuery: "Test 2", status: .success))
    ]
    XCTAssertEqual(observer.events, expectedStates)
  }
}
