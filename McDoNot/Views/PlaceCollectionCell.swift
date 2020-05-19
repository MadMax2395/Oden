//
//  PlaceCollectionCell.swift
//  McDoNot
//
//  Created by Roberto Scarpati on 26/02/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import UIKit
import Firebase

class PlaceCollectionCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet var smallTagCollection: UICollectionView!
    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var placeTag: UILabel!
    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var placeDistance: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    
    @IBOutlet var shitView: UIView!
    
    var place: Place?

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0

        for (_, value) in tagList.enumerated() {
            if value.availability == true {
                count += 1
            }
        }

        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = smallTagCollection.dequeueReusableCell(withReuseIdentifier: "SmallTagLabelsCell", for: indexPath) as! SmallTagLabelsCell

        cell.smallTagImage.image = UIImage(named: tagList[findNextAvailable(vector: &tagList, baseIndex: indexPath.row)].imageName)

        cell.smallTagImage.cornerRadius = 7

        cell.smallTagImage.clipsToBounds = true

        cell.smallTagImage.layer.masksToBounds = true

        return cell
    }

    var tagList: [Tag] = []

    override func awakeFromNib() {
        super.awakeFromNib()

        shitView.frame = frame

        smallTagCollection.delegate = self
        smallTagCollection.dataSource = self

        
        // Initialization code
    }
    
    func setupFavouriteButton() {
            if let myImage = UIImage(named: "Heart") {
                let tintableImage = myImage.withRenderingMode(.alwaysTemplate)
                favouriteButton.setImage(tintableImage, for: .normal)
            }
        
        favouriteButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 2, right: 0)
            
            var buffer = false

            for favPlace in PlaceManager.shared.listFavouritePlaces {
                if self.place?.ID == favPlace.ID {
                    buffer = true
                }
            }
            
            if buffer {
                self.favouriteButton.imageView?.tintColor = #colorLiteral(red: 1, green: 0.8039215686, blue: 0.5333333333, alpha: 1)
            } else {
                self.favouriteButton.imageView?.tintColor = #colorLiteral(red: 0.918313086, green: 0.918313086, blue: 0.918313086, alpha: 1)
            }
            
        }


    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int) {
        smallTagCollection.dataSource = self as! UICollectionViewDataSource
        smallTagCollection.delegate = self as! UICollectionViewDelegate
        smallTagCollection.tag = row
        smallTagCollection.reloadData()
    }

    @IBAction func favouriteButtonTapped(_ sender: Any) {
         if !(self.parentViewController is FavoritesController) {
            var buffer = false
            for favPlace in PlaceManager.shared.listFavouritePlaces {
                if place?.ID == favPlace.ID {
                    buffer = true
                }
            }
            if !buffer {
                favouriteButton.hearbeatMod()
                favouriteButton.imageView?.tintColor = #colorLiteral(red: 1, green: 0.8039215686, blue: 0.5333333333, alpha: 1)

                DBManager.shared.addPlaceToFavourites(db: Firestore.firestore(), place: place!, userID: FirstLoginManager.shared.userID) { test in
                    if test {
                        
                    }
                }
                PlaceManager.shared.listFavouritePlaces.append(self.place!)
            } else {
                favouriteButton.imageView?.tintColor = #colorLiteral(red: 0.918313086, green: 0.918313086, blue: 0.918313086, alpha: 1)
                DBManager.shared.removePlaceFromFavourites(db: Firestore.firestore(), place: place!, userID: FirstLoginManager.shared.userID) { test in
                    if test {
                        
                    }
                }
                for i in 0 ..< PlaceManager.shared.listFavouritePlaces.count {
                    if self.place!.ID == PlaceManager.shared.listFavouritePlaces[i].ID {
                        PlaceManager.shared.listFavouritePlaces.remove(at: i)
                        break
                    }
                }
                
            }
            (self.parentViewController as! ExploreController).placeCollection.reloadData()
        }
    }
 
}
