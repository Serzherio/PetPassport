

import UIKit
import RealmSwift
import UserNotifications


class MainTableViewTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    

    let appdelegate = UIApplication.shared.delegate as? AppDelegate
    var pets: Results<Pet>!
    private var globalIndexPath = IndexPath()

    
    //  MARK: - LCVC: view Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        self.navigationItem.hidesBackButton = true
        pets = realm.objects(Pet.self)
        setupBackground()
        
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        
        
  
    }
    
    //  MARK: - LCVC: view Will Appear
    @objc func refresh(sender:AnyObject)
    {
        // Updating your data here..
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pets.isEmpty ? 0 : pets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PetTableViewCell
        let pet = pets[indexPath.row]
        return pet.configureCell(pet: pet, cell: cell)
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.globalIndexPath = indexPath
        self.performSegue(withIdentifier: "hello", sender: self)
        
    }
    
    
    
// MARK: -  Table View Delegate

    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Удалить") {  (contextualAction, view, boolValue) in
            self.globalIndexPath = indexPath
            
            // Create Alert Controller
            let swipeDeleteAlertController = UIAlertController (title: "Вы уверены?", message: "Информация о вашем питомце будет навсегда удалена", preferredStyle: .alert)
            let delete = UIAlertAction(title: "Удалить", style: .destructive, handler: {_ in
                let pet = self.pets[indexPath.row]
               // self.deleteAllCalendarEvents(pet: pet)
                self.deleteEventInDeletingPet(pet: pet)
                StorageManager.deleteObject(pet)
                
                tableView.deleteRows(at: [indexPath], with: .fade)
            })
            let cancel = UIAlertAction(title: "Отмена", style: .cancel)
            swipeDeleteAlertController.addAction(delete)
            swipeDeleteAlertController.addAction(cancel)
            self.present(swipeDeleteAlertController, animated: true)
        }
        editAction.backgroundColor = UIColor.systemRed
        let swipeActions = UISwipeActionsConfiguration(actions: [editAction])
        return swipeActions
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Изменить") {  (contextualAction, view, boolValue) in
            self.globalIndexPath = indexPath
            let swipeEditAlertController = UIAlertController (title: "Хотите изменить информацию о питомце?", message: "", preferredStyle: .alert)
            let delete = UIAlertAction(title: "Изменить", style: .default, handler: {_ in
                self.performSegue(withIdentifier: "showDetail", sender: self)
            })
            let cancel = UIAlertAction(title: "Отмена", style: .cancel, handler: {_ in
            })
            swipeEditAlertController.addAction(delete)
            swipeEditAlertController.addAction(cancel)
            self.present(swipeEditAlertController, animated: true)
        }
        editAction.backgroundColor = UIColor.systemGreen
        let swipeActions = UISwipeActionsConfiguration(actions: [editAction])
        return swipeActions
    }
    
    
    //  MARK: - Supporting Functions
    
    func setupBackground() {
        let image = UIImage(named: "MainBG")
        let imageView = UIImageView(image: image)
        
        tableView.backgroundView = imageView
        tableView.tableFooterView = UIView()
        imageView.alpha = 0.5
  
    }
    
    private func deleteAllCalendarEvents(pet: Pet) {
        if pet.dateVaction != nil && pet.dateRevaction != nil {
            CalendarManager.shared.getEvent(date: pet.dateRevaction!) { events in
                CalendarManager.shared.deleteEventByTitle(events: events,
                                                          title: "Вакцинация питомца \(pet.name)") {
                }
            }
        }
        
        if pet.dateParasite != nil && pet.dateReparasite != nil {
            CalendarManager.shared.getEvent(date: pet.dateReparasite!) { events in
                CalendarManager.shared.deleteEventByTitle(events: events,
                                                          title: "Обработка от глистов питомца \(pet.name)") {
                }
            }
        }
        
        if pet.dateBugs != nil && pet.dateRebugs != nil {
            CalendarManager.shared.getEvent(date: pet.dateRebugs!) { events in
                CalendarManager.shared.deleteEventByTitle(events: events,
                                                          title: "Обработка от насекомых питомца \(pet.name)") {
                }
            }
        }
    }
        
        
       private func deleteEventInDeletingPet(pet: Pet) {
            if pet.dateRevaction != nil {
                CalendarManager.shared.getExistEvents(date: pet.dateRevaction!) { result in
                    switch result {
                    case .success(let events):
                        CalendarManager.shared.deleteExistEvents(events: events,
                                                                 title: "Вакцинация питомца \(pet.name)") { result in
                            switch result {
                            case .success(_):
                                print("events were deleted")
                            case .failure(let error):
                                print("error is \(error.localizedDescription)")
                            }
                        }
                    case .failure(let error):
                        print("error is \(error.localizedDescription)")
                    }
                }
            }
            if pet.dateReparasite != nil {
                CalendarManager.shared.getExistEvents(date: pet.dateReparasite!) { result in
                    switch result {
                    case .success(let events):
                        CalendarManager.shared.deleteExistEvents(events: events,
                                                                 title: "Обработка от глистов питомца \(pet.name)") { result in
                            switch result {
                            case .success(_):
                                print("events were deleted")
                            case .failure(let error):
                                print("error is \(error.localizedDescription)")
                            }
                        }
                    case .failure(let error):
                        print("error is \(error.localizedDescription)")
                    }
                }
            }
            if pet.dateRebugs != nil {
                CalendarManager.shared.getExistEvents(date: pet.dateRebugs!) { result in
                    switch result {
                    case .success(let events):
                        CalendarManager.shared.deleteExistEvents(events: events,
                                                                 title: "Обработка от насекомых питомца \(pet.name)") { result in
                            switch result {
                            case .success(_):
                                print("events were deleted")
                            case .failure(let error):
                                print("error is \(error.localizedDescription)")
                            }
                        }
                    case .failure(let error):
                        print("error is \(error.localizedDescription)")
                    }
                }
            }
        }
        
        
        
        
    
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Создайте свою первую карточку питомца!"
        let attrs = [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 26), NSAttributedString.Key.foregroundColor: UIColor.black]
        let textColor = UIColor.black
        return NSAttributedString(string: str, attributes: attrs)
    }
    //
    
    func imageTintColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        .black
    }
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Для этого нажмите кнопку + в верхей правой части экрана"
        let attrs = [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor.black]
        return NSAttributedString(string: str, attributes: attrs)
    }
    //
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        let image = UIImage(named: "DogDefaultImage")
        return image
    }
    
    
    
    
    //  MARK: - Segue
    @IBAction func unwindSegue (_ segue: UIStoryboardSegue) {
        guard let addPetVC = segue.source as? AddPetViewController else {return}
        guard let addPetTVC = addPetVC.children[0] as? AddPetTableViewController else {return}
        if addPetTVC.petName.text != "" {
            addPetTVC.savePet()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let addPetVC = segue.destination as? AddPetViewController else {return}
            addPetVC.currentPet = pets[globalIndexPath.row]

        }
        
        if segue.identifier == "hello" {
            let VC = segue.destination as! ShowPetTableViewController
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            VC.currentPet = pets[indexPath.row]
        } else {return}
    }
}


