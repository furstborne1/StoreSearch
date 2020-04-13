//
//  SearchResultcell.swift
//  StoreSearch
//
//  Created by MARC on 4/10/20.
//  Copyright © 2020 MARC. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
    @IBOutlet weak var placeHolderImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    var downloadTask: URLSessionDownloadTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9803921569, alpha: 1)
        selectedBackgroundView = selectedView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
    }
    
    func configure(for result: SearchResult) {
        placeHolderImage.image = UIImage(named: "Placeholder")
        placeHolderImage.layer.cornerRadius = 4
        placeHolderImage.layer.masksToBounds = true
        if let smallUrl = URL(string: result.artworkSmall) {
            downloadTask = placeHolderImage.loadimage(url: smallUrl)
        }
        nameLabel?.text = result.name
        if result.artist.isEmpty {
            artistLabel?.text = "Unknown"
        } else {
            artistLabel?.text = String(format: "%@ (%@)", result.artist, result.type)
        }
    }
}
