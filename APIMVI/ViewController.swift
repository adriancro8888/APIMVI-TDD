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
  private var disposeBag = DisposeBag()

  private var lifecycleRelay: PublishRelay<MviLifecycle>!
  private var statesRelay: BehaviorRelay<BlogState>!

  private var networkManager: NetworkManager!
  private var intentions: BlogIntentions!

  // UI Components
  @IBOutlet private weak var retryButton: UIButton!
  @IBOutlet private weak var searchTextField: UITextField!
  @IBOutlet private weak var tableView: UITableView!
  lazy var activityView: UIActivityIndicatorView = {
    var activityView = UIActivityIndicatorView()
    activityView.style = .gray
    activityView.transform = CGAffineTransform(scaleX: 2, y: 2)
    return activityView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setUpIndicatorView()

    setup()

    lifecycleRelay.accept(.created)
  }

  private func setup() {
    lifecycleRelay = PublishRelay()
    statesRelay = BehaviorRelay(value: BlogState.initial())

    networkManager = NetworkManager()
    intentions = BlogIntentions(
      retryButton.rx.tap.asObservable(),
      searchTextField.rx.text.orEmpty.asObservable()
    )

    bind(lifecycleRelay.asObservable(), networkManager, intentions, statesRelay.asObservable())
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

  func setUpIndicatorView() {
    view.addSubview(activityView)
    activityView.center = view.center
  }
}

extension ViewController: BlogsView {
  func showLoading(show: Bool) {
    if show { activityView.startAnimating() }
    else { activityView.stopAnimating() }
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
