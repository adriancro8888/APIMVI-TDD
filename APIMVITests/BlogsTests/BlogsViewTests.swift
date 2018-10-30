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
    func test_renderViewCreated() {
        // Setup
        let viewCreatedState = BlogState.initial()
        let view = MockSpyableBlogsView().withEnabledSuperclassSpy()
    
        // Act
        view.render(state: viewCreatedState)
        
        // Assert
        verify(view).showLoading(show: true)
        verify(view).showRetry(show: false)
    }

    func test_renderFailure() {
        // Setup
        let failureState = BlogState.failure()
        let view = MockSpyableBlogsView().withEnabledSuperclassSpy()
        
        // Act
        view.render(state: failureState)
        
        // Assert
        verify(view).showLoading(show: false)
        verify(view).showRetry(show: true)
    }
}
