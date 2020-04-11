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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9803921569, alpha: 1)
        selectedBackgroundView = selectedView
    }
}
