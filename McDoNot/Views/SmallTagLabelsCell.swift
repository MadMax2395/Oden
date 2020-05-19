//
//  CollectionViewCell.swift
//  McDoNot
//
//  Created by Fabio Staiano on 20/02/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import UIKit

class SmallTagLabelsCell: UICollectionViewCell {
    @IBOutlet var smallTagImage: UIImageView!

    override func prepareForReuse() {
        smallTagImage.image = nil
    }
}
