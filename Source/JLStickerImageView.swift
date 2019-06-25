//
//  stickerView.swift
//  stickerTextView
//
//  Created by 刘业臻 on 16/4/20.
//  Copyright © 2016年 luiyezheng. All rights reserved.
//

import UIKit

public class JLStickerImageView: UIImageView, UIGestureRecognizerDelegate {
    public var currentlyEditingLabel: JLStickerLabelView?
    public var labels: [JLStickerLabelView] = []
    private var renderedView: UIView!
    public var isEditing: Bool {
        guard let current = currentlyEditingLabel else { return false}
        return labels.contains(current)
    }
    
    fileprivate lazy var tapOutsideGestureRecognizer: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(JLStickerImageView.tapOutside))
        tapGesture.delegate = self
        return tapGesture

    }()

    // MARK: -

    // MARK: init

    init() {
        super.init(frame: CGRect.zero)
        isUserInteractionEnabled = true
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isUserInteractionEnabled = true
    }
}

// MARK: -

// MARK: Functions

extension JLStickerImageView {
    public func addLabel(_ frame:CGRect? = nil,tag:Int? = nil) {
        if let label: JLStickerLabelView = currentlyEditingLabel {
            label.hideEditingHandlers()
        }

        var frameX = bounds.midX - 50
        var frameY = bounds.midY - 25
        var frameWidth:CGFloat = 100
        var frameHeight:CGFloat = 50
        if let frame = frame {
            frameX = frame.minX
            frameY = frame.minY
            frameWidth = frame.width
            frameHeight = frame.height
        }
        let labelFrame = CGRect(x: frameX,
                                y: frameY,
                                width: frameWidth, height: frameHeight)
        let labelView = JLStickerLabelView(frame: labelFrame)
        if let tag = tag {
            labelView.tag = tag
        }
        labelView.setupTextLabel()
        labelView.delegate = self
        labelView.showsContentShadow = false
        labelView.borderColor = UIColor.white
//        labelView.labelTextView?.fontName = "Roboto-Medium"
        addSubview(labelView)
        currentlyEditingLabel = labelView
        adjustsWidthToFillItsContens(currentlyEditingLabel)
        labels.append(labelView)

        addGestureRecognizer(tapOutsideGestureRecognizer)
    }

    public func addImage(tag:Int? = nil) {
        if let label: JLStickerLabelView = currentlyEditingLabel {
            label.hideEditingHandlers()
        }

        let labelFrame = CGRect(x: bounds.midX - 50,
                                y: bounds.midY - 50,
                                width: 100, height: 100)
        let labelView = JLStickerLabelView(frame: labelFrame)
        if let tag = tag {
            labelView.tag = tag
        }
        labelView.setupImageLabel()
        labelView.showsContentShadow = false
        labelView.borderColor = UIColor.white
        labelView.delegate = self
        addSubview(labelView)
        currentlyEditingLabel = labelView
        adjustsWidthToFillItsContens(currentlyEditingLabel)
        labels.append(labelView)

        addGestureRecognizer(tapOutsideGestureRecognizer)
    }

    public func renderContentOnView() -> UIImage? {
        cleanup()

        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0)

        layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()
        return img
    }

    public func limitImageViewToSuperView() {
        if superview == nil {
            return
        }
        guard let imageSize = self.image?.size else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = true
        let aspectRatio = imageSize.width / imageSize.height

        if imageSize.width > imageSize.height {
            bounds.size.width = superview!.bounds.size.width
            bounds.size.height = superview!.bounds.size.width / aspectRatio
        } else {
            bounds.size.height = superview!.bounds.size.height
            bounds.size.width = superview!.bounds.size.height * aspectRatio
        }
    }

    // MARK: -

    public func cleanup() {
        for label in labels {
            if let isEmpty = label.labelTextView?.text.isEmpty, isEmpty {
                label.closeTap(nil)
            } else {
                label.hideEditingHandlers()
            }
        }
    }
}

// MARK-

// MARK: Gesture

extension JLStickerImageView {
    @objc func tapOutside() {
        currentlyEditingLabel?.hideEditingHandlers()
    }
}

// MARK-

// MARK: stickerViewDelegate

extension JLStickerImageView: JLStickerLabelViewDelegate {
    public func labelViewDidBeginEditing(_: JLStickerLabelView) {
        // labels.removeObject(label)
    }

    public func labelViewDidClose(_ label: JLStickerLabelView) {
        currentlyEditingLabel = nil
        labels.removeAll { $0 == label }
    }

    public func labelViewDidShowEditingHandles(_ label: JLStickerLabelView) {
        currentlyEditingLabel = label
    }

    public func labelViewDidHideEditingHandles(_: JLStickerLabelView) {
        currentlyEditingLabel = nil
    }

    public func labelViewDidStartEditing(_ label: JLStickerLabelView) {
        currentlyEditingLabel = label
    }

    public func labelViewDidChangeEditing(_: JLStickerLabelView) {}

    public func labelViewDidEndEditing(_: JLStickerLabelView) {}

    public func labelViewDidSelected(_ label: JLStickerLabelView) {
        for labelItem in labels {
            labelItem.hideEditingHandlers()
        }
        label.showEditingHandles()
    }
}

// MARK: -

// MARK: Set propeties

extension JLStickerImageView: adjustFontSizeToFillRectProtocol {
    
    public enum TextShadowPropterties {
        case offSet(CGSize)
        case color(UIColor)
        case blurRadius(CGFloat)
    }

    public var fontName: String! {
        set {
            if currentlyEditingLabel != nil {
                currentlyEditingLabel?.labelTextView?.fontName = newValue
                adjustsWidthToFillItsContens(currentlyEditingLabel)
            }
        }
        get {
            return currentlyEditingLabel?.labelTextView?.fontName
        }
    }

    public var textColor: UIColor! {
        set {
            if currentlyEditingLabel != nil {
                currentlyEditingLabel?.labelTextView?.foregroundColor = newValue
            }
        }
        get {
            return currentlyEditingLabel?.labelTextView?.foregroundColor
        }
    }
    
    public var text: String! {
        set {
            if currentlyEditingLabel != nil {
                currentlyEditingLabel?.labelTextView?.text = newValue
                adjustsWidthToFillItsContens(currentlyEditingLabel)
            }
        }
        get {
            return currentlyEditingLabel?.labelTextView?.text
        }
    }
    
    public var font: UIFont! {
        set {
            if currentlyEditingLabel != nil {
                currentlyEditingLabel?.labelTextView?.font = newValue
                adjustsWidthToFillItsContens(currentlyEditingLabel)
            }
        }
        get {
            return currentlyEditingLabel?.labelTextView?.font
        }
    }

    public var textAlpha: CGFloat! {
        set {
            if currentlyEditingLabel != nil {
                currentlyEditingLabel?.labelTextView?.textAlpha = newValue
            }
        }
        get {
            return currentlyEditingLabel?.labelTextView?.textAlpha
        }
    }

    // MARK: -

    // MARK: text Format

    public var textAlignment: NSTextAlignment! {
        set {
            if currentlyEditingLabel != nil {
                currentlyEditingLabel?.labelTextView?.alignment = newValue
            }
        }
        get {
            return currentlyEditingLabel?.labelTextView?.alignment
        }
    }

    public var lineSpacing: CGFloat! {
        set {
            if currentlyEditingLabel != nil {
                currentlyEditingLabel?.labelTextView?.lineSpacing = newValue
                adjustsWidthToFillItsContens(currentlyEditingLabel)
            }
        }
        get {
            return currentlyEditingLabel?.labelTextView?.lineSpacing
        }
    }

    // MARK: -

    // MARK: text Background

    public var textBackgroundColor: UIColor! {
        set {
            if currentlyEditingLabel != nil {
                currentlyEditingLabel?.labelTextView?.textBackgroundColor = newValue
            }
        }

        get {
            return currentlyEditingLabel?.labelTextView?.textBackgroundColor
        }
    }

    public var textBackgroundAlpha: CGFloat! {
        set {
            if currentlyEditingLabel != nil {
                currentlyEditingLabel?.labelTextView?.textBackgroundAlpha = newValue
            }
        }
        get {
            return currentlyEditingLabel?.labelTextView?.textBackgroundAlpha
        }
    }

    // MARK: -

    // MARK: text shadow

    public var textShadowOffset: CGSize! {
        set {
            if currentlyEditingLabel != nil {
                currentlyEditingLabel?.labelTextView?.textShadowOffset = newValue
            }
        }
        get {
            return currentlyEditingLabel?.labelTextView?.shadow?.shadowOffset
        }
    }

    public var textShadowColor: UIColor! {
        set {
            if currentlyEditingLabel != nil {
                currentlyEditingLabel?.labelTextView?.textShadowColor = newValue
            }
        }
        get {
            return (currentlyEditingLabel?.labelTextView?.shadow?.shadowColor) as? UIColor
        }
    }

    public var textShadowBlur: CGFloat! {
        set {
            if currentlyEditingLabel != nil {
                currentlyEditingLabel?.labelTextView?.textShadowBlur = newValue
            }
        }
        get {
            return currentlyEditingLabel?.labelTextView?.shadow?.shadowBlurRadius
        }
    }
}
