//
//  KeyboardButton.swift
//  Paperboard
//
//  Created by Igor Zapletnev on 13.12.2020.
//  Copyright © 2020 Exyte. All rights reserved.
//

import UIKit

class KeyboardButton: UIButton {
    var isCompact: Bool = false {
        didSet {
            updateFont()
        }
    }
    var isPressed: Bool = false
    var defaultBackgroundColor: UIColor = .white
    var highlightBackgroundColor: UIColor = .lightGray
    var originalFontSize: CGFloat = -1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
      super.layoutSubviews()
      backgroundColor = isHighlighted || isPressed ? highlightBackgroundColor : defaultBackgroundColor
    }
    
    func commonInit() {
        layer.cornerRadius = 5.0
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.shadowRadius = 0.0
        layer.shadowOpacity = 0.35
        if let titleLabel = titleLabel {
            originalFontSize = titleLabel.font.pointSize
        }
        
        updateFont()
    }
    
    func updateFont() {
        if let titleLabel = titleLabel {
            titleLabel.font = titleLabel.font.withSize(isCompact ? 20 : originalFontSize)
        }
    }
}
