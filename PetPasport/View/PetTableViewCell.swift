//
//  CustomTableViewCell.swift
//  PetPasport
//
//  Created by Сергей on 25.06.2020.
//  Copyright © 2020 Сергей. All rights reserved.
//

import UIKit

class PetTableViewCell: UITableViewCell {


    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet weak var petType: UILabel!
    @IBOutlet weak var petName: UILabel!
    @IBOutlet weak var petBreed: UILabel!
    @IBOutlet weak var petFullAge: UILabel!
    @IBOutlet weak var petFullMounth: UILabel!
    @IBOutlet weak var petStatus: UILabel!
    @IBOutlet weak var PetIndicator: UIProgressView!
    @IBOutlet weak var petLastTime: UILabel!
    @IBOutlet weak var petDesctiptionBugs: UILabel!
    @IBOutlet weak var petDescriptionParasite: UILabel!
    @IBOutlet weak var containerView: UIView!
    

    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.PetIndicator.layer.cornerRadius = 10
        self.PetIndicator.clipsToBounds = true
        self.containerView.backgroundColor = .white
        self.containerView.layer.opacity = 0.8
        self.containerView.layer.shadowRadius = 5
        self.containerView.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.containerView.layer.shadowOpacity = 1
        self.containerView.layer.shadowColor = UIColor.gray.cgColor
        self.containerView.layer.masksToBounds = false
        self.containerView.clipsToBounds = false
        self.containerView.layer.cornerRadius = 20
    }
    
}

