//
//  FirstViewController.swift
//  FinalProject
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class SimulationViewController: UIViewController, GridViewDataSource, EngineDelegate {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.backgroundColor = UIColor.green
    }
    
    @IBOutlet weak var gridView: GridView!
    
    var engine: EngineProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        engine = StandardEngine.engine
        gridView.size = engine.grid.size.rows
        engine.delegate = self
        gridView.setNeedsDisplay()
        gridView.gridDataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        engine = StandardEngine.engine
        gridView.size = engine.grid.size.rows
        engine.delegate = self
        gridView.setNeedsDisplay()
        gridView.gridDataSource = self
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
    }
    
    @IBAction func step(_ sender: UIButton) {
        _ = engine.step()
        gridView.setNeedsDisplay()
    }
}
