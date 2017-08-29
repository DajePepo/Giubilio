//
//  CircularLoaderView.swift
//  ImageLoaderIndicator
//
//  Created by Richard Turton on 17/02/2015.
//  Copyright (c) 2015 Rounak Jain. All rights reserved.
//

import UIKit

class CircularLoaderView: UIView, CAAnimationDelegate {
    
    let circlePathLayer = CAShapeLayer()
    let circleRadius: CGFloat = 25.0
    let ciclyngDuration = 0.9
    let blueColor = UIColor(red: 53/255, green: 152/255, blue: 219/255, alpha: 1.0)
    let greenColor = UIColor(red: 205/255, green: 218/255, blue: 73/255, alpha: 1.0)
    let orangeColor = UIColor(red: 255/255, green: 129/255, blue: 0/255, alpha: 1.0)
    var rotating = true
    var expanded = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        circlePathLayer.frame = bounds
        circlePathLayer.lineWidth = 3
        circlePathLayer.fillColor = UIColor.clear.cgColor
        circlePathLayer.strokeColor = greenColor.cgColor
        circlePathLayer.strokeEnd = 0
        layer.addSublayer(circlePathLayer)
    }
    
    func circleFrame() -> CGRect {
        var circleFrame = CGRect(x: 0, y: 0, width: 2*circleRadius, height: 2*circleRadius)
        circleFrame.origin.x = circlePathLayer.bounds.midX - circleFrame.midX
        circleFrame.origin.y = circlePathLayer.bounds.midY - circleFrame.midY
        return circleFrame
    }
    
    func circlePath() -> UIBezierPath {
        return UIBezierPath(ovalIn: circleFrame())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circlePathLayer.frame = bounds
        circlePathLayer.path = circlePath().cgPath
    }
    
    func rotateOnce() {
        UIView.animate(withDuration: 1.0,
            delay: 0.0,
            options: .curveLinear,
            animations: {self.transform = self.transform.rotated(by: 3.1415926)},
            completion: {finished in self.rotateAgain()})
    }
    
    func rotateAgain() {
        UIView.animate(withDuration: 1.0,
            delay: 0.0,
            options: .curveLinear,
            animations: {self.transform = self.transform.rotated(by: 3.1415926)},
            completion: {finished in if self.rotating { self.rotateOnce() }})
    }
    
    func expandOrContract() {
        if rotating {
            self.animateCircle(ciclyngDuration)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64((ciclyngDuration - 0.1) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
                self.expandOrContract()
            }
        }
    }
    
    func animateCircle(_ duration: TimeInterval) {
        
        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = expanded ? 0 : 1
        animation.toValue = expanded ? 1 : 0
        CATransaction.setCompletionBlock({self.circlePathLayer.strokeColor = self.expanded ? self.greenColor.cgColor : self.orangeColor.cgColor})
        circlePathLayer.add(animation, forKey: "animateCircle")
        expanded = !expanded
        
        CATransaction.commit()
    }
    
    func stop() {
        rotating = false
    }
    
    func start() {
        expanded = false
        rotateOnce()
        expandOrContract()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        superview?.layer.mask = nil
    }

}
