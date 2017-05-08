//
//  SimulatonViewController.swift
//  Final Project
//
//  David Hu
//

import UIKit

class SimulationViewController: UIViewController, GridViewDataSource, EngineDelegate {
    
    @IBOutlet weak var gridView: GridView!
    
    let defaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.backgroundColor = UIColor.green
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gridView.size = StandardEngine.engine.grid.size.rows
        gridView.gridDataSource = self
        StandardEngine.engine.delegate = self
        self.gridView.setNeedsDisplay()
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                self.gridView.size = StandardEngine.engine.grid.size.rows
                self.gridView.setNeedsDisplay()
        }
        let loadName = Notification.Name(rawValue: "LoadUpdate")
        nc.addObserver(forName: loadName, object: nil, queue: nil) { (n) in
            guard let save: SavedGrid = n.object as! SavedGrid? else {return}
            _ = StandardEngine.engine.load(savedGrid: save)
            self.gridView.size = StandardEngine.engine.grid.size.rows
            self.gridView.setNeedsDisplay()
        }
    }
    
    func engineDidUpdate(withGrid: GridProtocol) {
        gridView.size = StandardEngine.engine.grid.size.rows
        self.gridView.setNeedsDisplay()
    }
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return StandardEngine.engine.grid[row,col] }
        set { StandardEngine.engine.grid[row,col] = newValue }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func step(_ sender: UIButton) {
        _ = StandardEngine.engine.step()
        self.gridView.setNeedsDisplay()
    }
    
    @IBAction func save(_ sender: UIButton) {
        let save = SavedGrid(title: "saved simulation",
                             grid: StandardEngine.engine.save(),
                             size: StandardEngine.engine.grid.size.rows)
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "SaveUpdate")
        let n = Notification(name: name, object: save)
        nc.post(n)
        
        defaults.set(save.grid, forKey: "Grid")
    }
    
    @IBAction func reset(_ sender: UIButton) {
        StandardEngine.engine.reset()
        self.gridView.setNeedsDisplay()
    }
}
