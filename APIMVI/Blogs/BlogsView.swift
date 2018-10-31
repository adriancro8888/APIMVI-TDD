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
            case .fetching : render(fetching: state)
            case .failure  : render(failure: state)
            case .success  : render(success: state)
        }
    }
    
    private func render(fetching state: BlogState) {
        showLoading(show: true)
        showRetry(show: false)
    }
    
    private func render(failure state: BlogState) {
        showLoading(show: false)
        showRetry(show: true)
    }
    
    private func render(success state: BlogState) {
        if state.searchQuery == "" {
            showLoading(show: false)
            showBlogs(blogs: state.allBlogs)
        } else {
            showBlogs(blogs: state.filteredBlogs)
        }
    }
}
