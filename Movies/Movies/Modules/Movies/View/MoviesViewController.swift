//
//  MoviesViewController.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit
import Network

protocol MoviesView: AnyObject {
    func update()
    func didFailWithError(error: String)
}

final class MoviesViewController: UIViewController {
  
    //MARK: - Properties
    var presenter: MoviesPresenter!
    var currentSortType: SortType = .byDefault
    let itemsLeftToNextPage: Int = 3
    
    private lazy var galleryLayout: UICollectionViewCompositionalLayout = {
        let size = NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
                                          heightDimension: NSCollectionLayoutDimension.estimated(500))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize:  size,
                                                       subitem:     item,
                                                       count:       1)
        group.contentInsets = NSDirectionalEdgeInsets(top:        0,
                                                      leading:    20,
                                                      bottom:     0,
                                                      trailing:   20)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 20
        return UICollectionViewCompositionalLayout(section: section)
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: galleryLayout)
        return collectionView
    }()
    
    private lazy var sortButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(showActionSheet))
        button.tintColor = .black
        return button
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.showsBookmarkButton = false
        return searchBar
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        presenter.viewDidLoad()
    }
    
    //MARK: - Private methods
    private func initialSetup() {
        CollectionViewCell.registerNib(in: collectionView)
        setupNavigationBar()
        setupSearchBar()
        setupCollectionView()
        checkNetwork()
    }
    
    private func setupNavigationBar() {
        title = "Popular Movies"
        navigationItem.rightBarButtonItem = sortButton
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search..."
        searchBar.backgroundImage = UIImage()
        searchBar.showsCancelButton = true
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            searchBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func checkNetwork() {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "InternetConnectionMonitor")
        monitor.pathUpdateHandler = { pathUpdateHandler in
            if pathUpdateHandler.status == .unsatisfied {
                self.showAlert(title: "Error",
                               message: "You are offline. Please enable your Wi-Fi or connect using cellular data")
            }
        }
        monitor.start(queue: queue)
    }
    
    @objc private func showActionSheet() {
        let sortMenuController = UIAlertController(title: "Sort by",
                                                   message: nil,
                                                   preferredStyle: .actionSheet)
        let defaultAction = UIAlertAction(title: "popular",
                                          style: .default,
                                          handler: { SortBlock in
            self.currentSortType = .byDefault
            self.presenter.fetchMovies(sort: self.currentSortType)
            self.collectionView.setContentOffset(.zero, animated: false)
        })
        let votesAction = UIAlertAction(title: "most voted",
                                        style: .default,
                                        handler: { SortBlock in
            self.currentSortType = .byVotes
            self.presenter.fetchMovies(sort: self.currentSortType)
            self.collectionView.setContentOffset(.zero, animated: false)
        })
        let trendAction = UIAlertAction(title: "trending",
                                        style: .default,
                                        handler: { SortBlock in
            self.currentSortType = .byTrend
            self.presenter.fetchMovies(sort: self.currentSortType)
            self.collectionView.setContentOffset(.zero, animated: false)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        switch currentSortType {
        case .byDefault:
            defaultAction.setValue(true, forKey: "checked")
        case .byVotes:
            votesAction.setValue(true, forKey: "checked")
        case .byTrend:
            trendAction.setValue(true, forKey: "checked")
        }
        
        sortMenuController.addAction(defaultAction)
        sortMenuController.addAction(votesAction)
        sortMenuController.addAction(trendAction)
        sortMenuController.addAction(cancelAction)
        self.present(sortMenuController, animated: true, completion: nil)
    }
    
    private func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CollectionViewCell = .cell(in: self.collectionView, at: indexPath)
        let movie = presenter.getMovie(for: indexPath.item)
        cell.configure(movie: movie)
        cell.addShadow()
        return cell
    }
}

//MARK: - MoviesViewProtocol
extension MoviesViewController: MoviesView {
    func didFailWithError(error: String) {
        DispatchQueue.main.async {
            self.showAlert(title: "Error", message: error)
        }
    }
    
    func update() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

//MARK: - UICollectionViewDataSource
extension MoviesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getItemsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return cellForItem(at: indexPath)
    }
}

//MARK: - UICollectionViewDelegate
extension MoviesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == presenter.getItemsCount() - itemsLeftToNextPage {
            presenter.nextPage(sort: currentSortType)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.movieTapped(at: indexPath.item)
    }
}

//MARK: - UISearchBarDelegate
extension MoviesViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = .empty
        searchBar.endEditing(true)
        presenter.stopSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        collectionView.setContentOffset(.zero, animated: false)
        presenter.search(text: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

//MARK: - UIScrollViewDelegate
extension MoviesViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
}
