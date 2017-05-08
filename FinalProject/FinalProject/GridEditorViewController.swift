//
//  GridEditorViewController.swift
//  FinalProject
//
//  David Hu
//

import UIKit

class GridEditorViewController: UIViewController, GridViewDataSource, EngineDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var gridView: GridView!
    
    var engine: StandardEngine!
    var savedGrid: SavedGrid?
    var saveClosure: ((SavedGrid) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = false
        
        if savedGrid != nil {
            engine = StandardEngine(rows: savedGrid!.size, cols: savedGrid!.size)
            
            _ = engine.load(savedGrid: savedGrid!)
            
            self.title = savedGrid?.title
            titleTextField.text = savedGrid?.title
            
            gridView.gridDataSource = self
            gridView.size = engine.grid.size.rows
            engine.delegate = self
            gridView.setNeedsDisplay()
        }
    }

    func engineDidUpdate(withGrid: GridProtocol) {
        self.gridView.setNeedsDisplay()
    }
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return engine.grid[row,col] }
        set { engine.grid[row,col] = newValue }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save(_ sender: UIButton) {
        guard let title = titleTextField.text else { return }
        savedGrid!.title = title
        savedGrid!.size = engine.grid.size.rows
        savedGrid!.grid = engine.save()
        
        if let newValue = savedGrid,
            let saveClosure = saveClosure {
            saveClosure(newValue)
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "LoadUpdate")
        let n = Notification(name: name, object: savedGrid)
        nc.post(n)
    }

}
