//
//  StatisticsViewController.swift
//  FinalProject
//
//  Created by David Hu on 5/5/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {
    
    @IBOutlet weak var aliveLabel: UILabel!
    @IBOutlet weak var bornLabel: UILabel!
    @IBOutlet weak var diedLabel: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.backgroundColor = UIColor.blue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        update(grid: StandardEngine.engine.grid)
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        nc.addObserver(forName: name,
            object: nil,
            queue: nil) { (n) in
                self.update(grid: StandardEngine.engine.grid)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func update(grid: GridProtocol) {
        
        var alive = 0
        var born = 0
        var died = 0
        var empty = 0
        
        (0 ..< grid.size.rows).forEach { i in
            (0 ..< grid.size.cols).forEach { j in
                
                switch grid[i,j]
                {
                case .alive:
                    alive += 1
                case .born:
                    born += 1
                case .died:
                    died += 1
                case .empty:
                    empty += 1
                }
            }
        }
        aliveLabel.text = "\(alive)"
        bornLabel.text = "\(born)"
        diedLabel.text = "\(died)"
        emptyLabel.text = "\(empty)"
    }
}
