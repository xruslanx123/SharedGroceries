//
//  Cell.swift
//  SharedGroceries
//
//  Created by Cambium Team on 22/06/2017.
//
//

import UIKit;

class Cell: UITableViewCell{
    
    @IBOutlet weak var label: UILabel!
    var index: Int!;
    var delegate: TableDelegate!;
    
    
    @IBAction func minusButtonAction(_ sender: Any) {
        delegate.removeAt(index: index);
    }
    
    
}
