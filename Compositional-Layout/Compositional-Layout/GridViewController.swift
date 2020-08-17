//
//  ViewController.swift
//  Compositional-Layout
//
//  Created by Alex Paul on 8/17/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class GridViewController: UIViewController {
  
  // 3
  // setup enum to hold sections for collection view
  enum Section {
    case main
  }
  
  @IBOutlet weak var collectionView: UICollectionView! // default is flow layout
  
  // 4
  // declare our data source, which will be using diffable data source
  // review: both the SectionIdentifier and ItemIdentifier needs to be Hashable objects
  private var dataSource: UICollectionViewDiffableDataSource<Section, Int>!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureCollectionView()
    configureDataSource()
  }
  
  // 2
  private func configureCollectionView() {
    //collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
    
    // change the collectionView's layout
    // do this if using Storyboard to layout your collection view
    // since Storyboard does not support compositional layout
    collectionView.collectionViewLayout = createLayout() // from flow layout to compositional layout
    collectionView.backgroundColor = .systemBackground
    //collectionView.register(LabelCell.self, forCellWithReuseIdentifier: "labelCell")
  }
  
  // 1
  private func createLayout() -> UICollectionViewLayout {
    // 1
    // create and configure the item
    // item takes up 25% of the group's width
    // item takes up 100% of the group's height
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
    
    // 2
    // create and configure the group
    // group takes up 100% of the section's width
    // group's height is 25% of the section's width
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.25))
    //let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 4)
    group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
    
    // 3
    // configure the section
    let section = NSCollectionLayoutSection(group: group)
    
    // 4
    // configure the layout
    let layout = UICollectionViewCompositionalLayout(section: section)
    
    return layout
  }
  
  // 5
  // configure the data source
  private func configureDataSource() {
    // 1
    // setting up the data source
    dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "labelCell", for: indexPath) as? LabelCell else {
        fatalError("could not dequeue a LabelCell")
      }
      cell.textLabel.text = "\(item)"
      cell.backgroundColor = .systemOrange
      return cell
    })
    
    // 2
    // setting the initial snapshot
    var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
    snapshot.appendSections([.main]) // only one section
    snapshot.appendItems(Array(1...100))
    dataSource.apply(snapshot, animatingDifferences: false)
  }


}

