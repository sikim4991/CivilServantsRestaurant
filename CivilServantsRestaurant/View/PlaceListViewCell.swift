//
//  ListViewCell.swift
//  CivilServantsRestaurant
//
//  Created by SIKim on 5/7/24.
//

import UIKit

// '목록'에서의 Cell Custom View
class PlaceListViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var roadAddressLabel: UILabel!
    @IBOutlet weak var othersButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
