//
//  AddPetTableViewController.swift
//  PetPasport
//
//  Created by Сергей on 17.01.2022.
//  Copyright © 2022 Сергей. All rights reserved.
//

import UIKit

class AddPetTableViewController: UITableViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    // variables and constants
    let datePickerForPastEvents = UIDatePicker()
    let datePickerForFutureEvents = UIDatePicker()
    
    let breedPicker = UIPickerView()
    
    var currentPet: Pet?
    
    private var activeTextField = UITextField()
    private var dateRange =  [String]()
    private var imageIsChanged = false
    private let formatter = DateFormatter()
    private var petTypeBool = Bool()
    private var petGenderBool = Bool()
    private var petSterilizationBool = Bool()
    
    weak var delegate: AddPetTableViewControllerDelegate?
 
    
    // cells outlets
    @IBOutlet weak var contentViewImageCell: UIView!
    @IBOutlet weak var secondContentView: UIView!
    @IBOutlet weak var thirdContentView: UIView!
    @IBOutlet weak var fourthContentView: UIView!
    @IBOutlet weak var fifthContentView: UIView!
    @IBOutlet weak var sixthContentView: UIView!
    
    
    // ui elements outlets
    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var calendarLabel: UILabel!
    @IBOutlet weak var petTypeSelector: UISegmentedControl!
    @IBOutlet weak var petGenderSelector: UISegmentedControl!
    
    @IBOutlet weak var petType: UITextField!
    @IBOutlet weak var petName: UITextField!
    @IBOutlet weak var petBreed: UITextField!
    @IBOutlet weak var petAge: UITextField!
    
    @IBOutlet weak var petDateVaction: UITextField!
    @IBOutlet weak var petDateRevaction: UITextField!
    
    @IBOutlet weak var petDateParasite: UITextField!
    @IBOutlet weak var petDateReparasite: UITextField!
    
    @IBOutlet weak var petDateBugs: UITextField!
    @IBOutlet weak var petDateRebugs: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        petImage.layer.cornerRadius = 15
        petImage.clipsToBounds = true
        calendarButton.layer.cornerRadius = 5
        
        setupAllCell()
        setupDatePickers()
        setupEditScreen()

        //Метод для активации кнопки при вводе текста в поле имя
        petName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if petName.text != "" {
            delegate?.fillPetNameTextField()
        }
    }
    
    // MARK: - IB actions
    @IBAction func SelectPetType(_ sender: UISegmentedControl) {
        if petTypeSelector.selectedSegmentIndex == 0 {
            petTypeBool = true
            if !imageIsChanged { petImage.image = #imageLiteral(resourceName: "CatDefaultImage"); petImage.sizeToFit() }
            if petGenderSelector.selectedSegmentIndex == 0 { petType.text = "Кот"}
            else if petGenderSelector.selectedSegmentIndex == 1 { petType.text = "Кошка"}
        } else if petTypeSelector.selectedSegmentIndex == 1
        {
            petTypeBool = false
            if !imageIsChanged { petImage.image = #imageLiteral(resourceName: "DogDefaultImage"); petImage.sizeToFit() }
            if petGenderSelector.selectedSegmentIndex == 0 { petType.text = "Кобель"}
            else if petGenderSelector.selectedSegmentIndex == 1 { petType.text = "Собака"}
        }
    }
    
    @IBAction func SelectPetGender(_ sender: UISegmentedControl) {
        if petGenderSelector.selectedSegmentIndex == 0 {
            petGenderBool = true
            calendarLabel.isHidden = true
            calendarButton.isHidden = true
            if petTypeBool {petType.text = "Кот"}
            else {petType.text = "Кобель"}
        } else if petGenderSelector.selectedSegmentIndex == 1 {
            petGenderBool = false
            calendarLabel.isHidden = false
            calendarButton.isHidden = false
            if petTypeBool {petType.text = "Кошка"}
            else {petType.text = "Собака"}
        }
    }
    
    
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let addPhotoAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Камера", style: .default) { _ in
                self.chooseImagePicker(sourse: .camera)
            }
            let photo = UIAlertAction(title: "Фото", style: .default, handler: { _ in
                self.chooseImagePicker(sourse: .photoLibrary)
            })
            let cancel = UIAlertAction(title: "Отмена", style: .cancel)
            
            addPhotoAlert.addAction(camera)
            addPhotoAlert.addAction(photo)
            addPhotoAlert.addAction(cancel)
            present(addPhotoAlert, animated: true)
        }   else {
            view.endEditing(true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 0.0
        }
        return UITableView.automaticDimension
    }
    
    //  MARK: - Work with Date Picker
    private func setupDatePickers() {
        let LocaleID = Locale.preferredLanguages.first
        formatter.dateFormat = "dd.MM.yyyy"
        datePickerForPastEvents.locale = Locale(identifier: LocaleID!)
        datePickerForPastEvents.preferredDatePickerStyle = .wheels
        datePickerForPastEvents.datePickerMode = .date
        datePickerForPastEvents.addTarget(self, action: #selector(dateChangedInPastTF), for: .valueChanged)
        datePickerForPastEvents.maximumDate = Date()
        
        datePickerForFutureEvents.locale = Locale(identifier: LocaleID!)
        datePickerForFutureEvents.preferredDatePickerStyle = .wheels
        datePickerForFutureEvents.datePickerMode = .date
        datePickerForFutureEvents.addTarget(self, action: #selector(dateChangedInFutureTF), for: .valueChanged)
        datePickerForFutureEvents.minimumDate = Date()
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        doneButton.tintColor = .brown
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([space, doneButton], animated: true)
        petAge.inputAccessoryView = toolBar
        petDateVaction.inputAccessoryView = toolBar
        petDateRevaction.inputAccessoryView = toolBar
        petDateParasite.inputAccessoryView = toolBar
        petDateReparasite.inputAccessoryView = toolBar
        petDateRebugs.inputAccessoryView = toolBar
        petDateBugs.inputAccessoryView = toolBar
        
        petAge.delegate = self
        petDateBugs.delegate = self
        petDateVaction.delegate = self
        petDateParasite.delegate = self
        petDateBugs.delegate = self
        petDateRevaction.delegate = self
        petDateReparasite.delegate = self
        petDateRebugs.delegate = self
        
        petAge.inputView = datePickerForPastEvents
        petDateVaction.inputView = datePickerForPastEvents
        petDateParasite.inputView = datePickerForPastEvents
        petDateBugs.inputView = datePickerForPastEvents
        petDateRevaction.inputView = datePickerForFutureEvents
        petDateReparasite.inputView = datePickerForFutureEvents
        petDateRebugs.inputView = datePickerForFutureEvents
        
    }
    
    @objc func tapGestureDone () {
        self.view.endEditing(true)
        tableView.reloadData()
    }
    
    @objc func dateChangedInPastTF() {
        activeTextField.text = formatter.string(from: datePickerForPastEvents.date)
    }
    @objc func dateChangedInFutureTF() {
        activeTextField.text = formatter.string(from: datePickerForFutureEvents.date)
    }
    
    
    @objc func doneAction (){
        if (activeTextField == petAge) || (activeTextField == petDateBugs) || (activeTextField == petDateVaction) || (activeTextField == petDateParasite) {
            activeTextField.text = formatter.string(from: datePickerForPastEvents.date)
        } else {
            activeTextField.text = formatter.string(from: datePickerForFutureEvents.date)
        }
        self.view.endEditing(true)
        datePickerForPastEvents.date = Date()
        datePickerForFutureEvents.date = Date()
        tableView.reloadData()
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        setupDatePickers()
        if (activeTextField == petAge) || (activeTextField == petDateBugs) || (activeTextField == petDateVaction) || (activeTextField == petDateParasite) {
            activeTextField.text = formatter.string(from: datePickerForPastEvents.date)
        } else {
            activeTextField.text = formatter.string(from: datePickerForFutureEvents.date)
        }
    }
    
    //    MARK: - Function Save Pet
    func savePet() {
        var image : UIImage?
        if imageIsChanged {
            image = petImage.image
        } else {
            if petTypeSelector.selectedSegmentIndex == 0 {
                image = #imageLiteral(resourceName: "CatDefaultImage")
            } else {
                image = #imageLiteral(resourceName: "DogDefaultImage")
            }
        }
        let imageData = image?.pngData()
        let bday = formatter.date(from: petAge.text!)
        let dateVac = formatter.date(from: petDateVaction.text!)
        let datePar = formatter.date(from: petDateParasite.text!)
        let dateBugs = formatter.date(from: petDateBugs.text!)
        
        let dateRevac = formatter.date(from: petDateRevaction.text!)
        let dateRepar = formatter.date(from: petDateReparasite.text!)
        let dateRebugs = formatter.date(from: petDateRebugs.text!)
        
        
        let newPet = Pet(name: petName.text!,
                         type: petType.text,
                         breed: petBreed.text,
                         age: bday,
                         imageData: imageData,
                         vaction: dateVac,
                         revaction: dateRevac,
                         parasite: datePar,
                         reparasite: dateRepar,
                         bugs: dateBugs,
                         rebugs: dateRebugs
        )
        newPet.oestrusDates.append(objectsIn: dateRange)
        
        
        if dateVac != nil && dateRevac != nil {
            newPet.vactionPushIdentifier = "\(newPet.name)"+"vactionPush"
            
        }
        if datePar != nil && dateRepar != nil {
            newPet.parasitePushIdentifier = "\(newPet.name)"+"parasitePush"
        }
        if dateBugs != nil && dateRebugs != nil {
            newPet.bugsPushIdentifier = "\(newPet.name)"+"bugsPush"
        }
        
        if currentPet != nil {
            CalendarManager.shared.createEventVaction(pet: newPet, currentPet: currentPet)
            CalendarManager.shared.createEventParasite(pet: newPet, currentPet: currentPet)
            CalendarManager.shared.createEventBugs(pet: newPet, currentPet: currentPet)
            
            try! realm.write {
                currentPet?.name = newPet.name
                currentPet?.ageDate = newPet.ageDate
                currentPet?.breed = newPet.breed
                currentPet?.type = newPet.type
                currentPet?.imageData = newPet.imageData
                
                currentPet?.dateVaction = newPet.dateVaction
                currentPet?.dateRevaction = newPet.dateRevaction
                currentPet?.dateParasite = newPet.dateParasite
                currentPet?.dateReparasite = newPet.dateReparasite
                currentPet?.dateBugs = newPet.dateBugs
                currentPet?.dateRebugs = newPet.dateRebugs
                
                currentPet?.oestrusDates.removeAll()
                currentPet?.oestrusDates.append(objectsIn: dateRange)
            }
            
        } else {
            StorageManager.saveObject(newPet)
            dateRange = []
        
            CalendarManager.shared.createEventVaction(pet: newPet, currentPet: currentPet)
            CalendarManager.shared.createEventParasite(pet: newPet, currentPet: currentPet)
            CalendarManager.shared.createEventBugs(pet: newPet, currentPet: currentPet)
        }
    }
    
    // MARK: - segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setCalendar" {
            guard let vc = segue.destination as? CalendarViewController else {return}
            vc.calendarDelegate = self
            vc.dates = dateRange
        }
    }
    
    
    
    // MARK: - setup UI
    private func setupCell(view: UIView) {
        view.layer.masksToBounds = false
        view.clipsToBounds = false
        view.layer.cornerRadius = 15
        view.layer.shadowRadius = 5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 5, height: 5)
        view.layer.shadowOpacity = 0.3
    }
    
    private func setupAllCell() {
        setupCell(view: contentViewImageCell)
        setupCell(view: secondContentView)
        setupCell(view: thirdContentView)
        setupCell(view: fourthContentView)
        setupCell(view: fifthContentView)
        setupCell(view: sixthContentView)
    }
    
    func setupEditScreen() {
        if currentPet != nil {
            petName.text = currentPet?.name
            petImage.image = UIImage(data:(currentPet?.imageData)!)
            petImage.clipsToBounds = true
            petImage.contentMode = .scaleAspectFit
            imageIsChanged = true
            
            if currentPet?.ageDate != nil { petAge.text = formatter.string(from: (currentPet?.ageDate)!)}
            if currentPet?.breed != nil {petBreed.text = currentPet?.breed}
            if currentPet?.type != nil {
                petType.text = currentPet?.type
                switch currentPet?.type {
                case "Кошка":   petTypeSelector.selectedSegmentIndex = 0; petGenderSelector.selectedSegmentIndex = 1;
                case "Кот":     petTypeSelector.selectedSegmentIndex = 0; petGenderSelector.selectedSegmentIndex = 0;
                case "Кобель":     petTypeSelector.selectedSegmentIndex = 1; petGenderSelector.selectedSegmentIndex = 0;
                case "Собака":  petTypeSelector.selectedSegmentIndex = 1; petGenderSelector.selectedSegmentIndex = 1;
                default: break
                }
            }
            if currentPet?.dateVaction != nil { petDateVaction.text = formatter.string(from: (currentPet?.dateVaction)!)}
            if currentPet?.dateBugs != nil { petDateBugs.text = formatter.string(from: (currentPet?.dateBugs)!)}
            if currentPet?.dateParasite != nil { petDateParasite.text = formatter.string(from: (currentPet?.dateParasite)!)}
            if currentPet?.dateRevaction != nil {petDateRevaction.text = formatter.string(from: (currentPet?.dateRevaction)!)}
            if currentPet?.dateReparasite != nil {petDateReparasite.text = formatter.string(from: (currentPet?.dateReparasite)!)}
            if currentPet?.dateRebugs != nil {petDateRebugs.text = formatter.string(from: (currentPet?.dateRebugs)!)}
            if currentPet?.oestrusDates != nil { dateRange = Array(currentPet!.oestrusDates) }
        }
    }
    
    
}


// MARK: - Work with image
extension AddPetTableViewController: UIImagePickerControllerDelegate {
    
    func chooseImagePicker(sourse: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourse){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = sourse
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        petImage.image = info[.editedImage] as? UIImage
        petImage.contentMode = .scaleAspectFill
        petImage.clipsToBounds = true
        imageIsChanged = true
        dismiss(animated: true)
    }
}




//MARK: - Text Field Delegate
extension AddPetTableViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //скрываем клавиатуру при завершении ввода текста
        textField.resignFirstResponder()
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        activeTextField = textField
        return true
    }
    @objc private func textFieldChanged() {
        
        if petName.text?.isEmpty == false {
            delegate?.fillPetNameTextField()
        } else {
            delegate?.notFillPetNameTextField()
        }
    }
}

// MARK: - calendarProtocol
extension AddPetTableViewController: SaveCalendarDataDelegate {
    func saveData(dates: [String]) {
        self.dateRange = dates
    }
    
    
}



