//
//  AddPetViewController.swift
//  PetPasport
//
//  Created by Сергей on 17.01.2022.
//  Copyright © 2022 Сергей. All rights reserved.
//

import UIKit
import EventKit

class AddPetViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    var currentPet: Pet?
    var tableViewController: AddPetTableViewController?

    private let eventStore = EKEventStore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        saveButton.isEnabled = false
        eventStore.requestAccess(to: EKEntityType.event) { granted, error in
            return
        }

    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableViewController = self.children[0] as? AddPetTableViewController
        tableViewController?.delegate = self
        tableViewController?.currentPet = currentPet
        tableViewController?.setupEditScreen()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func setupBackground() {
        let background = UIImage(named: "MainBG")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.alpha = 0.5
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    
 
    
}



extension AddPetViewController: AddPetTableViewControllerDelegate {
    
    func notFillPetNameTextField() {
        saveButton.isEnabled = false
    }
    
    
    func fillPetNameTextField() {
        saveButton.isEnabled = true
    }
    
    func saveButtonTapped() {
        
    }
    
    
}


