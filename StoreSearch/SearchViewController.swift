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
    
    
    var searchResults = [SearchResults]()
    var hasSearch = false
    
    struct TableView {
        struct cellIdentifiers {
            static let searchCell = "SearchResultCell"
            static let notFoundCell = "NothingFoundCell"
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
    }


}


//MARK:- THIS IS SEARCH BAR DELEGATE:
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchResults = []
        for i in 0...2 {
            let searchResult = SearchResults()
            searchResult.name = String(format: "Fake Result %d for ", i)
            searchResult.artistName = searchBar.text!
            searchResults.append(searchResult)
        }
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        hasSearch = true
        return .topAttached
    }
}


//MARK:- THIS IS FOR TABLEVIEW DELEGATE:
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearch {
            return 0
        } else if searchResults.count == 0 {
            return 1
        }
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = TableView.cellIdentifiers.searchCell
        let notFoundCellId = TableView.cellIdentifiers.notFoundCell
        if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: notFoundCellId, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SearchResultCell
            
            cell.nameLabel?.text = searchResults[indexPath.row].name
            cell.artistLabel?.text = searchResults[indexPath.row].artistName
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 {
            return nil
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

