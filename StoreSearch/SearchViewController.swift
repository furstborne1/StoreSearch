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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
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
        let cellID = "SearchCell"
        var cell: UITableViewCell! =  tableView.dequeueReusableCell(withIdentifier: cellID)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        }
        if searchResults.count == 0 {
            cell.textLabel?.text = "(Nothing Found)"
            cell.detailTextLabel?.text = ""
        } else {
            cell.textLabel?.text = searchResults[indexPath.row].name
            cell.detailTextLabel?.text = searchResults[indexPath.row].artistName
        }
        return cell
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

