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
    @IBOutlet weak var segmented: UISegmentedControl!
    
    
    var searchResults = [SearchResult]()
    var hasSearch = false
    var isLoading = false
    var dataTask: URLSessionDataTask?
    
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
        setupSegmentedControll()
       
    }
    
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        performSearch()
        print("segmented control index: \(segmented.selectedSegmentIndex)")
    }
    
    func setupSegmentedControll() {
        let segmentColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9803921569, alpha: 1)
        let selectedtextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray ]
        let normalAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        segmented.selectedSegmentTintColor = segmentColor
        segmented.setTitleTextAttributes(normalAttributes, for: .normal)
        segmented.setTitleTextAttributes(selectedtextAttributes, for: .selected)
        segmented.setTitleTextAttributes(selectedtextAttributes, for: .highlighted)
    }
    
    
    func setNibs() {
        let nibCell = UINib(nibName: TableView.cellIdentifiers.searchCell, bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: TableView.cellIdentifiers.searchCell)
        tableView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
        
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
    func performSearch() {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            dataTask?.cancel()
            hasSearch = true
            isLoading = true
            tableView.reloadData()
            searchResults = []
            let url = itunesURL(for: searchBar.text!, for: segmented.selectedSegmentIndex)
            let session = URLSession.shared
            print("URL \(url)")
            dataTask = session.dataTask(with: url) { (data, response, error) in
                if let error = error as NSError? {
                    if error.code == -999 {
                        return
                    }
                    print("error in urlsesson \(error.localizedDescription)")
                } else if let httpResquest = response as? HTTPURLResponse {
                    if httpResquest.statusCode == 200 {
                        if let data = data {
                            self.searchResults = self.parse(data: data)
                            self.searchResults.sort{ $0.name.localizedStandardCompare($1.name) == .orderedAscending}
                            DispatchQueue.main.async {
                                self.isLoading = false
                                self.tableView.reloadData()
                            }
                            return
                        }
                    }
                } else {
                    print("faillure")
                }
                DispatchQueue.main.async {
                    self.hasSearch = false
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.showNetWorkError()
                }
            }
            dataTask?.resume()
        }
    }
    
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        hasSearch = true
        return .topAttached
    }
    
    //MARK:- this method create a url from a string
    func itunesURL(for searchText: String, for category: Int) -> URL {
        let kind: String
        switch category {
        case 1: kind = "musicTrack"
        case 2: kind = "software"
        case 3: kind = "ebook"
        default : kind = ""
            
        }
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = "https://itunes.apple.com/search?" +
        "term=\(encodedText)&limit=200&entity=\(kind)"
        let url = URL(string: urlString)
        return url!
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
            cell.configure(for: searchResult)
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
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    
    
}

