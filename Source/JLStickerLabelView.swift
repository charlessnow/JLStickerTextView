//
//  JLStickerLabelView.swift
//  stickerTextView
//
//  Created by 刘业臻 on 16/4/19.
//  Copyright © 2016年 luiyezheng. All rights reserved.
//

import UIKit

public class JLStickerLabelView: UIView {
    var offset: CGSize!

    //MARK: -
    //MARK: Gestures
    
    fileprivate lazy var moveGestureRecognizer: UIPanGestureRecognizer! = {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(JLStickerLabelView.moveGesture(_:)))
        panRecognizer.delegate = self
        return panRecognizer
    }()
    
    fileprivate lazy var singleTapShowHide: UITapGestureRecognizer! = {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(JLStickerLabelView.contentTapped(_:)))
        tapRecognizer.delegate = self
        return tapRecognizer
    }()
    
    fileprivate lazy var closeTap: UITapGestureRecognizer! = {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: (#selector(JLStickerLabelView.closeTap(_:))))
        tapRecognizer.delegate = self
        return tapRecognizer
    }()
    
    fileprivate lazy var panRotateGesture: UIPanGestureRecognizer! = {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(JLStickerLabelView.rotateViewPanGesture(_:)))
        panRecognizer.delegate = self
        return panRecognizer
    }()
    
    fileprivate lazy var pinchRotateGesture: UIPinchGestureRecognizer! = {
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(JLStickerLabelView.pinchViewPanGesture(_:)))
        pinchRecognizer.delegate = self
        return pinchRecognizer
    }()
    
    //MARK: -
    //MARK: properties
    
    fileprivate var lastTouchedView: JLStickerLabelView?
    
    var delegate: JLStickerLabelViewDelegate?
    
    fileprivate var globalInset: CGFloat?
    
    fileprivate var initialBounds: CGRect?
    fileprivate var initialDistance: CGFloat?
    
    fileprivate var beginningPoint: CGPoint?
    fileprivate var beginningCenter: CGPoint?
    
    fileprivate var touchLocation: CGPoint?
    
    fileprivate var deltaAngle: CGFloat?
    fileprivate var beginBounds: CGRect?
    
    public var border: CAShapeLayer?
    public var labelTextView: JLAttributedTextView?
    public var rotateView: UIImageView?
    public var closeView: UIImageView?
    public var imageView: UIImageView?
    
    fileprivate var isShowingEditingHandles = true
    
    public var borderColor: UIColor? {
        didSet {
            border?.strokeColor = borderColor?.cgColor
        }
    }
    
    public var maxStringCount = INTMAX_MAX 
    
    
    //MARK: -
    //MARK: Set Control Buttons
    
    public var enableClose: Bool = true {
        didSet {
            closeView?.isHidden = enableClose
            closeView?.isUserInteractionEnabled = enableClose
        }
    }
    public var enableRotate: Bool = true {
        didSet {
            rotateView?.isHidden = enableRotate
            rotateView?.isUserInteractionEnabled = enableRotate
        }
    }
    public var enableMoveRestriction: Bool = true {
        didSet {
            
        }
    }
    public var showsContentShadow: Bool = false {
        didSet {
            if showsContentShadow {
                self.layer.shadowColor = UIColor.black.cgColor
                self.layer.shadowOffset = CGSize(width: 0, height: 5)
                self.layer.shadowOpacity = 1.0
                self.layer.shadowRadius = 4.0
            }else {
                self.layer.shadowColor = UIColor.clear.cgColor
                self.layer.shadowOffset = CGSize.zero
                self.layer.shadowOpacity = 0.0
                self.layer.shadowRadius = 0.0
            }
        }
    }
    
    //MARK: -
    //MARK: didMoveToSuperView
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.superview != nil {
            self.showEditingHandles()
            self.refresh()
        }
        
    }
    
    //MARK: -
    //MARK: init
    
    init() {
        super.init(frame: CGRect.zero)
//        setup()
//        adjustsWidthToFillItsContens(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if frame.size.width < 25 {
            self.bounds.size.width = 25
        }
        
        if frame.size.height < 25 {
            self.bounds.size.height = 25
        }
        
//        self.setup()
//        adjustsWidthToFillItsContens(self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        setup()
//        adjustsWidthToFillItsContens(self)
        
    }
    
    public override func layoutSubviews() {
        if labelTextView != nil {
            border?.path = UIBezierPath(rect: labelTextView!.bounds).cgPath
            border?.frame = labelTextView!.bounds
        } else if imageView != nil {
            border?.path = UIBezierPath(rect: imageView!.bounds).cgPath
            border?.frame = imageView!.bounds
        }
    }
    
    private func setup() {

        self.setupCloseAndRotateView()
        
        self.addGestureRecognizer(moveGestureRecognizer)
        self.addGestureRecognizer(singleTapShowHide)
        self.addGestureRecognizer(pinchRotateGesture)
        self.moveGestureRecognizer.require(toFail: closeTap)
        
        self.closeView!.addGestureRecognizer(closeTap)
        self.rotateView!.addGestureRecognizer(panRotateGesture)
        
        self.enableMoveRestriction = true
        self.enableClose = true
        self.enableRotate = true
        self.showsContentShadow = true
        
        self.showEditingHandles()
        
        adjustsWidthToFillItsContens(self)
    }
    
    func setupTextLabel() {
        self.globalInset = 19
        
        self.backgroundColor = UIColor.clear
        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.border?.strokeColor = UIColor(red: 33, green: 45, blue: 59, alpha: 1).cgColor
        
        self.setupLabelTextView()
        self.setupBorder()
        
        self.insertSubview(labelTextView!, at: 0)
        
        self.setup()
        
        adjustsWidthToFillItsContens(self)
    }
    
    func setupImageLabel() {
        self.globalInset = 19
        
        self.backgroundColor = UIColor.clear
        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.border?.strokeColor = UIColor(red: 33, green: 45, blue: 59, alpha: 1).cgColor
        
        self.setupImageView()
        self.setupBorder()
        
        self.insertSubview(imageView!, at: 0)
        
        self.setup()
        
        var viewFrame = self.bounds
        viewFrame.size.width = 100
        viewFrame.size.height = 100
        self.bounds = viewFrame
    }
}

//MARK: -
//MARK: labelTextViewDelegate

extension JLStickerLabelView: UITextViewDelegate {
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if (isShowingEditingHandles) {
            return true
        }
        return false
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        
        if let delegate: JLStickerLabelViewDelegate = delegate {
            if delegate.responds(to: #selector(JLStickerLabelViewDelegate.labelViewDidStartEditing(_:))) {
                delegate.labelViewDidStartEditing!(self)
            }
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (!isShowingEditingHandles) {
            self.showEditingHandles()
        }
        if let selectedRange = textView.markedTextRange {
            
            let position = textView.position(from: selectedRange.start, offset: 0)
            if  position != nil {
                let startOffset = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
                let endOffset = textView.offset(from: textView.beginningOfDocument, to: selectedRange.end)
                let offsetRange = NSMakeRange(startOffset, endOffset - startOffset)
                if (offsetRange.location < maxStringCount) {
                    return true
                }else{
                    return false
                }
            }
        }
        
        let contents = ((textView.text) as NSString).replacingCharacters(in: range, with: text)
        let canInputLen = Int(maxStringCount) - contents.count
        if canInputLen >= 0
        {
            labelTextView!.attributedText =   NSAttributedString(string: textView.text, attributes: labelTextView!.textAttributes)
            return true
        }
        else
        {
            let len = text.count + canInputLen
            //            //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
            let rang = NSRange(location: 0, length: max(len, 0))
            if (rang.length > 0) {
                let s = (text as NSString).substring(with: rang)
                //                //超出限制，截取最大长度的内容
                let str = (textView.text as NSString).replacingCharacters(in: range, with: s)
                labelTextView!.attributedText =   NSAttributedString(string: str, attributes: labelTextView!.textAttributes)
                adjustsWidthToFillItsContens(self)
            }
            return false
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        if !textView.text.isEmpty {
            if labelTextView != nil {
                adjustsWidthToFillItsContens(self)
                if let selectedRange = textView.markedTextRange {
                    let position = textView.position(from: selectedRange.start, offset: 0)
                    if  position != nil {
                        return
                    }
                }
                
                //如果在变化中是高亮部分在变，就不要计算字符了
                let textContent = textView.text as NSString
                let existTextNum = textContent.length
                
                if (existTextNum > maxStringCount) {
                    //截取到最大位置的字符
                    let s = textContent.substring(to: Int(maxStringCount))
                    labelTextView!.attributedText =   NSAttributedString(string: s, attributes: labelTextView!.textAttributes)
                } else {
                    labelTextView!.attributedText =   NSAttributedString(string: textView.text, attributes: labelTextView!.textAttributes)
                }
                
                adjustsWidthToFillItsContens(self)
            }
        }
    }
}
//MARK: -
//MARK: GestureRecognizer

extension JLStickerLabelView: UIGestureRecognizerDelegate, adjustFontSizeToFillRectProtocol {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == singleTapShowHide {
            return true
        }
        return false
    }
    
    
    @objc func contentTapped(_ recognizer: UITapGestureRecognizer) {
        if !isShowingEditingHandles {
            self.showEditingHandles()
            
            if let delegate: JLStickerLabelViewDelegate = delegate {
                delegate.labelViewDidSelected!(self)
            }
        }
        
    }
    
    @objc func closeTap(_ recognizer: UITapGestureRecognizer?) {
        self.removeFromSuperview()
        
        if let delegate: JLStickerLabelViewDelegate = delegate {
            if delegate.responds(to: #selector(JLStickerLabelViewDelegate.labelViewDidClose(_:))) {
                delegate.labelViewDidClose!(self)
            }
        }
    }

    @objc func moveGesture(_ recognizer: UIPanGestureRecognizer) {
        if !isShowingEditingHandles {
            self.showEditingHandles()
            
            if let delegate: JLStickerLabelViewDelegate = delegate {
                delegate.labelViewDidSelected!(self)
            }
        }

//        let transP: CGPoint = recognizer.translation(in: superview)
//
//        // 移动图片控件
//        self.transform = self.transform.translatedBy(x: transP.x, y: transP.y)
//
//        // 复位,表示相对上一次
//        recognizer.setTranslation(CGPoint.zero, in: superview)
//
//        self.touchLocation = recognizer.location(in: self.superview)
        
        self.touchLocation = recognizer.location(in: recognizer.view?.superview)
        guard let view = recognizer.view else {
            return
        }
        switch recognizer.state {
        case .began:
//            beginningPoint = touchLocation
//            beginningCenter = self.center
            
//            self.center = self.estimatedCenter()
            
            offset = CGSize(width: view.center.x - self.touchLocation!.x, height: view.center.y - self.touchLocation!.y)
            // 偏移值 + location值即可做到跟随移动
            beginBounds = self.bounds
            
            if let delegate: JLStickerLabelViewDelegate = delegate {
                delegate.labelViewDidBeginEditing!(self)
            }
            
        case .changed:
//            self.center = self.estimatedCenter()
            center = CGPoint(x: offset.width + touchLocation!.x, y: offset.height + touchLocation!.y)
            
            if let delegate: JLStickerLabelViewDelegate = delegate {
                delegate.labelViewDidChangeEditing!(self)
            }
            
        case .ended:
//            self.center = self.estimatedCenter()
            
            
            if let delegate: JLStickerLabelViewDelegate = delegate {
                delegate.labelViewDidEndEditing!(self)
            }
            
        default:break
            
        }
    }
    
    @objc func pinchViewPanGesture(_ recognizer: UIPinchGestureRecognizer) {
        
        let scale = recognizer.scale
        
        switch recognizer.state {
        case .began:
            initialBounds = bounds
        case .changed:
            let scaleRect = CalculateFunctions.CGRectScale(initialBounds!, wScale: CGFloat(scale), hScale: CGFloat(scale))
            debugPrint(scaleRect)
            if scaleRect.size.width >= (1 + (globalInset ?? 0) * 4), scaleRect.size.height >= (1 + (globalInset ?? 0) * 4), (labelTextView?.text != "" || imageView?.image != nil) {
                //  if fontSize < 100 || CGRectGetWidth(scaleRect) < CGRectGetWidth(self.bounds) {
                if labelTextView?.text != nil, scale < 1, (labelTextView?.fontSize ?? 0) <= 9 {
                    
                } else {
                    let bHeight:CGFloat = UniversalDefine.isPad ? 66 : 44
                    let width =  (((UIScreen.main.bounds.size.height - (UIScreen.main.bounds.size.height*2/7 - 34 + bHeight) - 4))  * 9 / 14) - 40
                    
                    if imageView?.image != nil && scaleRect.size.width < 100 {
                        bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
                        return
                    }
                    
                    if imageView?.image != nil && (scaleRect.size.width >= width || scaleRect.size.height >= width) {
                        bounds = CGRect(x: 0, y: 0, width:  width , height: width )
                        return
                    }
                    
                    if imageView?.image != nil && scaleRect.size.width > UIScreen.main.bounds.size.width {
                        bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width)
                        return
                    }
                    adjustFontSizeToFillRect(scaleRect, view: self)
                    bounds = scaleRect
                    adjustsWidthToFillItsContens(self)
                    refresh()
                }
            }
        case .ended:
            break
        @unknown default:
            break
        }
    }
    
    @objc func rotateViewPanGesture(_ recognizer: UIPanGestureRecognizer) {
        touchLocation = recognizer.location(in: self.superview)
        
        let center = CalculateFunctions.CGRectGetCenter(self.frame)
        
        switch recognizer.state {
        case .began:
            deltaAngle = atan2(touchLocation!.y - center.y, touchLocation!.x - center.x) - CalculateFunctions.CGAffineTrasformGetAngle(self.transform)
            initialBounds = self.bounds
            initialDistance = CalculateFunctions.CGpointGetDistance(center, point2: touchLocation!)
            
            if let delegate: JLStickerLabelViewDelegate = delegate {
                if delegate.responds(to: #selector(JLStickerLabelViewDelegate.labelViewDidBeginEditing(_:))) {
                    delegate.labelViewDidBeginEditing!(self)
                }
            }
            
        case .changed:
         
            let ang = atan2(touchLocation!.y - center.y, touchLocation!.x - center.x)
            
            let angleDiff = deltaAngle! - ang
            transform = CGAffineTransform(rotationAngle: -angleDiff)
            layoutIfNeeded()
            // Finding scale between current touchPoint and previous touchPoint
            let scale = sqrtf(Float(CalculateFunctions.CGpointGetDistance(center, point2: touchLocation!)) / Float(initialDistance!))
            let scaleRect = CalculateFunctions.CGRectScale(initialBounds!, wScale: CGFloat(scale), hScale: CGFloat(scale))
            
            //            print("bounds\(bounds)")
            //            print("ang\(ang)")
            //            print("angleDiff\(angleDiff)")
            //            print("scale\(scale)")
            //            print("scaleRect\(scaleRect)\n")
            
            if scaleRect.size.width >= (1 + (globalInset ?? 0) * 4), scaleRect.size.height >= (1 + (globalInset ?? 0) * 4), (labelTextView?.text != "" || imageView?.image != nil) {
                //  if fontSize < 100 || CGRectGetWidth(scaleRect) < CGRectGetWidth(self.bounds) {
                if labelTextView?.text != nil, scale < 1, (labelTextView?.fontSize ?? 0) <= 9 {} else {
                    let bHeight:CGFloat = UniversalDefine.isPad ? 66 : 44
                    let width =  (((UIScreen.main.bounds.size.height - (UIScreen.main.bounds.size.height*2/7 - 34 + bHeight) - 4))  * 9 / 14) - 40
                    
                    if imageView?.image != nil && scaleRect.size.width < 100 {
                        bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
                        return
                    }
                    
                    if imageView?.image != nil && (scaleRect.size.width >= width || scaleRect.size.height >= width) {
                        bounds = CGRect(x: 0, y: 0, width:  width , height: width )
                        return
                    }
                    
                    if imageView?.image != nil && scaleRect.size.width > UIScreen.main.bounds.size.width {
                        bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width)
                        return
                    }
                    adjustFontSizeToFillRect(scaleRect, view: self)
                    bounds = scaleRect
                    adjustsWidthToFillItsContens(self)
                    refresh()
                }
            }
            
//            let ang = atan2(touchLocation!.y - center.y, touchLocation!.x - center.x)
//
//            let angleDiff = deltaAngle! - ang
//            self.transform = CGAffineTransform(rotationAngle: -angleDiff)
//            self.layoutIfNeeded()
//
//            //Finding scale between current touchPoint and previous touchPoint
//            let scale = sqrtf(Float(CalculateFunctions.CGpointGetDistance(center, point2: touchLocation!)) / Float(initialDistance!))
//            let scaleRect = CalculateFunctions.CGRectScale(initialBounds!, wScale: CGFloat(scale), hScale: CGFloat(scale))
//
//            if scaleRect.size.width >= (1 + globalInset! * 2) && scaleRect.size.height >= (1 + globalInset! * 2) && self.labelTextView?.text != "" {
//                //  if fontSize < 100 || CGRectGetWidth(scaleRect) < CGRectGetWidth(self.bounds) {
//                if scale < 1 && (labelTextView?.fontSize ?? 0) <= 9 {
//
//                }else {
//                    self.adjustFontSizeToFillRect(scaleRect, view: self)
//                    self.bounds = scaleRect
//                    self.adjustsWidthToFillItsContens(self)
//                    self.refresh()
//                }
//            }
            
            if let delegate: JLStickerLabelViewDelegate = delegate {
                if delegate.responds(to: #selector(JLStickerLabelViewDelegate.labelViewDidChangeEditing(_:))) {
                    delegate.labelViewDidChangeEditing!(self)
                }
            }
        case .ended:
            if let delegate: JLStickerLabelViewDelegate = delegate {
                if delegate.responds(to: #selector(JLStickerLabelViewDelegate.labelViewDidEndEditing(_:))) {
                    delegate.labelViewDidEndEditing!(self)
                }
            }
            
            self.refresh()
            
        //self.adjustsWidthToFillItsContens(self, labelView: labelTextView)
        default:break
            
        }
    }
}

//MARK: -
//MARK: setup
extension JLStickerLabelView {
    private func setupLabelTextView() {
        labelTextView = JLAttributedTextView(frame: self.bounds.insetBy(dx: globalInset!, dy: globalInset!))
        labelTextView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        labelTextView?.clipsToBounds = true
        labelTextView?.delegate = self
        labelTextView?.backgroundColor = UIColor.clear
        labelTextView?.tintColor = UIColor(red: 33, green: 45, blue: 59, alpha: 1)
        labelTextView?.isScrollEnabled = false
        labelTextView?.isSelectable = true
        labelTextView?.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private func setupBorder() {
        border = CAShapeLayer(layer: layer)
        border?.strokeColor = borderColor?.cgColor
        border?.fillColor = nil
        border?.lineDashPattern = [10, 2]
        border?.lineWidth = 1
        
    }
    
    private func setupCloseAndRotateView() {
        closeView = UIImageView(frame: CGRect(x: 0, y: 0, width: globalInset! * 2 - 6, height: globalInset! * 2 - 6))
        closeView?.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        closeView?.contentMode = .scaleAspectFit
        closeView?.clipsToBounds = true
        closeView?.backgroundColor = UIColor.clear
        closeView?.isUserInteractionEnabled = true
        self.addSubview(closeView!)
        
        rotateView = UIImageView(frame: CGRect(x: self.bounds.size.width - globalInset! * 2, y: self.bounds.size.height - globalInset! * 2, width: globalInset! * 2 - 6, height: globalInset! * 2 - 6))
        rotateView?.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        rotateView?.backgroundColor = UIColor.clear
        rotateView?.clipsToBounds = true
        rotateView?.contentMode = .scaleAspectFit
        rotateView?.isUserInteractionEnabled = true
        self.addSubview(rotateView!)
    }
    
    private func setupImageView() {
        imageView = UIImageView(frame: self.bounds.insetBy(dx: globalInset!, dy: globalInset!))
        imageView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView?.contentMode = .scaleAspectFit
        imageView?.clipsToBounds = true
        imageView?.backgroundColor = UIColor.clear
    }
}


//MARK: -
//MARK: Help funcitons
extension JLStickerLabelView {
    
    fileprivate func refresh() {
        if let superView: UIView = self.superview {
            let transform: CGAffineTransform = superView.transform
            let scale = CalculateFunctions.CGAffineTransformGetScale(transform)
            let t = CGAffineTransform(scaleX: scale.width, y: scale.height)
            self.closeView?.transform = t.inverted()
            self.rotateView?.transform = t.inverted()
            
            if (isShowingEditingHandles) {
                if let border: CALayer = border {
                    self.labelTextView?.layer.addSublayer(border)
                    self.imageView?.layer.addSublayer(border)
                }
            }else {
                border?.removeFromSuperlayer()
            }
        }
    }
    
    public func hideEditingHandlers() {
        lastTouchedView = nil
        
        isShowingEditingHandles = false
        
        if enableClose {
            closeView?.isHidden = true
        }
        if enableRotate {
            rotateView?.isHidden = true
        }
        
        labelTextView?.resignFirstResponder()
        
        self.refresh()
        
        if let delegate : JLStickerLabelViewDelegate = delegate {
            if delegate.responds(to: #selector(JLStickerLabelViewDelegate.labelViewDidHideEditingHandles(_:))) {
                delegate.labelViewDidHideEditingHandles!(self)
            }
        }
    }
    
    public func showEditingHandles() {
        lastTouchedView?.hideEditingHandlers()
        
        isShowingEditingHandles = true
        
        lastTouchedView = self
        
        if enableClose {
            closeView?.isHidden = false
        }
        
        if enableRotate {
            rotateView?.isHidden = false
        }
        
        self.refresh()
        
        if let delegate: JLStickerLabelViewDelegate = delegate {
            if delegate.responds(to: #selector(JLStickerLabelViewDelegate.labelViewDidShowEditingHandles(_:))) {
                delegate.labelViewDidShowEditingHandles!(self)
            }
        }
    }
    
    fileprivate func estimatedCenter() -> CGPoint{
        let newCenter: CGPoint!
        var newCenterX = beginningCenter!.x + (touchLocation!.x - beginningPoint!.x)
        var newCenterY = beginningCenter!.y + (touchLocation!.y - beginningPoint!.y)
        
        if (enableMoveRestriction) {
            if (!(newCenterX - 0.5 * self.frame.width > 0 &&
                newCenterX + 0.5 * self.frame.width < self.superview!.bounds.width)) {
                newCenterX = self.center.x;
            }
            if (!(newCenterY - 0.5 * self.frame.height > 0 &&
                newCenterY + 0.5 * self.frame.height < self.superview!.bounds.height)) {
                newCenterY = self.center.y;
            }
            newCenter = CGPoint(x: newCenterX, y: newCenterY)
        }else {
            newCenter = CGPoint(x: newCenterX, y: newCenterY)
        }
        return newCenter
    }
}

//MARK: -
//MARK: delegate


@objc public protocol JLStickerLabelViewDelegate: NSObjectProtocol {
    /**
     *  Occurs when a touch gesture event occurs on close button.
     *
     *  @param label    A label object informing the delegate about action.
     */
    @objc optional func labelViewDidClose(_ label: JLStickerLabelView) -> Void
    /**
     *  Occurs when border and control buttons was shown.
     *
     *  @param label    A label object informing the delegate about showing.
     */
    @objc optional func labelViewDidShowEditingHandles(_ label: JLStickerLabelView) -> Void
    /**
     *  Occurs when border and control buttons was hidden.
     *
     *  @param label    A label object informing the delegate about hiding.
     */
    @objc optional func labelViewDidHideEditingHandles(_ label: JLStickerLabelView) -> Void
    /**
     *  Occurs when label become first responder.
     *
     *  @param label    A label object informing the delegate about action.
     */
    @objc optional func labelViewDidStartEditing(_ label: JLStickerLabelView) -> Void
    /**
     *  Occurs when label starts move or rotate.
     *
     *  @param label    A label object informing the delegate about action.
     */
    @objc optional func labelViewDidBeginEditing(_ label: JLStickerLabelView) -> Void
    /**
     *  Occurs when label continues move or rotate.
     *
     *  @param label    A label object informing the delegate about action.
     */
    @objc optional func labelViewDidChangeEditing(_ label: JLStickerLabelView) -> Void
    /**
     *  Occurs when label ends move or rotate.
     *
     *  @param label    A label object informing the delegate about action.
     */
    @objc optional func labelViewDidEndEditing(_ label: JLStickerLabelView) -> Void
    
    @objc optional func labelViewDidSelected(_ label: JLStickerLabelView) -> Void
}
