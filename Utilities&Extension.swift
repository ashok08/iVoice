//
//  Utilities&Extension.swift
//  iVoice
//
//  Created by Ashok on 31/05/21.
//

import Foundation
import UIKit
import NVActivityIndicatorView

class Utilities: NSObject {
    
    static let shared = Utilities()
    var indicator : NVActivityIndicatorView?
    
    //MARK: -InitiateViewController
    func instantiateViewController<T>(_ storyboard:String, _ identifier:String, ofClass: T.Type) -> T{
        let controller = UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: identifier) as? T
        return controller!
    }
    
    //MARK: -ShowLoader
    func showLoader(view:UIView){
        self.indicator = NVActivityIndicatorView(frame: CGRect(x: (view.frame.width/2)-50, y: (view.frame.height/2)-50, width: 100, height: 100), type: .ballRotateChase, color: .black, padding: 10)
        self.indicator?.startAnimating()
        view.addSubview(self.indicator!)
        self.indicator?.bringSubviewToFront( view)
    }
    
    //MARK: -HideLoader
    func hideLoader(){
        self.indicator?.stopAnimating()
    }
    
}

//UI works - you can skip
extension UIView {
    func dropShadows(scale: Bool = true,radius:CGFloat,color:UIColor) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = .zero
        layer.shadowRadius = radius
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    func roundCornersView(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

//MARK: - UICollectionView
extension UICollectionView{
    
    func dequeueXib<T>(_ identifier :String, _ indexPath:IndexPath, _ OfClass :T.Type) -> T{
        self.register(UINib(nibName: identifier, bundle:nil), forCellWithReuseIdentifier: identifier)
        let cell = self.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T
        return cell!
    }
}
