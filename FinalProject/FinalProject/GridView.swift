//
//  GridView.swift
//  Assignment3
//
//  Created by David Hu on 3/22/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

public protocol GridViewDataSource {
    subscript (row: Int, col: Int) -> CellState { get set }
}

@IBDesignable class GridView: UIView {

    var gridDataSource: GridViewDataSource?
    @IBInspectable var size = 10
    @IBInspectable var livingColor = UIColor.green
    @IBInspectable var emptyColor = UIColor.clear
    @IBInspectable var bornColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.4)
    @IBInspectable var diedColor = UIColor(white: 0.333, alpha: 0.4)
    @IBInspectable var gridColor = UIColor.black
    @IBInspectable var gridWidth = CGFloat(2.0)
    
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
                    x: base.x + (CGFloat(j) * cellSize.width) + gridWidth,
                    y: base.y + (CGFloat(i) * cellSize.height) + gridWidth
                )
                let ovalSize = CGSize(
                    width: cellSize.width - 2 * gridWidth,
                    height: cellSize.height - 2 * gridWidth
                )
                let ovalRect = CGRect(
                    origin: origin,
                    size: ovalSize
                )
                let path = UIBezierPath(ovalIn: ovalRect)
                if let grid = gridDataSource {
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
    
    var lastTouchedPosition: GridPosition?
    
    func process(touches: Set<UITouch>) -> GridPosition? {
        let touchY = touches.first!.location(in: self.superview).y
        let touchX = touches.first!.location(in: self.superview).x
        guard touchX > frame.origin.x && touchX < (frame.origin.x + frame.size.width) else { return nil }
        guard touchY > frame.origin.y && touchY < (frame.origin.y + frame.size.height) else { return nil }
        
        guard touches.count == 1 else { return nil }
        let pos = convert(touch: touches.first!)
        
        guard lastTouchedPosition?.row != pos.row
            || lastTouchedPosition?.col != pos.col
            else { return pos }
        
        if gridDataSource != nil {
            gridDataSource![pos.row, pos.col] = gridDataSource![pos.row, pos.col].isAlive ? .empty : .alive
            setNeedsDisplay()
        }
        return pos
    }
    
    func convert(touch: UITouch) -> GridPosition {
        let touchY = touch.location(in: self).y
        let gridHeight = frame.size.height
        let row = touchY / gridHeight * CGFloat(size)
        let touchX = touch.location(in: self).x
        let gridWidth = frame.size.width
        let col = touchX / gridWidth * CGFloat(size)
        
        return GridPosition(row: Int(row), col: Int(col))
    }

}
