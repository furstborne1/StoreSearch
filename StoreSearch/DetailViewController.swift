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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailView.layer.cornerRadius = 7
        detailView.layer.masksToBounds = true
        buyBtn.layer.cornerRadius = 5
        buyBtn.layer.masksToBounds = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    

    @IBAction func closeButon(_ sender: Any) {
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
