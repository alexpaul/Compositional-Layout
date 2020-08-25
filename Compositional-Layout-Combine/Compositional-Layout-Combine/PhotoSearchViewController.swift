//
//  ViewController.swift
//  Compositional-Layout-Combine
//
//  Created by Alex Paul on 8/25/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import Combine // asynchronous programming framework introduced in iOS 13

import Kingfisher

class PhotoSearchViewController: UIViewController {
  
  enum SectionKind: Int, CaseIterable {
    case main
  }
  
  // declare collection view
  private var collectionView: UICollectionView!
  
  // declare data source
  typealias DataSource = UICollectionViewDiffableDataSource<SectionKind, Photo>
  private var dataSource: DataSource!
  
  // declare a search controller
  private var searchController: UISearchController!
  
  // declare a serchText property that will be a `Publisher`
  // that emits changes from the searchBar on the search controller
  // in order to make any property a `Publisher` you need to append
  // the `@Published` property wrapper
  // to subscribe to the searchText's `Publisher` a $ needs to be prefixed
  // to searchText => $searchText
  @Published private var searchText = ""
  
  // store subscriptions
  private var subscriptions: Set<AnyCancellable> = []
  
  // property observer
//  var searchText {
//    didSet {
//      // changes
//    }
//  }

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "Photo Search"
    configureCollectionView()
    configureDataSource()
    configureSearchController()
    
    // subscribe to the searchText `Publisher`
    $searchText
      .debounce(for: .seconds(1.0), scheduler: RunLoop.main)
      .removeDuplicates()
      .sink { [weak self] (text) in // .assign
        self?.searchPhotos(for: text)
        // call the api client for the photo search queue
      }
      .store(in: &subscriptions)
  }
  
  private func searchPhotos(for query: String) {
    // searchPhotos is a `Publisher`
    APIClient().searchPhotos(for: query)
      .sink(receiveCompletion: { (completion) in
        print(completion)
      }) { [weak self] (photos) in
        self?.updateSnapshot(with: photos)
      }
      .store(in: &subscriptions)
  }
  
  private func updateSnapshot(with photos: [Photo]) {
    var snapshot = dataSource.snapshot()
    snapshot.deleteAllItems()
    snapshot.appendSections([.main])
    snapshot.appendItems(photos)
    dataSource.apply(snapshot, animatingDifferences: false)
  }
  
  private func configureSearchController() {
    searchController = UISearchController(searchResultsController: nil)
    navigationItem.searchController = searchController
    searchController.searchResultsUpdater = self // delegate
    searchController.searchBar.autocapitalizationType = .none
    searchController.obscuresBackgroundDuringPresentation = false
  }
  
  private func configureCollectionView() {
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
    collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.reuseIdentifier)
    collectionView.backgroundColor = .systemBackground
    collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(collectionView)
  }
  
  private func createLayout() -> UICollectionViewLayout {
    let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      // item
      let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      let itemSpacing: CGFloat = 5 // points
      item.contentInsets = NSDirectionalEdgeInsets(top: itemSpacing, leading: itemSpacing, bottom: itemSpacing, trailing: itemSpacing)
      
      // group (leadingGroup, trailingGroup, nestedGroup)
      let innerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.50), heightDimension: .fractionalHeight(1.0))
      let leadingGroup = NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, subitem: item, count: 2)
      let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, subitem: item, count: 3)
      let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(1000))
      let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: nestedGroupSize, subitems: [leadingGroup, trailingGroup])
      
      // section
      let section = NSCollectionLayoutSection(group: nestedGroup)
      
      return section
    }
    
    // layout
    return layout
  }
  
  private func configureDataSource() {
    // initializing the data source and
    // configuring the cell
    dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, photo) -> UICollectionViewCell? in
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.reuseIdentifier, for: indexPath) as? ImageCell else {
        fatalError("could not dequeue an ImageCell")
      }
      cell.imageView.kf.indicatorType = .activity
      cell.imageView.kf.setImage(with: URL(string: photo.webformatURL))
      cell.imageView.contentMode = .scaleAspectFill
      return cell
    })
    
    // setup initial snapshot
    var snapshot = dataSource.snapshot() // current snapshot
    snapshot.appendSections([.main])
    //snapshot.appendItems(Array(1...4))
    dataSource.apply(snapshot, animatingDifferences: false)
  }
}

extension PhotoSearchViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    guard let text = searchController.searchBar.text,
      !text.isEmpty else {
        return
    }
    searchText = text
    // upon asigning a new value to the searchText
    // the subscriber in the viewDidLoad will receive that value
  }
}
