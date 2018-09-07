//
//  RoundedShadowImageView.swift
//  CoreMLApp
//
//  Created by Robert Wais on 9/5/18.
//  Copyright © 2018 Robert Wais. All rights reserved.
//

import UIKit

class RoundedShadowImageView: UIImageView {

    override func awakeFromNib() {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = 15
        
    }

}
