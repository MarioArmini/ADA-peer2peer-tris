//
//  PeerTableViewCell.swift
//  Peer2Peer Tris
//
//  Created by Mario Armini on 24/03/2020.
//  Copyright © 2020 Mario Armini. All rights reserved.
//

import UIKit

class PeerTableViewCell: UITableViewCell {
    @IBOutlet weak var peerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
