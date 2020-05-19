//
//  CollectionViewCell.swift
//  McDoNot
//
//  Created by Fabio Staiano on 20/02/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import UIKit

class TagLabelsCell: UICollectionViewCell {

    let tagWidths: [CGFloat] = [100, 100, 150, 100, 110, 190, 170]
    
    func getDamnButtonWidth() {
        btnTag.frame.size = CGSize(width: tagWidths[getIndex()], height: 50)
    }

    @IBOutlet var btnTag: UIButton!
    var isOn = false

    @IBAction func tagTapped(_ sender: Any) {
        if isOn {
            isOn = false
            btnTag.backgroundColor = #colorLiteral(red: 0.8901180029, green: 0.8902462125, blue: 0.8900898695, alpha: 1)
            btnTag.setTitleColor(.lightGray, for: .normal)
            btnTag.setImage(btnTag.imageView?.image?.withTintColor(.lightGray), for: .normal)
        } else {
            isOn = true
            btnTag.backgroundColor = #colorLiteral(red: 0.6774679422, green: 0.7304675579, blue: 0.9886408448, alpha: 1)
            btnTag.setTitleColor(.white, for: .normal)
            btnTag.setImage(btnTag.imageView?.image?.withTintColor(.white), for: .normal)
        }
        if let parentController = self.parentViewController as? ExploreController {
            parentController.tagBools[getIndex()] = isOn
        } else if let parentController = self.parentViewController as? NearbyController {
            parentController.tagBools[getIndex()] = isOn
        }
    }

    func getIndex() -> Int {
        if let myViewController = self.parentViewController as? ExploreController {
            let indexPath: IndexPath = myViewController.tagCollection.indexPath(for: self)!
            return indexPath.row
        }
        if let myOtherController = self.parentViewController as? NearbyController {
            let indexPath: IndexPath = myOtherController.tagCollection.indexPath(for: self)!
            return indexPath.row
        }
        return -1
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.btnTag.adjustsImageWhenHighlighted = false
    }


}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
