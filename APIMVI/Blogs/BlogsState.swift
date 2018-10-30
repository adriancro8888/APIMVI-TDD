//
//  BlogsState.swift
//  APIMVI
//
//  Created by Dinesh IIINC on 26/10/18.
//  Copyright © 2018 kite.work. All rights reserved.
//

import Foundation

struct Blog: Decodable, Equatable {
  var userId: Int
  var id: Int
  var title: String
  var body: String
}

enum APIStatus {
  case fetching
  case success
  case failure
}

struct BlogState: Equatable {
  var allBlogs: [Blog]
  var filteredBlogs: [Blog]
  var searchQuery: String
  var status: APIStatus
}

extension BlogState {

  static func initial() -> BlogState {
    return BlogState(allBlogs: [], filteredBlogs: [], searchQuery: "", status: .fetching)
  }

  static func failure() -> BlogState {
    return BlogState(allBlogs: [], filteredBlogs: [], searchQuery: "", status: .failure)
  }

  static func success(blogs: [Blog]) -> BlogState {
    return BlogState(allBlogs: blogs, filteredBlogs: [], searchQuery: "", status: .success)
  }

//  static func filtered(_ filteredBlogs: [Blog], query: String) -> BlogState {
//    return BlogState(allBlogs: blogs, filteredBlogs: filteredBlogs, searchQuery: query, status: .success)
//  }
}
