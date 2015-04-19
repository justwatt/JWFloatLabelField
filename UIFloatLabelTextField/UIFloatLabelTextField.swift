//
//  UIFloatLabelTextField.swift
//  Created by Justin Watt on 02.02.15
//  Copyright (c) 2015 Justin Watt. All rights reserved.
//

import UIKit

class UIFloatLabelTextField: UITextField {
  
  // The floating label that is displayed above the text field when there is other
  // text in the text field.
  var floatingLabel = UILabel(frame: CGRectMake(0, 0, 0, 0))

  // The color of the floating label displayed above the text field when it is in
  // an active state (i.e. the associated text view is first responder).
  @IBInspectable var activeTextColorfloatingLabel : UIColor = UIColor.blueColor() {
    didSet {
      floatingLabel.textColor = activeTextColorfloatingLabel
    }
  }

  // The color of the floating label displayed above the text field when it is in
  // an inactive state
  @IBInspectable var inactiveTextColorfloatingLabel : UIColor = UIColor(white: 0.8, alpha: 1.0) {
    didSet {
      floatingLabel.textColor = inactiveTextColorfloatingLabel
    }
  }
  
  // Used to cache the placeholder string.
  var cachedPlaceholder = NSString()
  

  // Used to draw the placeholder string if necessary. Starting value is true.
  var shouldDrawPlaceholder = true
  
  //Default padding for floatingLabel
  var verticalPadding : CGFloat = 0
  var horizontalPadding : CGFloat = 0
  
  
  // Initializer
  // Programmatic Initializer
  
  override convenience init(frame: CGRect) {
    self.init(frame: frame)
    setup()
  }
  
  //Nib Initializer
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  // Unsupported Initializers
  init () {
    fatalError("Using the init() initializer directly is not supported. use init(frame:) instead")
  }
  
  // Deinit
  deinit {
    // remove observer
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  
  // Setter & Getter
  override var placeholder : String? {
    get {
      return super.placeholder
    }
    set (newValue) {
      super.placeholder = newValue
      if (cachedPlaceholder != newValue) {
        cachedPlaceholder = newValue!
        floatingLabel.text = self.cachedPlaceholder as String
        floatingLabel.sizeToFit()
      }
    }
  }
  
  override func hasText() ->Bool {
    return !text.isEmpty
  }
  
  // Setup
  func setup() {
    setupObservers()
    setupFloatingLabel()
    applyFonts()
    setupViewDefaults()
  }
  
  func setupObservers() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector:"textFieldTextDidChange:", name: UITextFieldTextDidChangeNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "fontSizeDidChange:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector:"textFieldTextDidBeginEditing:", name: UITextFieldTextDidBeginEditingNotification, object: self)
    NSNotificationCenter.defaultCenter().addObserver(self, selector:"textFieldTextDidEndEditing:", name: UITextFieldTextDidEndEditingNotification, object: self)
  }
  
  func setupFloatingLabel() {
    // Create the floating label instance and add it to the view
    floatingLabel.alpha = 1
    floatingLabel.center = CGPointMake(horizontalPadding, verticalPadding)
    addSubview(floatingLabel)
    
    // Setup default colors for the floating label states
    floatingLabel.textColor = inactiveTextColorfloatingLabel
    floatingLabel.alpha = 0
    
  }
  
  func applyFonts() {
    floatingLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
    
    let textStyle = self.font.fontDescriptor().fontAttributes()["NSCTFontUIUsageAttribute"] as! String
    font = UIFont.preferredFontForTextStyle(textStyle)
  }
  
  func setupViewDefaults() {
    
    // Set vertical padding
    verticalPadding = 0.5 * CGRectGetHeight(self.frame)
    
    // Make sure placeholder setter methods are called
    if let ph = placeholder {
      placeholder = ph
    } else {
      placeholder = ""
    }
  }
  
  // - Drawing & Animations
  override func layoutSubviews() {
    super.layoutSubviews()
    if (isFirstResponder() && !hasText()) {
      hideFloatingLabel()
    } else if(hasText()) {
      showFloatingLabelWithAnimation(true)
    }
  }
  
  func showFloatingLabelWithAnimation(isAnimated : Bool)
  {
    let fl_frame = CGRectMake(
      horizontalPadding,
      0,
      CGRectGetWidth(self.floatingLabel.frame),
      CGRectGetHeight(self.floatingLabel.frame)
    )
    if (isAnimated) {
      let options = UIViewAnimationOptions.BeginFromCurrentState | UIViewAnimationOptions.CurveEaseOut
      UIView.animateWithDuration(0.2, delay: 0, options: options, animations: {
        self.floatingLabel.alpha = 1
        self.floatingLabel.frame = fl_frame
        }, completion: nil)
    } else {
      self.floatingLabel.alpha = 1
      self.floatingLabel.frame = fl_frame
    }
  }
  
  func hideFloatingLabel () {
    let fl_frame = CGRectMake(
      horizontalPadding,
      verticalPadding,
      CGRectGetWidth(self.floatingLabel.frame),
      CGRectGetHeight(self.floatingLabel.frame)
    )
    let options = UIViewAnimationOptions.BeginFromCurrentState |
      UIViewAnimationOptions.CurveEaseIn
    UIView.animateWithDuration(0.1, delay: 0, options: options, animations: {
      self.floatingLabel.alpha = 0
      self.floatingLabel.frame = fl_frame
      }, completion: nil
    )
  }

  
  // Auto Layout
  override func intrinsicContentSize() -> CGSize {
    return sizeThatFits(frame.size)
  }

  // Adds padding so these text fields align with B68FloatingPlaceholderTextView's
  override func textRectForBounds (bounds :CGRect) -> CGRect
  {
    return UIEdgeInsetsInsetRect(super.textRectForBounds(bounds), floatingLabelInsets())
  }
  
  // Adds padding so these text fields align with B68FloatingPlaceholderTextView's
  override func editingRectForBounds (bounds : CGRect) ->CGRect
  {
    return UIEdgeInsetsInsetRect(super.editingRectForBounds(bounds), floatingLabelInsets())
  }
  
  // Helpers
  func floatingLabelInsets() -> UIEdgeInsets {
    floatingLabel.sizeToFit()
    return UIEdgeInsetsMake(
      floatingLabel.font.lineHeight,
      horizontalPadding,
      0,
      horizontalPadding)
  }
  
  
  // Observers
  func textFieldTextDidChange(notification : NSNotification) {
    let previousShouldDrawPlaceholderValue = shouldDrawPlaceholder
    shouldDrawPlaceholder = !hasText()
    
    // Only redraw if self.shouldDrawPlaceholder value was changed
    if (previousShouldDrawPlaceholderValue != shouldDrawPlaceholder) {
      if (self.shouldDrawPlaceholder) {
        hideFloatingLabel()
      } else {
        showFloatingLabelWithAnimation(true)
      }
    }
  }
  // TextField Editing Observer
  func textFieldTextDidEndEditing(notification : NSNotification) {
    if (hasText())  {
      floatingLabel.textColor = inactiveTextColorfloatingLabel
    }
  }
  
  func textFieldTextDidBeginEditing(notification : NSNotification) {
    floatingLabel.textColor = activeTextColorfloatingLabel
  }
  // Font Size Change Oberver
  func fontSizeDidChange (notification : NSNotification) {
    applyFonts()
    invalidateIntrinsicContentSize()
    setNeedsLayout()
  }
  
}
