//
//  AddPetTableViewControllerDelegate.swift
//  PetPasport
//
//  Created by Сергей on 18.01.2022.
//  Copyright © 2022 Сергей. All rights reserved.
//

import Foundation

protocol AddPetTableViewControllerDelegate: class {
    
    func fillPetNameTextField()
    func notFillPetNameTextField()
    func saveButtonTapped()
}
