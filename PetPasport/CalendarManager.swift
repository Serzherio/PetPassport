//
//  CalendarManager.swift
//  PetPasport
//
//  Created by Сергей on 09.02.2022.
//  Copyright © 2022 Сергей. All rights reserved.
//

import Foundation
import EventKit
import EventKitUI


class CalendarManager {
    
    // success callback
    typealias SuccessAddEvent = ((_ identifier: String) -> Void)
    
    static let shared = CalendarManager()
    private let eventStore = EKEventStore()
    private var currentTime = Date()
    private var calendar: EKCalendar!
    
    func createEvent(startDate: Date?, title: String?, notes: String?, finished: @escaping () -> Void) {
        eventStore.requestAccess(to: EKEntityType.event) { granted, error in
            if error == nil {
                let event: EKEvent = EKEvent(eventStore: self.eventStore)
                event.title = title
                
                let formatter1 = DateFormatter()
                formatter1.dateFormat = "dd.MM.yyyy"
                let formatter2 = DateFormatter()
                formatter2.dateFormat = "dd.MM.yyyy HH:mm:ss"
                
                let stringDate = formatter1.string(from: startDate!)
                print(stringDate)
                let date: Date = formatter2.date(from: stringDate + " " + "12:00:00")!
                event.startDate = date
                event.endDate = date
                event.notes = notes
                event.calendar = self.eventStore.defaultCalendarForNewEvents
                event.addAlarm(EKAlarm(relativeOffset: 0))
                do {
                    try? self.eventStore.save(event, span: .thisEvent, commit: true)
                    finished()
                } catch _ as NSError {
                }
            }
        } // request access
    } // create Event
    
    func getEvent(date: Date, finished: @escaping ([EKEvent]) -> Void) {
        let date1 = date
        let date2 = date
        let startDate = date1.addingTimeInterval(-60*60*24*5)
        let endDate = date2.addingTimeInterval(60*60*24*5)
        print("startDate is \(startDate)")
        print("endDate is \(endDate)")
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate) as [EKEvent]
        finished(events)
    }
    
    func deleteEventByTitle(events: [EKEvent], title: String, finished: @escaping () -> Void) {
        if !events.isEmpty {
            for i in events {
                print(i.title)
                if i.title == title {
                    do {
                        try eventStore.remove(i, span: .thisEvent, commit: true)
                        finished()
                    } catch {
                    }
                }
            }
        }
    }
    
    
    
    
}
