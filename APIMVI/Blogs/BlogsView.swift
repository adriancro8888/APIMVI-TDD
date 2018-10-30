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
        if (state.status == .failure) {
            showLoading(show: false)
            showRetry(show: true)
        } else if (state.status == .success) {
            showLoading(show: false)
            showBlogs(blogs: state.allBlogs)
        }
        else {
            showLoading(show: true)
            showRetry(show: false)
        }
    }
}


