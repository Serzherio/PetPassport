//
//  PetsModel.swift
//  PetPasport
//
//  Created by Сергей on 27.06.2020.
//  Copyright © 2020 Сергей. All rights reserved.
//

import RealmSwift
import UIKit

let dateNow = Date()

class Pet: Object {
    @objc dynamic var type: String?
    @objc dynamic var name = ""
    @objc dynamic var breed: String?
    @objc dynamic var ageDate: Date?
    @objc dynamic var imageData: Data?
    
    @objc dynamic var dateVaction: Date?
    @objc dynamic var dateRevaction : Date?
    @objc dynamic var vactionPushIdentifier : String?
    
    @objc dynamic var dateParasite: Date?
    @objc dynamic var dateReparasite : Date?
    @objc dynamic var parasitePushIdentifier : String?
    
    @objc dynamic var dateBugs: Date?
    @objc dynamic var dateRebugs  : Date?
    @objc dynamic var bugsPushIdentifier : String?
    
    
    var oestrusDates = List<String>()
    
    
    
    
    convenience init (name: String, type: String?, breed: String?, age: Date?, imageData: Data?,
                      vaction: Date?, revaction: Date?,
                      parasite: Date?, reparasite: Date?,
                      bugs: Date?, rebugs: Date?)
    
    {
        self.init()
        self.name = name
        self.type = type
        self.breed = breed
        self.ageDate = age
        self.imageData = imageData
        self.dateVaction = vaction
        self.dateRevaction = revaction
        self.dateParasite = parasite
        self.dateReparasite = reparasite
        self.dateBugs = bugs
        self.dateRebugs = rebugs
    }
    
    func configureCell(pet: Pet, cell: PetTableViewCell) -> PetTableViewCell {
        if pet.name != nil {
            cell.petBreed?.text = pet.breed
            cell.petName?.text = pet.name
            cell.petType?.text = pet.type
            cell.petImage?.image = UIImage(data: pet.imageData!)
            cell.petImage?.layer.cornerRadius = 75
            cell.petImage?.clipsToBounds = true
            
            // Fill pet's age by calculating it with day of born from TF
            if pet.ageDate != nil {
                let petAge = pet.calculatePetsAge(bday: pet.ageDate!)
                let correctFill = pet.correctFillTheLabelOfMainVC(date: petAge)
                cell.petFullAge.text = " \(petAge[0]) \(correctFill[0])"
                cell.petFullMounth.text = "\(petAge[1]) \(correctFill[1])"
                if petAge[0] == 0 { cell.petFullAge.isHidden = true }
                if petAge[1] == 0 { cell.petFullMounth.isHidden = true }
            } else {
                cell.petFullAge.isHidden = true; cell.petFullMounth.isHidden = true
            }
            
            if pet.dateVaction != nil && pet.dateRevaction != nil {
                let timeStartToNow = abs(pet.calculateTimeInterval(fromDate: pet.dateVaction!))
                let timeLast = pet.calculateTimeInterval(fromDate: pet.dateRevaction!)
                let timeFull = timeLast + timeStartToNow
                // Setup progress Bar for pet
                cell.PetIndicator.progress = Float(timeLast)
                cell.PetIndicator.setProgress(Float(timeLast/timeFull), animated: true)
                let lastDays = (lroundf(Float(timeLast/60/60/24)))
                if lastDays <= 0 {
                    cell.petStatus.text = "Питомец не вакцинирован"
                    cell.petStatus.textColor = .red
                    cell.petLastTime.text = "Питомцу необходима ревакцинация"
                    cell.petLastTime.textColor = .red
                }
                if lastDays > 0 {
                    if lastDays < 30 {
                        cell.petLastTime.text = "Дней до ревакцинации: \(lastDays)"
                        cell.petStatus.text = "Вакцинация заканчивается"
                        cell.petStatus.textColor = .red
                    } else {
                        cell.petLastTime.text = "Дней до ревакцинации: \(lastDays)"
                        cell.petStatus.text = "Питомец вакцинирован"
                        cell.petStatus.textColor = .black
                    }
                }
            } else {
                cell.PetIndicator.isHidden = true
                cell.petStatus.isHidden = true
                cell.petLastTime.text = "Заполните данные о вакцинации"
                cell.petLastTime.textColor = .systemGray
            }
            
            if pet.dateBugs != nil && pet.dateRebugs != nil {
                let timeLast = Float((pet.calculateTimeInterval(fromDate: (pet.dateRebugs)!)))
                let dayLastRebugs = (lroundf(Float(timeLast/60/60/24)))
                switch dayLastRebugs {
                case ..<1:
                    cell.petDesctiptionBugs.text = "Нужна обработка от блох"
                    cell.petDesctiptionBugs.textColor = .red
                case 0...30:
                    cell.petDesctiptionBugs.text = "Обработка от блох заканчивается"
                    cell.petDesctiptionBugs.textColor = .red
                default:
                    cell.petDesctiptionBugs.text = "Питомец обработан от блох"
                    cell.petDesctiptionBugs.textColor = .black
                }
            } else {
                    cell.petDesctiptionBugs.text = "Заполните данные обработки от блох"
                    cell.petDesctiptionBugs.textColor = .systemGray
//                cell.petDesctiptionBugs.isHidden = true
                
            }
            
            if pet.dateParasite != nil && pet.dateReparasite != nil  {
                let timeLast = Float((pet.calculateTimeInterval(fromDate: (pet.dateReparasite)!)))
                var dayLastReparasite = (lroundf(Float(timeLast/60/60/24)))
                switch dayLastReparasite {
                case ..<1:
                    cell.petDescriptionParasite.text = "Нужна обработка от глистов"
                    cell.petDescriptionParasite.textColor = .red
                case 0...30:
                    cell.petDescriptionParasite.text = "Обработка от глистов заканчивается"
                    cell.petDescriptionParasite.textColor = .red
                default:
                    cell.petDescriptionParasite.text = "Питомец обработан от глистов"
                    cell.petDescriptionParasite.textColor = .black
                }
            } else {
                cell.petDescriptionParasite.text = "Заполните данные обработки от глистов"
                cell.petDescriptionParasite.textColor = .systemGray
            }
            return cell
        }
        return cell
    }
    
    func calculatePetsAge(bday: Date) -> [Int] {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let calendar : NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
        let calcAge = calendar.components(.month, from: bday, to: Date()).month
        let year = calcAge! / 12
        let mounth = calcAge! % 12
        return [year, mounth]
    }
    
    
    func calculateTimeInterval(fromDate: Date) -> Double {
        let timeInterval = fromDate.timeIntervalSince(dateNow)
        return (timeInterval)
    }
    
    func correctFillTheLabelOfMainVC(date: [Int]) -> [String] {
        var firstArg = String()
        var secondArg = String()
        
        switch date[0] {
        case 0:
            firstArg = ""
        case 1,21,31,41,51:
            firstArg = "год"
        case 2,3,4,22,23,24,32,33,34,42,43,44:
            firstArg = "года"
        case 5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,25,26,27,28,29,30,35,36,37,38,39,40:
            firstArg = "лет"
        default:
            break
        }
        switch date[1] {
        case 0:                     secondArg = ""
        case 1:                     secondArg = "месяц"
        case 2,3,4:                 secondArg = "месяца"
        case 5,6,7,8,9,10,11,12:    secondArg = "месяцев"
        default: break
        }
        return [firstArg, secondArg]
    }
    
    
    func correctFillTheTFOfShowPetVC(lastDay: Int) -> [String] {
        var firstArg = String()
        var secondArg = String()
        var thirdArg = String()
        if lastDay > 0 {
            firstArg = "Срок защиты: \(lastDay)"
            secondArg = "Питомец в безопасности"
            if (lastDay%100 == 1) {
                thirdArg = "день"
            } else {
                switch (lastDay%10) {
                case 1: thirdArg = "день"
                case 2,3,4: thirdArg = "дня"
                case 5,6,7,8,9,0: thirdArg = "дней"
                default: break
                }
            }
            if lastDay < 30 {
                firstArg = "Срок защиты: \(lastDay)"
                secondArg = "Срок защиты заканчивается"
            }
            
        }
        if lastDay < 0 {
            secondArg = "Питомец под угрозой"
            firstArg  = "Срок истек"
            thirdArg =  ""
        }
        
        return [firstArg, secondArg, thirdArg]
    }
    
    
}
