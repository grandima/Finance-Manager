//
//  TransactionTableViewCell.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 06.11.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell (source source: String, date:NSDate, category:String, amount:NSNumber) {
        self.sourceLabel.text = source

        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd.MM 'at' HH:mm"
        self.dateLabel.text = formatter.stringFromDate(date)

        self.destinationLabel.text = category
        self.amountLabel.text = amount.stringValue + " UAH"
    }

}
