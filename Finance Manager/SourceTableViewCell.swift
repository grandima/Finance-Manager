//
//  SourceTableViewCell.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 03.12.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import UIKit

class SourceTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
//MARK: - Configuration cell
extension SourceTableViewCell {

    func configureCell (name: String?, balance: Double?) {
        self.nameLabel.text = name
        if (balance != nil) {
            self.balanceLabel.text = String("Balance: \(balance!)")
        } else {
            self.balanceLabel.text = "Balance: 0"
        }
    }


}
