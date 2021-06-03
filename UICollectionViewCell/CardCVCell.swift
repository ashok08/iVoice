//
//  CardCVCell.swift
//  iNotion
//
//  Created by Ashok on 20/05/21.
//

import UIKit

class CardCVCell: UICollectionViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var images = [UIImage(named: "picture2"),UIImage(named: "picture1"),UIImage(named: "picture3")]
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
       
    }
    func setUI(index:IndexPath){
        self.imageView.image = self.images[index.row]
    let indexs = Array(
        index.section == 0 ? speakers : audiences
    )[index.row]
      self.titleLbl.text = allUsers[indexs]
        print(allUsers[indexs])
    }
}
