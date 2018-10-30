//
//  BlogsViewTests.swift
//  APIMVITests
//
//  Created by alice singh on 30/10/18.
//  Copyright © 2018 kite.work. All rights reserved.
//

import XCTest
import Foundation
import XCTest
import RxCocoa
import RxTest
import Cuckoo
@testable import APIMVI

class BlogsViewTests: XCTestCase {
    var view: MockSpyableBlogsView!

    override func setUp() {
        view = MockSpyableBlogsView().withEnabledSuperclassSpy()
    }

    func test_renderViewCreated() {
        // Setup
        let viewCreatedState = BlogState.initial()
    
        // Act
        view.render(state: viewCreatedState)
        
        // Assert
        verify(view).showLoading(show: true)
        verify(view).showRetry(show: false)
    }

    func test_renderFailure() {
        // Setup
        let failureState = BlogState.failure()
        
        // Act
        view.render(state: failureState)
        
        // Assert
        verify(view).showLoading(show: false)
        verify(view).showRetry(show: true)
    }
    
    func equal(to value: Blog) -> ParameterMatcher<Blog> {
        return ParameterMatcher(matchesFunction: { (blog) -> Bool in
            return blog.id == value.id
            && blog.userId == value.userId
            && blog.title == value.title
            && blog.body == value.body
        })
    }
    
    func test_renderSuccess() {
        // Setup
        let blogs = [
            Blog(userId: 1, id: 1, title: "Test", body: "Test body"),
            Blog(userId: 2, id: 2, title: "Test 2", body: "Test body 2")
        ]
        let successState = BlogState.success(blogs: blogs)
        
        // Act
        view.render(state: successState)
        
        // Assert
        verify(view).showLoading(show: false)
        verify(view).showBlogs(blogs: Cuckoo.equal(to: blogs))
    }
    
    func test_renderFilteredBlogs() {
        // Setup
        let blogs = [
            Blog(userId: 1, id: 1, title: "Test", body: "Test body"),
            Blog(userId: 2, id: 2, title: "Test 2", body: "Test body 2")
        ]
        let filteredState = BlogState(allBlogs: blogs, filteredBlogs: [], searchQuery: "A", status: .success)
        
        // Act
        view.render(state: filteredState)
        
        // Assert
        verify(view).showBlogs(blogs: Cuckoo.equal(to: []))
    }
}
