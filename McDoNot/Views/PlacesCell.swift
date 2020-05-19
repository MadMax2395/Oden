//
//  PlacesCell.swift
//  McDoNot
//
//  Created by Fabio Staiano on 21/02/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import Firebase
import UIKit
import wobbly


class PlacesCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
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

    @IBOutlet var smallTagCollection: UICollectionView!

    @IBOutlet var placeImage: UIImageView!
    @IBOutlet var placeTag: UILabel!
    @IBOutlet var placeLabel: UILabel!
    @IBOutlet var favouriteButton: UIButton!
    @IBOutlet var placeDistance: UILabel!

    var place: Place?

    var tagList: [Tag] = []

    override func awakeFromNib() {
        super.awakeFromNib()

        smallTagCollection.delegate = self
        smallTagCollection.dataSource = self
  
    }

    

    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int) {
        smallTagCollection.dataSource = self as UICollectionViewDataSource
        smallTagCollection.delegate = self as UICollectionViewDelegate
        smallTagCollection.tag = row
        smallTagCollection.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
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
        
        self.favouriteButton.imageView?.tintColor = buffer ? #colorLiteral(red: 1, green: 0.8039215686, blue: 0.5333333333, alpha: 1) : #colorLiteral(red: 0.918313086, green: 0.918313086, blue: 0.918313086, alpha: 1)
        
        
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
        } else {
            let alert = UIAlertController(title: "", message: NSLocalizedString("Are you sure do you want to remove this place from Favorites?", comment: "Alert showing up when a user wants to remove a place from favorites"), preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "No"), style: UIAlertAction.Style.default, handler: nil))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Yes"), style: UIAlertAction.Style.destructive, handler: { (UIAlertAction) in
                DBManager.shared.removePlaceFromFavourites(db: Firestore.firestore(), place: self.place!, userID: FirstLoginManager.shared.userID) { test in
                    if test {
                    }
                }
                for i in 0 ..< PlaceManager.shared.listFavouritePlaces.count {
                    if self.place!.ID == PlaceManager.shared.listFavouritePlaces[i].ID {
                        PlaceManager.shared.listFavouritePlaces.remove(at: i)
                        break
                    }
                }
                (self.parentViewController as! FavoritesController).placesTable.reloadData()
            }))

            self.parentViewController!.present(alert, animated: true, completion: nil)
        }
        
    }
}

@IBDesignable class PaddingLabel: UILabel {
    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 7.0
    @IBInspectable var rightInset: CGFloat = 7.0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    func intrinsicContentSize() -> CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        return intrinsicSuperViewContentSize
    }
    
}


public extension UIView{
    
    func hearbeatMod(){
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2, animations: {
                self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.16, relativeDuration: 0.2, animations: {
                self.transform = .identity
            })
            
            
        }, completion: nil)
    }
}
