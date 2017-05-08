//
//  InstrumentationViewController.swift
//  FinalProject
//  David Hu
//
//  uses 1 controller for rows/cols requested by Prof. Simmons in Apr 12 discussion.
//

import UIKit

struct SavedGrid {
    var title: String
    var grid: [[Int]]
    var size: Int
}

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
        
        self.tabBarController?.tabBar.backgroundColor = UIColor.cyan
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sizeTextField.text = "\(StandardEngine.engine.rows)"
        sizeStepper.value = Double(StandardEngine.engine.rows)
        refreshSlider.value = Float(1.0 / StandardEngine.engine.refreshRate)
        refreshSwitch.isOn = StandardEngine.engine.refreshOn
        
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
                self.saveSize.text = "size"
            }
            return
        }
        guard let t = saveSize.text else { return }
        
        var grid: [[Int]]
        for i in 0..<val {
            for j in 0..<val {
                grid[i][j] = 0
            }
        }
        
        saves[0] = SavedGrid(title: t,
                              grid: grid,
                              size: val)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        if let indexPath = indexPath {
            let save = saves[indexPath.row]
            if let vc = segue.destination as? GridEditorViewController {
                vc.fruitValue = fruitValue
                vc.saveClosure = { newValue in
                    data[indexPath.section][indexPath.row] = newValue
                    self.tableView.reloadData()
                }
            }
        }
    }
}

