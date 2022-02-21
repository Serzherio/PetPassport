//
//  ShowPetTableViewController.swift
//  PetPasport
//
//  Created by Сергей on 01.08.2020.
//  Copyright © 2020 Сергей. All rights reserved.
//

import UIKit

class ShowPetTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    let formatter = DateFormatter()
    var currentPet: Pet?
    let dateNow = Date()
    
    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet weak var CatDogLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var petFullAgeLabel: UILabel!
    
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var buttonVaction: UIButton!
    @IBOutlet weak var vactionTF: UITextField!
    @IBOutlet weak var progressOfVaction: UIProgressView!
    @IBOutlet weak var vactionLastDays: UILabel!
    
    @IBOutlet weak var parasiteButton: UIButton!
    @IBOutlet weak var progressOfParasite: UIProgressView!
    @IBOutlet weak var parasiteTF: UITextField!
    @IBOutlet weak var parasiteLastDays: UILabel!
    
    @IBOutlet weak var bugsButton: UIButton!
    @IBOutlet weak var bugsTF: UITextField!
    @IBOutlet weak var progressOfBugs: UIProgressView!
    @IBOutlet weak var bugsLastDays: UILabel!
    
    
    @IBOutlet weak var cell1View: UIView!
    @IBOutlet weak var cell2View: UIView!
    @IBOutlet weak var cell3View: UIView!
    @IBOutlet weak var cell4View: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAllCell()
        showPet()
        setUpBackgroundImage()
        
        buttonVaction.layer.cornerRadius = 10
        buttonVaction.layer.borderWidth = 1
        buttonVaction.layer.borderColor = UIColor.brown.cgColor
        
        parasiteButton.layer.cornerRadius = 10
        parasiteButton.layer.borderWidth = 1
        parasiteButton.layer.borderColor = UIColor.brown.cgColor
        
        bugsButton.layer.cornerRadius = 10
        bugsButton.layer.borderWidth = 1
        bugsButton.layer.borderColor = UIColor.brown.cgColor
        
        calendarButton.layer.cornerRadius = 10
        calendarButton.layer.borderWidth = 1
        calendarButton.layer.borderColor = UIColor.brown.cgColor
        
        petImage.layer.cornerRadius = 20
        petImage.clipsToBounds = true
        petImage.layer.masksToBounds = true

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
            setupCell(view: cell1View)
            setupCell(view: cell2View)
            setupCell(view: cell3View)
            setupCell(view: cell4View)
        }
    
    func setUpBackgroundImage() {
        let image = UIImage(named: "MainBG")
        let imageView = UIImageView(image: image)
        tableView.backgroundView = imageView
        imageView.alpha = 0.5
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .singleLine
        
        progressOfVaction.layer.cornerRadius = 10
        progressOfVaction.clipsToBounds = true
        progressOfParasite.layer.cornerRadius = 10
        progressOfParasite.clipsToBounds = true
        progressOfBugs.layer.cornerRadius = 10
        progressOfBugs.clipsToBounds = true
    }
    
 // MARK: - IBActions
    @IBAction func pushButtonVaction(_ sender: Any) {
        self.performSegue(withIdentifier: "vaction", sender: self)
    }
    @IBAction func pushButtonParasite(_ sender: Any) {
        self.performSegue(withIdentifier: "parasite", sender: self)
    }
    @IBAction func pushButtonBugs(_ sender: Any) {
        self.performSegue(withIdentifier: "bugs", sender: self)
    }
    @IBAction func pushButtonCalendar(_ sender: Any) {
        self.performSegue(withIdentifier: "showCalendar", sender: self)
    }
    
    
    
    // MARK: - segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "vaction" {
            let VC = segue.destination as? InfoViewController
            VC?.filePath = ["vaction", "html", "Vaction"]
        }
        if segue.identifier == "parasite" {
            let VC = segue.destination as? InfoViewController
            VC?.filePath = ["parasites", "html", "Parasites"]
        }
        if segue.identifier == "bugs" {
            let VC = segue.destination as? InfoViewController
            VC?.filePath = ["bugs", "html", "Bugs"]
        }
        if segue.identifier == "showCalendar" {
            let VC = segue.destination as? CalendarViewController
            for each in currentPet!.oestrusDates
            {VC?.dates.append(each)}
        }
        else {return}
    }
    
    
    // MARK: - support logic
    func calculateInterval(date: Date) -> Double {
        let timeInterval = date.timeIntervalSince(dateNow)
        return timeInterval
    }
    
    func showPet() {
        fillAgeTF()
        
        CatDogLabel.text = currentPet?.type
        nameLabel.text = currentPet?.name
        breedLabel.text =  currentPet?.breed
        petImage.image = UIImage(data:(currentPet?.imageData)!)
        petImage.layer.cornerRadius = 20
        
        if currentPet?.type == "Кот" {calendarButton.isHidden = true}
        if currentPet?.type == "Кобель" {calendarButton.isHidden = true}
        
        //Заполнение и расчет вакцинации
        if currentPet?.dateVaction != nil, currentPet?.dateRevaction != nil {
            let timeStartToNow = abs(Float((currentPet?.calculateTimeInterval(fromDate: (currentPet?.dateVaction)!))!))
            let timeLast = Float((currentPet?.calculateTimeInterval(fromDate: (currentPet?.dateRevaction)!))!)
            let timeFull = Float(timeLast+timeStartToNow)
            progressOfVaction.progress = timeLast
            progressOfVaction.setProgress((timeLast/timeFull), animated: true)
            
            let lastDay = (lroundf(timeLast/60/60/24))
            if lastDay <= 0 {
                vactionTF.text = "Питомец не вакцинирован"
                vactionTF.textColor = .red
                vactionLastDays.text = "Питомцу необходима ревакцинация"
                vactionLastDays.textColor = .red
            }
            if lastDay > 0 {
                if lastDay < 30 {
                    vactionLastDays.text = "Дней до ревакцинации: \(lastDay)"
                    vactionTF.text = "Вакцинация заканчивается"
                    vactionTF.textColor = .red
                } else {
                    vactionLastDays.text = "Дней до ревакцинации: \(lastDay)"
                    vactionTF.text = "Питомец вакцинирован"
                    vactionTF.textColor = .black
                }
            }
        } else {
            progressOfVaction.setProgress(0/1, animated: false)
            progressOfVaction.trackTintColor = .systemGray
            progressOfVaction.layer.opacity = 0.5
            vactionLastDays.text = "Данные не заполнены"
            vactionLastDays.textColor = .systemGray
            vactionTF.text = "Заполните даты вакцинации"
            vactionTF.textColor = .systemGray
        }
        
        if breedLabel.text == "" {
            breedLabel.text = "Нет информации"
            breedLabel.textColor = .systemGray
        }
        
        
        //Заполнение и расчет глистов
        if currentPet?.dateParasite != nil && currentPet?.dateReparasite != nil {
            let timeStartToNow = abs(Float((currentPet?.calculateTimeInterval(fromDate: (currentPet?.dateParasite)!))!))
            let timeLast = Float((currentPet?.calculateTimeInterval(fromDate: (currentPet?.dateReparasite)!))!)
            let timeFull = Float(timeLast+timeStartToNow)
            progressOfParasite.progress = timeLast
            progressOfParasite.setProgress((timeLast/timeFull), animated: true)
            let lastDay = (lroundf(timeLast/60/60/24))
            if lastDay <= 0 {
                parasiteTF.text = "Не обработан от паразитов"
                parasiteTF.textColor = .red
                parasiteLastDays.text = "Питомцу необходима обработка"
                parasiteLastDays.textColor = .red
            }
            if lastDay > 0 {
                if lastDay < 30 {
                    parasiteLastDays.text = "Дней до обработки: \(lastDay)"
                    parasiteTF.text = "Обработка от паразитов заканчивается"
                    parasiteTF.textColor = .red
                } else {
                    parasiteLastDays.text = "Дней до обработки: \(lastDay)"
                    parasiteTF.text = "Питомец обработан"
                    parasiteTF.textColor = .black
                }
            }
        } else {
            progressOfParasite.setProgress(0/1, animated: false)
            progressOfParasite.trackTintColor = .systemGray
            progressOfParasite.layer.opacity = 0.5
            parasiteLastDays.text = "Данные не заполнены"
            parasiteLastDays.textColor = .systemGray
            parasiteTF.text = "Заполните даты обработки"
            parasiteTF.textColor = .systemGray
        }
        
        //Заполнение и расчет блох
        if currentPet?.dateBugs != nil && currentPet?.dateRebugs != nil {
            let timeStartToNow = abs(Float((currentPet?.calculateTimeInterval(fromDate: (currentPet?.dateBugs)!))!))
            let timeLast = Float((currentPet?.calculateTimeInterval(fromDate: (currentPet?.dateRebugs)!))!)
            let timeFull = Float(timeLast+timeStartToNow)
            progressOfBugs.progress = timeLast
            progressOfBugs.setProgress((timeLast/timeFull), animated: true)
            let lastDay = (lroundf(timeLast/60/60/24))

            if lastDay <= 0 {
                bugsTF.text = "Не обработан от насекомых"
                bugsTF.textColor = .red
                bugsLastDays.text = "Питомцу необходима обработка"
                bugsLastDays.textColor = .red
            }
            if lastDay > 0 {
                if lastDay < 30 {
                    bugsLastDays.text = "Дней до обработки: \(lastDay)"
                    bugsTF.text = "Обработка от насекомых заканчивается"
                    bugsTF.textColor = .red
                } else {
                    bugsLastDays.text = "Дней до обработки: \(lastDay)"
                    bugsTF.text = "Питомец обработан от насекомых"
                    bugsTF.textColor = .black
                }
            }
        } else {
            progressOfBugs.setProgress(0/1, animated: false)
            progressOfBugs.trackTintColor = .systemGray
            progressOfBugs.layer.opacity = 0.5
            bugsLastDays.text = "Данные не заполнены"
            bugsLastDays.textColor = .systemGray
            bugsTF.text = "Заполните даты обработки"
            bugsTF.textColor = .systemGray
        }
    }
    
    
    
    
    func fillAgeTF() {
        if currentPet?.ageDate != nil {
            let petAge = currentPet!.calculatePetsAge(bday: currentPet!.ageDate!)
            let correctFill = currentPet!.correctFillTheLabelOfMainVC(date: petAge)
            petFullAgeLabel.text = "\(petAge[0]) \(correctFill[0]) \(petAge[1]) \(correctFill[1])"
            if petAge[0] == 0 {petFullAgeLabel.text = "\(petAge[1]) \(correctFill[1])"}
            if petAge[1] == 0 {petFullAgeLabel.text = "\(petAge[0]) \(correctFill[0])"}
        } else {
            petFullAgeLabel.text = "Нет информации"
            petFullAgeLabel.textColor = .systemGray
        }
    }
    
    
}
