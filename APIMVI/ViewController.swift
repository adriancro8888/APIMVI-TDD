//
//  ViewController.swift
//  APIMVI
//
//  Created by Dinesh IIINC on 25/10/18.
//  Copyright © 2018 kite.work. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
  private let disposeBag = DisposeBag()

  private let lifecycleRelay = PublishRelay<MviLifecycle>()
  private let statesRelay = BehaviorRelay<BlogState?>(value: nil)
  private let networkManager = NetworkManager()

  // Intentions
  private lazy var retryIntention = retryButton.rx.tap.asObservable()
  private lazy var searchIntention = searchTextField.rx.text.orEmpty.asObservable()
  private lazy var intentions = BlogIntentions(retryIntention, searchIntention)

  // UI Components
  @IBOutlet private weak var retryButton: UIButton! {
    didSet {
      retryButton.isHidden = true
    }
  }
  @IBOutlet private weak var searchTextField: UITextField! {
    didSet {
      searchTextField.isHidden = true
    }
  }
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.isHidden = true
    }
  }
  @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView! {
    didSet {
      let scale: CGFloat = 3
      activityIndicatorView.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setup()
    lifecycleRelay.accept(.created)
  }

  func setup() {
    let statesObservable = statesRelay
      .filter { return $0 != nil }
      .map { $0! }

    bind(lifecycleRelay.asObservable(), networkManager, intentions, statesObservable)
  }

  private func bind(
    _ lifecycle: Observable<MviLifecycle>,
    _ networkManager: NetworkManager,
    _ intentions: BlogIntentions,
    _ states: Observable<BlogState>
  ) {
    BlogsModel
      .bind(lifecycle, networkManager, intentions, states.asObservable())
      .observeOn(MainScheduler.asyncInstance)
      .subscribe { (state) in
        if let state = state.element {
          self.statesRelay.accept(state)
          self.render(state: state)
        }
      }
      .disposed(by: disposeBag)
  }
}

extension ViewController: BlogsView {
  func showLoading(show: Bool) {
    if show {
      activityIndicatorView.startAnimating()
    } else {
      activityIndicatorView.stopAnimating()
    }
  }

  func showRetry(show: Bool) {
    retryButton.isHidden = !show
    tableView.isHidden = show
    searchTextField.isHidden = show
  }

  func showBlogs(blogs: [Blog]) {
    let blogs = Observable.of(
      blogs.sorted { $0.title.count < $1.title.count }
    )

    tableView.delegate = nil
    tableView.dataSource = nil

    blogs.bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) {
        (_, blog, cell) in
        cell.textLabel?.text = blog.title
        cell.detailTextLabel?.text = blog.body
      }.disposed(by: disposeBag)

    tableView.reloadData()
  }
}
