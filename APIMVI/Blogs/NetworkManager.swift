//
//  NetworkManager.swift
//  APIMVI
//
//  Created by Dinesh IIINC on 29/10/18.
//  Copyright © 2018 kite.work. All rights reserved.
//

import Foundation
import RxSwift
import RxAlamofire
import Alamofire

enum NetworkError: Error {
  case failure
}

class NetworkManager {
  func fetchBlogs() -> Observable<[Blog]> {
    return request(
        .get,
        "http://demo3027021.mockable.io/posts",
        parameters: nil,
        encoding: JSONEncoding.default,
        headers: nil
      )
      .validate()
      .responseData()
      .map({ (_, data) in
        return try JSONDecoder().decode([Blog].self, from: data)
      })
  }
}
