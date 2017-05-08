//
//  InstrumentationViewController.swift
//  FinalProject
//
//  David Hu
//

import UIKit

struct SavedGrid {
    var title: String
    var grid: [[Int]]
    var size: Int
}

let finalProjectURL = "https://dl.dropboxusercontent.com/u/7544475/S65g.json"

class InstrumentationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var sizeStepper: UIStepper!
    @IBOutlet weak var refreshSlider: UISlider!
    @IBOutlet weak var refreshSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveSize: UITextField!
    @IBOutlet weak var saveTitle: UITextField!
    
    var saves: [SavedGrid] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.backgroundColor = UIColor.blue
        navigationController?.isNavigationBarHidden = false
        
        sizeTextField.text = "\(StandardEngine.engine.rows)"
        sizeStepper.value = Double(StandardEngine.engine.rows)
        refreshSlider.value = Float(1.0 / StandardEngine.engine.refreshRate)
        refreshSwitch.isOn = StandardEngine.engine.refreshOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sizeTextField.text = "\(StandardEngine.engine.rows)"
        sizeStepper.value = Double(StandardEngine.engine.rows)
        refreshSlider.value = Float(1.0 / StandardEngine.engine.refreshRate)
        refreshSwitch.isOn = StandardEngine.engine.refreshOn
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "SaveUpdate")
        nc.addObserver(forName: name,
                       object: nil,
                       queue: nil) { (n) in
                        guard let save: SavedGrid = n.object as! SavedGrid? else {return}
                        self.saves.insert(save, at: 0)
                        self.tableView.reloadData()
        }
        let fetcher = Fetcher()
        fetcher.fetchJSON(url: URL(string:finalProjectURL)!) { (json: Any?, message: String?) in
            guard message == nil else {
                print(message ?? "nil")
                return
            }
            guard let json = json else {
                print("no json")
                return
            }
            let jsonArray = json as! NSArray
            for i in 0..<jsonArray.count {
                let jsonDictionary = jsonArray[i] as! NSDictionary
                let jsonTitle = jsonDictionary["title"] as! String
                let jsonContents = jsonDictionary["contents"] as! [[Int]]
                
                var max = 0
                for j in 0..<jsonContents.count {
                    if jsonContents[j][0] > max {
                        max = jsonContents[j][0]
                    }
                    if jsonContents[j][1] > max {
                        max = jsonContents[j][1]
                    }
                }
                var grid = Array(repeating: Array(repeating: 0, count: 2*max), count: 2*max)
                for j in 0..<jsonContents.count {
                    let row = jsonContents[j][0]
                    let col = jsonContents[j][1]
                    grid[row][col] = 1
                }
                let savedGrid = SavedGrid(title: jsonTitle, grid: grid, size: 2*max)
                self.saves.append(savedGrid)
            }
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func resizeText(_ sender: UITextField) {
        guard let text = sender.text else { return }
        guard let val = Int(text) else {
            showErrorAlert(withMessage: "Invalid value: \(text), please try again.") {
                sender.text = "\(StandardEngine.engine.rows)"
            }
            return
        }
        StandardEngine.engine.setSize(rows: val, cols: val)
        sizeStepper.value = Double(val)
    }

    @IBAction func resizeStepper(_ sender: UIStepper) {
        let size = Int(sender.value)
        sizeTextField.text = "\(size)"
        StandardEngine.engine.setSize(rows: size, cols: size)
    }
    
    @IBAction func refreshRate(_ sender: UISlider) {
        StandardEngine.engine.setRate(rate: 1.0/Double(sender.value))
    }
    
    @IBAction func refreshTimer(_ sender: UISwitch) {
        StandardEngine.engine.setTimer(refreshOn: sender.isOn)
    }
    
    @IBAction func addRow(_ sender: UIButton) {
        guard let text = saveSize.text else { return }
        guard let val = Int(text) else {
            showErrorAlert(withMessage: "Invalid value: \(text), please try again.") {
                self.saveSize.text = "Size"
            }
            return
        }
        guard val > 1 else {
            showErrorAlert(withMessage: "Invalid value: \(text), please try again.") {
                self.saveSize.text = "Size"
            }
            return
        }
        guard let t = saveTitle.text else { return }
        guard t != "" else {
            showErrorAlert(withMessage: "Invalid value: \(t), please try again.") {
                self.saveTitle.text = "Title"
            }
            return
        }
        
        let grid = Array(repeating: Array(repeating: 0, count: val), count: val)
        
        let newSave = SavedGrid(title: t, grid: grid, size: val)
        saves.insert(newSave, at: 0)
        tableView.reloadData()
    }
    
    func showErrorAlert(withMessage msg:String, action: (() -> Void)? ) {
        let alert = UIAlertController(
            title: "Alert",
            message: msg,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true) { }
            OperationQueue.main.addOperation { action?() }
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return saves.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "basic"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let label = cell.contentView.subviews.first as! UILabel
        label.text = saves[indexPath.item].title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            saves.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.title = "Cancel"
        let indexPath = tableView.indexPathForSelectedRow
        if let indexPath = indexPath {
            let save = saves[indexPath.row]
            if let vc = segue.destination as? GridEditorViewController {
                vc.savedGrid = save
                vc.saveClosure = { newValue in
                    self.saves[indexPath.row] = newValue
                    self.tableView.reloadData()
                }
            }
        }
    }
}

