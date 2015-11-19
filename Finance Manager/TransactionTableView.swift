//
//  TransactioonTableView.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 10.11.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import UIKit

class TransactionTableView: UITableView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    var emptyView: EmptyTransactionView = EmptyTransactionView()

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.emptyView = EmptyTransactionView(frame: self.frame)
        emptyView.hidden = true
        addSubview(emptyView)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        emptyView.frame = frame
    }
    func showEmptyView() {
        self.emptyView.hidden = false
        self.bringSubviewToFront(self.emptyView)
    }
    func hideEmptyView() {
        self.emptyView.hidden = true
        self.sendSubviewToBack(self.emptyView)
    }
    func configureEmptyView(sourceUnavaliable : Bool = false, _ destinationUnavaliable : Bool = false) {
        if (sourceUnavaliable && destinationUnavaliable) {
            self.emptyView.actionLabel.text = "Add souces and destinations first"
        }else if(sourceUnavaliable) {
            self.emptyView.actionLabel.text = "Add souce first"
        }else if (destinationUnavaliable){
            self.emptyView.actionLabel.text = "Add destination first"
        }
        self.emptyView.sourceButton.hidden = !sourceUnavaliable
        self.emptyView.destinationButton.hidden = !destinationUnavaliable
    }

}
