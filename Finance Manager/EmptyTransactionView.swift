//
//  TransactionTableViewPlaceholder.swift
//  Finance Manager
//
//  Created by Dima Medynsky on 09.11.15.
//  Copyright © 2015 Dima Medynsky. All rights reserved.
//

import UIKit

@IBDesignable class EmptyTransactionView: UIView {

    @IBOutlet weak var actionLabel: UILabel!

    @IBOutlet weak var sourceButton: UIButton!
    @IBOutlet weak var destinationButton: UIButton!
    @IBOutlet weak var view: UIView!
    let nibName = "EmptyTransactionView"
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.xibSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()

    }

    func configurePlaceholder(actionTitle : String?, source isSource: Bool = true, destination isDestination: Bool = true) {
        self.actionLabel.text = actionTitle
        self.sourceButton.hidden = isSource
        self.destinationButton.hidden = isDestination
    }
    func xibSetup() {
        view = loadViewFromNib()
        // use bounds not frame or it'll be offset
        view.frame = self.frame
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }

    func loadViewFromNib() -> UIView {

        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView

        return view
    }
}


//protocol UIViewLoading {}
//extension UIView : UIViewLoading {}
//
//extension UIViewLoading where Self : UIView {
//
//    // note that this method returns an instance of type `Self`, rather than UIView
//    static func loadFromNib() -> Self {
//        let nibName = "\(self)".characters.split{$0 == "."}.map(String.init).last!
//        let nib = UINib(nibName: nibName, bundle: nil)
//        return nib.instantiateWithOwner(self, options: nil).first as! Self
//    }
//    
//}
