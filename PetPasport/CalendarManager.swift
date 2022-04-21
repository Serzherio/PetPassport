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
    
    
    func createNewEvent(startDate: Date?, title: String?, notes: String?, completion: @escaping (Result<String,Error>) -> Void) {
        eventStore.requestAccess(to: EKEntityType.event) { granted, error in
            if error == nil {
                let event: EKEvent = EKEvent(eventStore: self.eventStore)
                let formatter1 = DateFormatter()
                formatter1.dateFormat = "dd.MM.yyyy"
                let formatter2 = DateFormatter()
                formatter2.dateFormat = "dd.MM.yyyy HH:mm:ss"
                let stringDate = formatter1.string(from: startDate!)
                let date: Date = formatter2.date(from: stringDate + " " + "12:00:00")!
                
                event.title = title
                event.startDate = date
                event.endDate = date
                event.notes = notes
                event.calendar = self.eventStore.defaultCalendarForNewEvents
                event.addAlarm(EKAlarm(relativeOffset: 0))
                
                DispatchQueue.main.async {
                    do {
                        try self.eventStore.save(event, span: .thisEvent, commit: true)
                        completion(.success(""))
                    } catch {
                        completion(.failure(CalendarError.eventsCannotBeCreated))
                    }

                }
            }
        }
    }
    
    func getExistEvents(date: Date, completion: @escaping(Result<[EKEvent], Error>) -> Void) {
        let date1 = date
        let date2 = date
        let startDate = date1.addingTimeInterval(-60*60*24*5)
        let endDate = date2.addingTimeInterval(60*60*24*5)
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate) as [EKEvent]
        if !events.isEmpty {
            completion(.success(events))
        } else {
            completion(.failure(CalendarError.eventsDontExist))
        }
    }
    
    func deleteExistEvents(events: [EKEvent], title: String, completion: @escaping(Result<String, Error>) -> Void) {
        if !events.isEmpty {
            for i in events {
                if i.title == title {
                    do {
                        try eventStore.remove(i, span: .thisEvent, commit: true)
                        completion(.success("EventsWereDeleted"))
                    } catch {
                        completion(.failure(CalendarError.eventsCannotBeDeleted))
                    }
                }
            }
        }
    }
    
 
    
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
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate) as [EKEvent]
        finished(events)
    }
    
    func deleteEventByTitle(events: [EKEvent], title: String, finished: @escaping () -> Void) {
        if !events.isEmpty {
            for i in events {
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
    
    
    // MARK: - create events logic
    func createEventVaction(pet: Pet, currentPet: Pet?) {
        if pet.dateRevaction != nil {
            if currentPet?.dateRevaction != nil {
                CalendarManager.shared.getExistEvents(date: currentPet!.dateRevaction!) { result in
                    switch result {
                    case .success(let events):
                        CalendarManager.shared.deleteExistEvents(events: events,
                                                                 title: "Вакцинация питомца \(pet.name)") { result in
                            switch result {
                            case .success(let response):
                                print(response)
                                CalendarManager.shared.createNewEvent(startDate: pet.dateRevaction,
                                                                      title: "Вакцинация питомца \(pet.name)",
                                                                      notes: "Проведите повторную вакцинацию питомца и обновите информацию в приложении Pet Passport") { resultOfCreate in
                                    switch resultOfCreate {
                                    case .success(_):
                                        print("Вакцинация питомца успешно изменена")
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                    }
                                }
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        CalendarManager.shared.createNewEvent(startDate: pet.dateRevaction,
                                                              title: "Вакцинация питомца \(pet.name)",
                                                              notes: "Проведите повторную вакцинацию питомца и обновите информацию в приложении Pet Passport") { result in
                            switch result {
                            case .success(_):
                                print("Вакцинация питомца успешно создана")
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    } //switch result
                } // CalendarManager.shared.getExistEvents
            } else { // if currentPet?.dateRevaction != nil
                CalendarManager.shared.createNewEvent(startDate: pet.dateRevaction,
                                                      title: "Вакцинация питомца \(pet.name)",
                                                      notes: "Проведите повторную вакцинацию питомца и обновите информацию в приложении Pet Passport") { result in
                    switch result {
                    case .success(_):
                        print("Вакцинация питомца успешно создана")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            } // if currentPet?.dateRevaction == nil
        } //if pet.dateRevaction != nil
    }
    
    
    
    func createEventParasite(pet: Pet, currentPet: Pet?) {
        if pet.dateReparasite != nil {
            if currentPet?.dateReparasite != nil {
                CalendarManager.shared.getExistEvents(date: currentPet!.dateReparasite!) { result in
                    switch result {
                    case .success(let events):
                        CalendarManager.shared.deleteExistEvents(events: events,
                                                                 title: "Обработка от глистов питомца \(pet.name)") { result in
                            switch result {
                            case .success(let response):
                                print(response)
                                CalendarManager.shared.createNewEvent(startDate: pet.dateReparasite,
                                                                      title: "Обработка от глистов питомца \(pet.name)",
                                                                      notes: "Проведите повторную обработку от глистов питомца и обновите информацию в приложении Pet Passport") { resultOfCreate in
                                    switch resultOfCreate {
                                    case .success(_):
                                        print("От глистов питомца успешно изменена")
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                    }
                                }
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        CalendarManager.shared.createNewEvent(startDate: pet.dateReparasite,
                                                              title: "Обработка от глистов питомца \(pet.name)",
                                                              notes: "Проведите повторную обработку от глистов питомца и обновите информацию в приложении Pet Passport") { resultOfCreate in
                            switch resultOfCreate {
                            case .success(_):
                                print("От глистов питомца успешно изменена")
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    } //switch result
                } // CalendarManager.shared.getExistEvents
            } else { // if currentPet?.dateRevaction != nil
                CalendarManager.shared.createNewEvent(startDate: pet.dateReparasite,
                                                      title: "Обработка от глистов питомца \(pet.name)",
                                                      notes: "Проведите повторную обработку от глистов питомца и обновите информацию в приложении Pet Passport") { resultOfCreate in
                    switch resultOfCreate {
                    case .success(_):
                        print("От глистов питомца успешно изменена")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            } // if currentPet?.dateRevaction == nil
        } //if pet.dateRevaction != nil
    }
    
    func createEventBugs(pet: Pet, currentPet: Pet?) {
        if pet.dateRebugs != nil {
            if currentPet?.dateRebugs != nil {
                CalendarManager.shared.getExistEvents(date: currentPet!.dateRebugs!) { result in
                    switch result {
                    case .success(let events):
                        CalendarManager.shared.deleteExistEvents(events: events,
                                                                 title: "Обработка от глистов питомца \(pet.name)") { result in
                            switch result {
                            case .success(let response):
                                print(response)
                                CalendarManager.shared.createNewEvent(startDate: pet.dateRebugs,
                                                                      title: "Обработка от насекомых питомца \(pet.name)",
                                                                      notes: "Проведите повторную обработку от насекомых питомца и обновите информацию в приложении Pet Passport") { resultOfCreate in
                                    switch resultOfCreate {
                                    case .success(_):
                                        print("От насекомых питомца успешно изменена")
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                    }
                                }
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        CalendarManager.shared.createNewEvent(startDate: pet.dateRebugs,
                                                              title: "Обработка от насекомых питомца \(pet.name)",
                                                              notes: "Проведите повторную обработку от насекомых питомца и обновите информацию в приложении Pet Passport") { resultOfCreate in
                            switch resultOfCreate {
                            case .success(_):
                                print("От насекомых питомца успешно изменена")
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    } //switch result
                } // CalendarManager.shared.getExistEvents
            } else { // if currentPet?.dateRevaction != nil
                CalendarManager.shared.createNewEvent(startDate: pet.dateRebugs,
                                                      title: "Обработка от насекомых питомца \(pet.name)",
                                                      notes: "Проведите повторную обработку от насекомых питомца и обновите информацию в приложении Pet Passport") { resultOfCreate in
                    switch resultOfCreate {
                    case .success(_):
                        print("От насекомых питомца успешно изменена")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            } // if currentPet?.dateRevaction == nil
        } //if pet.dateRevaction != nil
    }
    
    
    
    
}
