//
//  BlogsView.swift
//  APIMVI
//
//  Created by alice singh on 30/10/18.
//  Copyright © 2018 kite.work. All rights reserved.
//

import Foundation

protocol BlogsView {
    // Writes
    func showLoading(show: Bool)
    func showRetry(show: Bool)
    func showBlogs(blogs: [Blog])

    func render(state: BlogState)
}

extension BlogsView {
    func render(state: BlogState) {
        switch state.status {
            case .fetching : renderFetchingState(state)
            case .failure  : renderFailureState(state)
            case .success  : renderSuccessState(state)
        }
    }
    
    private func renderFetchingState(_ state: BlogState) {
        showLoading(show: true)
        showRetry(show: false)
    }
    
    private func renderFailureState(_ state: BlogState) {
        showLoading(show: false)
        showRetry(show: true)
    }
    
    private func renderSuccessState(_ state: BlogState) {
        if state.searchQuery == "" {
            showLoading(show: false)
            showBlogs(blogs: state.allBlogs)
        } else {
            showBlogs(blogs: state.filteredBlogs)
        }
    }
}
