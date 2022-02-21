//
//  CalendarViewController.swift
//  PetPasport
//
//  Created by Сергей on 22.02.2021.
//  Copyright © 2021 Сергей. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDelegateAppearance, FSCalendarDataSource, FSCalendarDelegate {
    
    @IBOutlet weak var calendar: FSCalendar!
    var dates = [String]()
    let dateFormatter = DateFormatter()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.navigationItem.setHidesBackButton(true, animated: false)
        calendar.locale = Locale(identifier: "ru_RU")
        calendar.allowsMultipleSelection = true
//        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.dateFormat = "dd.MM.yyyy"
            for each in dates {
                calendar.select(dateFormatter.date(from: each))
            }
    }

    
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateString = self.dateFormatter.string(from: date)
        dates.append(dateString)
        print("dates are \(dates)")

    }

    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateString = self.dateFormatter.string(from: date)
        if dates.contains(dateString) {
            let index = dates.firstIndex(of: dateString)
            dates.remove(at: index!)
        }
    }
    
    fileprivate lazy var dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()

    
    
    
    
    
    
    
    
    
    
    
}


