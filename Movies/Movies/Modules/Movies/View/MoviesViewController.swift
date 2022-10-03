//
//  MoviesViewController.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit

protocol MoviesView: AnyObject {
    func update()
    func didFailWithError(error: String)
    func updateWithNetworkStatus(isAvailable: Bool)
}

final class MoviesViewController: UIViewController {
    
    //MARK: - Properties
    var presenter: MoviesPresenter!
    private var currentSortType: SortType = .byPopularity
    private let itemsLeftToNextPage: Int = 2
    private let estimatedCellHeight: CGFloat = 500
    private let padding: CGFloat = 20
    private let minSymbolsToSearch: Int = 2
    
    private lazy var layout: UICollectionViewCompositionalLayout = {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                          heightDimension: .estimated(estimatedCellHeight))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size,
                                                       subitem: item,
                                                       count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: .zero,
                                                      leading: padding,
                                                      bottom: .zero,
                                                      trailing: padding)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = padding
        return UICollectionViewCompositionalLayout(section: section)
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private lazy var sortButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(sortingAction))
        button.tintColor = .black
        return button
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        return searchBar
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        presenter.viewDidLoad()
    }
    
    //MARK: - Action
    @objc private func sortingAction() {
        let sortMenuController = UIAlertController(title: "Sort by",
                                                   message: nil,
                                                   preferredStyle: .actionSheet)
        let byPopularityAction = UIAlertAction(title: "popular",
                                               style: .default,
                                               handler: { SortBlock in
            self.scrollToTop()
            self.currentSortType = .byPopularity
            self.presenter.getSortedMovies(self.currentSortType)
        })
        let byVotesCountAction = UIAlertAction(title: "most voted",
                                               style: .default,
                                               handler: { SortBlock in
            self.scrollToTop()
            self.currentSortType = .byVotesCount
            self.presenter.getSortedMovies(self.currentSortType)
        })
        let byTrendAction = UIAlertAction(title: "trending",
                                          style: .default,
                                          handler: { SortBlock in
            self.scrollToTop()
            self.currentSortType = .byTrend
            self.presenter.getSortedMovies(self.currentSortType)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        switch currentSortType {
        case .byPopularity:
            byPopularityAction.setValue(true, forKey: "checked")
        case .byVotesCount:
            byVotesCountAction.setValue(true, forKey: "checked")
        case .byTrend:
            byTrendAction.setValue(true, forKey: "checked")
        }
        
        sortMenuController.addAction(byPopularityAction)
        sortMenuController.addAction(byVotesCountAction)
        sortMenuController.addAction(byTrendAction)
        sortMenuController.addAction(cancelAction)
        self.present(sortMenuController, animated: true, completion: nil)
    }
    
    //MARK: - Private methods
    private func initialSetup() {
        CollectionViewCell.registerNib(in: collectionView)
        setupNavigationBar()
        setupSearchBar()
        setupCollectionView()
    }
    
    private func setupNavigationBar() {
        title = "Popular Movies"
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
    
    private func scrollToTop() {
        collectionView.setContentOffset(.zero, animated: false)
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
    
    func updateWithNetworkStatus(isAvailable: Bool) {
        DispatchQueue.main.async {
            isAvailable ? self.navigationItem.setRightBarButton(self.sortButton, animated: false) : self.navigationItem.setRightBarButton(nil, animated: false)
        }
    }
}

//MARK: - UICollectionViewDataSource
extension MoviesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getItemsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CollectionViewCell = .cell(in: self.collectionView, at: indexPath)
        let movie = presenter.getMovie(for: indexPath.item)
        cell.configure(for: movie) {  [weak self] poster in
            guard let self = self else { return }
            self.presenter.modelIsReadyToSave(movie: movie, poster: poster)
        }
        return cell
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
        if searchText.count >= minSymbolsToSearch {
            scrollToTop()
            presenter.search(text: searchText)
        } else {
            presenter.stopSearch()
        }
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
