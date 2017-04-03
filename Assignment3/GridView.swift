//
//  GridView.swift
//  Assignment3
//
//  Created by David Hu on 3/22/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

@IBDesignable class GridView: UIView {

    @IBInspectable var size = 20 {
        didSet {
            grid = Grid(size, size)
        }
    }
    @IBInspectable var livingColor = UIColor.green
    @IBInspectable var emptyColor = UIColor.darkGray
    @IBInspectable var bornColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.6)
    @IBInspectable var diedColor = UIColor(white: 0.333, alpha: 0.6)
    @IBInspectable var gridColor = UIColor.black
    @IBInspectable var gridWidth = CGFloat(2.0)
    
    var grid = Grid(20, 20) //{ _,_ in arc4random_uniform(3) == 2 ? .alive : .empty }
    
    override func draw(_ rect: CGRect) {
        let cellSize = CGSize(
            width: rect.size.width / CGFloat(size),
            height: rect.size.height / CGFloat(size)
        )
        let base = rect.origin
        
        (0 ... size).forEach {
            drawLine(
                start: CGPoint(x: CGFloat($0) * cellSize.width, y: 0.0),
                end:   CGPoint(x: CGFloat($0) * cellSize.width, y: rect.size.height)
            )
            
            drawLine(
                start: CGPoint(x: 0.0, y: CGFloat($0) * cellSize.height ),
                end: CGPoint(x: rect.size.width, y: CGFloat($0) * cellSize.height)
            )
        }
        
        (0 ..< size).forEach { i in
            (0 ..< size).forEach { j in
                let origin = CGPoint(
                    x: base.x + (CGFloat(j) * cellSize.width),
                    y: base.y + (CGFloat(i) * cellSize.height)
                )
                let cellRect = CGRect(
                    origin: origin,
                    size: cellSize
                )
                let path = UIBezierPath(ovalIn: cellRect)
                switch grid[(i,j)] {
                case .alive:
                    livingColor.setFill()
                case .empty:
                    emptyColor.setFill()
                case .born:
                    bornColor.setFill()
                case .died:
                    diedColor.setFill()
                }
                path.fill()
            }
        }
    }
    func drawLine(start:CGPoint, end: CGPoint) {
        let path = UIBezierPath()
        path.lineWidth = gridWidth
        path.move(to: start)
        path.addLine(to: end)
        
        gridColor.setStroke()
        path.stroke()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = nil
    }
    
    typealias Position = (row: Int, col: Int)
    var lastTouchedPosition: Position?
    
    func process(touches: Set<UITouch>) -> Position? {
        guard touches.count == 1 else { return nil }
        let pos = convert(touch: touches.first!)
        guard lastTouchedPosition?.row != pos.row
            || lastTouchedPosition?.col != pos.col
            else { return pos }
        
        grid[(pos.row,pos.col)] = grid[(pos.row,pos.col)].isAlive ? .empty : .alive
        setNeedsDisplay()
        return pos
    }
    
    func convert(touch: UITouch) -> Position {
        let touchY = touch.location(in: self).y
        let gridHeight = frame.size.height
        let row = touchY / gridHeight * CGFloat(size)
        let touchX = touch.location(in: self).x
        let gridWidth = frame.size.width
        let col = touchX / gridWidth * CGFloat(size)
        let position = (row: Int(row), col: Int(col))
        return position
    }

}
