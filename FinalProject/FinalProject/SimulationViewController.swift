//
//  FirstViewController.swift
//  FinalProject
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class SimulationViewController: UIViewController, GridViewDataSource, EngineDelegate {
    
    @IBOutlet weak var gridView: GridView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.backgroundColor = UIColor.green
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gridView.size = StandardEngine.engine.grid.size.rows
        StandardEngine.engine.delegate = self
        gridView.setNeedsDisplay()
        gridView.gridDataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        gridView.size = StandardEngine.engine.grid.size.rows
        StandardEngine.engine.delegate = self
        gridView.setNeedsDisplay()
        gridView.gridDataSource = self
    }
    
    func engineDidUpdate(withGrid: GridProtocol) {
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
        gridView.setNeedsDisplay()
    }
}
