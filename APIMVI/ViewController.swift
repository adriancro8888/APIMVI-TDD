//
//  ViewController.swift
//  APIMVI
//
//  Created by Dinesh IIINC on 25/10/18.
//  Copyright © 2018 kite.work. All rights reserved.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa
import RxAlamofire
import Alamofire

class ViewController: UIViewController {

  let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()

    getRequest().subscribe(onNext: { (arr) in
      print("Array Count")
      print(arr.count)
    }, onError: {
      (error) in
      print("Error")
      print(error.localizedDescription)
    }).disposed(by: disposeBag)
  }

  func getRequest() -> Observable<[Blog]> {

    let urlString = "http://demo3027021.mockable.io/posts"

        return
          request(
            .get,
            urlString,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: nil
          )
          .validate()
          .responseData()
          .map({ (_, data) -> [Blog] in
            return try JSONDecoder().decode([Blog].self, from: data)
          })
  }
}
