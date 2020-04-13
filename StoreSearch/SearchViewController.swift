//
//  ViewController.swift
//  StoreSearch
//
//  Created by MARC on 4/10/20.
//  Copyright © 2020 MARC. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    //MARK:- THIS ALL THE OUTLETS:
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    var searchResults = [SearchResult]()
    var hasSearch = false
    var isLoading = false
    
    struct TableView {
        struct cellIdentifiers {
            static let searchCell = "SearchResultCell"
            static let notFoundCell = "NothingFoundCell"
            static let itemCount = "ObjectCount"
            static let loadingIndicator = "LoadingCell"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.becomeFirstResponder()
        setNibs()
       
    }
    
    
    func setNibs() {
        let nibCell = UINib(nibName: TableView.cellIdentifiers.searchCell, bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: TableView.cellIdentifiers.searchCell)
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        let notFoundNib = UINib(nibName: TableView.cellIdentifiers.notFoundCell, bundle: nil)
        tableView.register(notFoundNib, forCellReuseIdentifier: TableView.cellIdentifiers.notFoundCell)
        
        let itemLoadedNib = UINib(nibName: TableView.cellIdentifiers.itemCount, bundle: nil)
        tableView.register(itemLoadedNib, forCellReuseIdentifier: TableView.cellIdentifiers.itemCount)
        
        let loadingNib = UINib(nibName: TableView.cellIdentifiers.loadingIndicator, bundle: nil)
        tableView.register(loadingNib, forCellReuseIdentifier: TableView.cellIdentifiers.loadingIndicator)
    }


}


//MARK:- THIS IS SEARCH BAR DELEGATE:
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            hasSearch = true
            isLoading = true
            tableView.reloadData()
            searchResults = []
            let queue = DispatchQueue.global()
            let url = itunesURL(for: searchBar.text!)
            print("URL \(url)")
            queue.async {
                if let data = self.performStoreRequest(with: url) {
                    self.searchResults = self.parse(data: data)
                     self.searchResults.sort{ $0.name.localizedStandardCompare($1.name) == .orderedAscending }
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.tableView.reloadData()
                    }
                    return
                }
            }
        }
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        hasSearch = true
        return .topAttached
    }
    
    //MARK:- this method create a url from a string
    func itunesURL(for searchText: String) -> URL {
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@", encodedText)
        let url = URL(string: urlString)
        return url!
    }
    
    //MARK:- this method put url response to data
    func performStoreRequest(with url: URL) -> Data? {
        do {
            return try Data(contentsOf: url)
        } catch {
            print("error \(error.localizedDescription)")
            showNetWorkError()
            return nil
            
        }
    }
    
    func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultsArray.self, from: data)
            return result.results
        } catch {
            print("JSON parsing error \(error.localizedDescription)")
            return []
        }
    }
    
    func showNetWorkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing the iTunes Store." + " Please try again.", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}


//MARK:- THIS IS FOR TABLEVIEW DELEGATE:
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        } else if !hasSearch {
            return 0
        } else if searchResults.count == 0 {
            return 1
        }
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = TableView.cellIdentifiers.searchCell
        let notFoundCellId = TableView.cellIdentifiers.notFoundCell
        let loadingCell = TableView.cellIdentifiers.loadingIndicator
        ///let searchCount = TableView.cellIdentifiers.itemCount
        
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }
        if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: notFoundCellId, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel?.text = searchResult.name
            if searchResult.artist.isEmpty {
                cell.artistLabel?.text = "Unknown"
            } else {
                cell.artistLabel?.text = String(format: "%@ (%@)", searchResult.artist, searchResult.type)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading {
            return nil
        }
        return indexPath
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

