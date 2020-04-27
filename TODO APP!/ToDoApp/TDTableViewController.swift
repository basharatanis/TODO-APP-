import UIKit

class ToDoTableViewController: UITableViewController, TodoCellDelegate {
    

    var todoItems:[TodoItem]!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    @IBAction func add(_ sender: Any) {
        let addAlert = UIAlertController(title: "Adding Item!", message: "Whats the task?", preferredStyle: .alert)
        
        addAlert.addTextField { (textfield : UITextField) in
            textfield.placeholder = "Description"
        }
        
        
        addAlert.addAction(UIAlertAction(title: "Create", style: .default, handler:
            {(action:UIAlertAction) in
            
                guard let title = addAlert.textFields?.first?.text else { return }
                let newTodo = TodoItem.init(title: title, completed: false, createdAt: Date(), itemIdentifier: UUID())
                newTodo.saveItem()
                
                self.todoItems.append(newTodo)
                
                let indexPath = IndexPath(row: self.tableView.numberOfRows(inSection: 0), section: 0)
                self.tableView.insertRows(at: [indexPath], with: .automatic)}))
        
        
        addAlert.addAction(UIAlertAction(title: "Discart", style: .cancel, handler: nil))
        
        self.present(addAlert, animated: true,completion: nil)
        
    }
    
    func didRequestDelete(_ cell: ToDoTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            todoItems[indexPath.row].deleteItem()
            todoItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func didRequestComplete(_ cell: ToDoTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            var todoItem = todoItems[indexPath.row]
            todoItem.markAsCompleted()
            cell.todoLabel.attributedText = strikeThroughText(todoItem.title)
        }
    }
    
    func strikeThroughText(_ text: String) -> NSAttributedString {
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: text)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,value: 1,range: NSMakeRange(0, attributeString.length))
        
        return attributeString
    }
    
    func loadData() {
        todoItems = [TodoItem]()
        todoItems = DataManager.loadAll(TodoItem.self).sorted(by: {
            $0.createdAt < $1.createdAt
        })
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ToDoTableViewCell
        
        cell.delegate = self
        
        let todoItem = todoItems[indexPath.row]
        
        cell.todoLabel.text = todoItem.title

        if todoItem.completed {
            cell.todoLabel.attributedText = strikeThroughText(todoItem.title)
        }

        return cell
    }
}
