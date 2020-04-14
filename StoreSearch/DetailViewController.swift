//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by MARC on 4/13/20.
//  Copyright © 2020 MARC. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var buyBtn: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var largeImage: UIImageView!
    
    
    var searchResult: SearchResult!
    var downloadTask: URLSessionDownloadTask!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if searchResult != nil {
           configurePopupView(for: searchResult)
        }
        
        
        detailView.layer.cornerRadius = 7
        detailView.layer.masksToBounds = true
        buyBtn.layer.cornerRadius = 5
        buyBtn.layer.masksToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeButton(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)

    }
    
    deinit {
        downloadTask?.cancel()
    }
    
    func configurePopupView(for searchResult: SearchResult) {
        largeImage.image = UIImage(named: "Placeholder")
        largeImage.layer.cornerRadius = 5
        largeImage.layer.masksToBounds = true
        if let largeimageURL = URL(string: searchResult.artworkLarge) {
            downloadTask = largeImage.loadimage(url: largeimageURL)
        }
        name.text = searchResult.name
        type.text = "Type: \(searchResult.type)"
        genre.text = "Genre: \(searchResult.genre)"
        if searchResult.price == 0 {
            buyBtn.setTitle("Free", for: .normal)
        } else {
            buyBtn.setTitle("$\(searchResult.price)", for: .normal)
        }
        if searchResult.artist.isEmpty {
            artistName.text = "unknown"
        } else {
            artistName.text = String(format: "%@ (%@)", searchResult.artist, searchResult.type)
        }
    }
    
    @IBAction func openStore() {
        if let url = URL(string: searchResult.storeUrl) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    

    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
   

}

extension DetailViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
  
}

extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}
