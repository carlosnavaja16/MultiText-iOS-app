//
//  ContactSelectionTableViewCell.swift
//  Multitext0.2
//
//  Created by Carlos Rossi on 7/10/20.
//  Copyright © 2020 Carlos Rossi. All rights reserved.
//

import UIKit

protocol customContactCellDelegate {
    func didPressCheck(index: Int)
}

class CustomContactCell: UITableViewCell {
    
    //Outlets
    @IBOutlet var title:UILabel!
    @IBOutlet var subtitle:UILabel!
    @IBOutlet var checkCircle:UIButton!
    
    var delegate:customContactCellDelegate?
    var checked:Bool = false
    var index:IndexPath?
    
    

    func isChecked() -> Bool{
        return checked
    }
    
    func check(){
        checked = true
        checkCircle.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        checkCircle.tintColor = .systemBlue
    }
    
    func uncheck(){
        checked = false
        checkCircle.setImage(UIImage(systemName: "circle"), for: .normal)
        checkCircle.tintColor = .label
    }
    
    @IBAction func circleCheckPressed(_ sender: Any) {
        
        if isChecked(){
            uncheck()
        }
        
        else{
            check()
        }
        
        delegate?.didPressCheck(index:(index!.row))
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionStyle = .none
        // Configure the view for the selected state
    }
    
}
