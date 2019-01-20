//
//  FilterTextOverlayView.swift
//  BeMaverick
//
//  Created by David McGraw on 10/15/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import SCRecorder
import CoreGraphics

class FilterTextOverlayView: UIView, SCVideoOverlay {
    
    // MARK: - Static
    
    class func instanceFromNib() -> FilterTextOverlayView {
        return R.nib.filterTextOverlayView.firstView(owner: nil)! as FilterTextOverlayView
    }
    
    // MARK: - IBOutlets
    
    /// A view used to draw
    @IBOutlet weak var contentView: UIView!
    
    /// An export of the content contained in the drawing view
    @IBOutlet weak var drawingImageView: UIImageView?
    
    // MARK: - Public Properties
    
    /// The parent editor controller
    weak var parentViewController: PostRecordViewController?
    
    /// Whether the drawing proxy has been initialized or not
    var hasInitDrawingProxy: Bool = false
    
    /// Track the last input field in order to adjust while not under edit
    var lastSelectedInputField: UITextView?
    
    /// An identifier representing the index of the item
    var indexIdentifier: Int = -1
    
    /// A button used to delete an object it's attached to
    var deleteObjectButton: UIButton?
    
    /// The text view under edit
    fileprivate(set) var editingView: UITextView?
    
    /// A view used to draw
    fileprivate(set) var drawingView: JotView?
    
    /// JotView state manager
    fileprivate(set) var paperState: JotViewStateProxy?
    
    /// A view containing doodles, stickers, and other things
    fileprivate(set) var componentsView: UIView?
    
    // MARK: - Private Properties
    
    /// Pan gesture handler
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer?
    
    /// Tap gesture handler
    fileprivate var tapGestureRecognizer: UITapGestureRecognizer?
    
    /// Rotate gesture handler
    fileprivate var rotateGestureRecognizer: UIRotationGestureRecognizer?
    
    /// Pinch gesture handler
    fileprivate var pinchGestureRecognizer: UIPinchGestureRecognizer?
    
    /// The position of the view under edit
    fileprivate var editingContentWithCenter: CGPoint = .zero
    
    /// The transform of the view under edit
    fileprivate var editingContentWithTransform: CGAffineTransform = .identity
    
    /// The view being moved around on the screen
    fileprivate var translatingView: UIView?
    
    /// The position to move the text view to when under edit
    fileprivate var defaultEditingPosition: CGPoint = .zero
    
    /// The active brush type
    fileprivate var brushType: Constants.RecordingBrushType = .brush
    
    /// Brush Styles
    fileprivate var pen: Pen = Pen()
    fileprivate var pencil: Pencil = Pencil()
    fileprivate var eraser: Eraser = Eraser()
    
    /// The pen being used
    fileprivate var activePen: Pen {
        
        switch brushType {
        case .brush:
            return pen
        case .pencil:
            return pencil
        case .erase:
            return eraser
        }
        
    }
    
    /// Basic undo history tracking
    override var undoManager: UndoManager {
        return _undoManager
    }
    
    private let _undoManager: UndoManager = {
        let undoManager = UndoManager()
        return undoManager
    }()
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        configureView()
        
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        initializeDrawingCapability()
        
    }
    
    /**
     Keeps track of the default editing position and updates subviews in the event
     the bounds change.
     */
    override func layoutSublayers(of layer: CALayer) {
        
        super.layoutSublayers(of: layer)
        
        /// Keep the default editing position updated with layout updates
        defaultEditingPosition = CGPoint(x: self.center.x, y: self.center.y - 100.0)
        
    }
    
    // MARK: - Public Methods
    
    func hasEditingContent() -> Bool {
        
        guard let componentsView = componentsView else { return false }
        return componentsView.subviews.count > 0
    
    }
    /**
     Loading saved draft content needs to force text view layout
    */
    open func refreshContentLayout() {
        
        for item in componentsView?.subviews ?? [] {
            
            if let v = item as? UITextView {
                sizeToFit(forTextView: v)
            }
            
        }
        
    }
    
    /**
     Initializes the drawing view and proxy
    */
    open func initializeDrawingCapability() {
        
        if !hasInitDrawingProxy {
            hasInitDrawingProxy = true
            
            drawingView = JotView(frame: bounds)
            drawingView!.delegate = self
            drawingView!.isUserInteractionEnabled = false
            contentView.addSubview(drawingView!)
            contentView.sendSubview(toBack: drawingView!)
            
            reloadJotViewProxy()
            
        }
        
    }
    
    /**
     Removes any items added to the view and clears the existing drawing
    */
    open func reset() {
        
        // Remove items
        for item in componentsView?.subviews.reversed() ?? [] {
            item.removeFromSuperview()
        }
        
        deleteObjectButton = nil
        defaultEditingPosition = CGPoint(x: center.x, y: center.y - 100.0)
        translatingView = nil
        editingView = nil
        
        // Clear drawing
        drawingView!.clear(true)
        drawingView!.setNeedsDisplay()
        reloadJotViewProxy()
        
    }
    
    /**
     Disable drawing for the active overlay
     */
    open func deselectActiveOverlay() {
        toggleDrawingEnabled(enabled: false)
    }
    
    /**
     Creates and adds a new `UITextView` as a subview and immediately brings it into focus
     */
    func insertNewTextField() {
        
        let field = UITextView(frame: CGRect(x: 0, y: 0, width: frame.size.width / 2.0, height: 40))
        field.font = UIFont(name: parentViewController!.defaultFontStyle.fontName, size: 40.0)
        field.spellCheckingType = .no
        field.center = center
        field.clipsToBounds = false
        field.backgroundColor =  .clear
        field.textAlignment = .center
        field.textColor = parentViewController!.defaultColorStyle
        field.tintColor = UIColor.maverickBrightTeal
        field.isScrollEnabled = false
        field.keyboardAppearance = .dark
        field.delegate = self
        field.minimumZoomScale = 0.01
        field.adjustsFontForContentSizeCategory = true
        componentsView!.addSubview(field)
        componentsView!.bringSubview(toFront: field)
        
        sizeToFit(forTextView: field)
        
        field.center = defaultEditingPosition
        field.becomeFirstResponder()
        
        editingView = field
        
        // Register undo
        undoManager.registerUndo(withTarget: self) { this in
            field.removeFromSuperview()
            this.editingView?.resignFirstResponder()
            this.editingView = nil
        }
        undoManager.setActionName("Insert Text Field")
        
    }
    
    /**
     Creates and adds a new `UIImageView` to the overlay that can be moved and scaled
    */
    func insertNewImageView(image: UIImage, stickerName: String?) {
        
        let sticker = UIImageView(image: image)
        
        if let _ = stickerName {
            sticker.accessibilityIdentifier = stickerName
        }
        
        let itemwidth : CGFloat = 128.0
        let itemHeight = itemwidth * image.size.height / image.size.width
        sticker.frame = CGRect(x: 0, y: 0, width: itemwidth, height: itemHeight)
        sticker.center = center
        componentsView!.addSubview(sticker)
        componentsView!.bringSubview(toFront: sticker)
        
        // Register undo
        undoManager.registerUndo(withTarget: self) { this in
            sticker.removeFromSuperview()
        }
        undoManager.setActionName("Insert ImageView")
        
    }
    
    /**
     Toggle whether gestures are enabled
     */
    func toggleGesturesEnabled(enabled: Bool) {
        
        panGestureRecognizer?.isEnabled = enabled
        tapGestureRecognizer?.isEnabled = enabled
        rotateGestureRecognizer?.isEnabled = enabled
        pinchGestureRecognizer?.isEnabled = enabled
        
        drawingView?.isUserInteractionEnabled = !enabled
        componentsView?.isUserInteractionEnabled = enabled
        
        
    }
    
    /**
     Toggle whether drawing is enabled
     */
    func toggleDrawingEnabled(enabled: Bool) {
        
        translatingView = nil
        editingView = nil
        
        lastSelectedInputField = nil
        editingView?.resignFirstResponder()
        
        toggleGesturesEnabled(enabled: !enabled)
        drawingView?.isUserInteractionEnabled = enabled
        componentsView?.isUserInteractionEnabled = !enabled
        
    }
    

    
    /**
     Undo the last stroke for this overlay
     */
    open func undoLastDrawingStroke() {
        drawingView?.undo()
    }
    
    
    /**
     Redo the last known stroke for this overlay
     */
    open func redoLastDrawingStroke() {
        drawingView?.redo()
    }
    
    /**
     Change the brush type and maintain the selected color and size
    */
    open func setDrawingBrushType(type: Constants.RecordingBrushType,
                                  withColor color: UIColor,
                                  size: Constants.RecordingBrushSize) {
        
        brushType = type
        setDrawingPointSize(size: size)
        setDrawingColor(color: color)
        
    }
    
    /**
     Change the size of the active pen
    */
    open func setDrawingPointSize(size: Constants.RecordingBrushSize) {
        activePen.updateSize(size: size)
    }
    
    /**
     Change the color of the active pen
    */
    open func setDrawingColor(color: UIColor) {
        activePen.color = color
    }
    
    /**
     Change the font of the input field
     */
    open func setInputFont(font: UIFont) {
        
        if let v = editingView {
            v.font = font
            sizeToFit(forTextView: v)
        }
        
    }
    
    /**
     Reload the image data used for drawing
     */
    open func reloadJotViewProxy() {
        
        // Ignore any pending edits when replacing a drawing
        if paperState != nil {
            paperState?.isForgetful = true
        }
        
        paperState = JotViewStateProxy(delegate: self)
        paperState!.loadJotStateAsynchronously(true,
                                               with: bounds.size,
                                               andScale: UIScreen.main.scale,
                                               andContext: drawingView!.context,
                                               andBufferManager: JotBufferManager.sharedInstance())
        
    }
        
    // MARK: - Private Methods
    
    /**
     Configures the overlay view with the needed gesture recognizers
     */
    fileprivate func configureView() {
        
        // Improve accuracy
        pen.drawingView = self
        pencil.drawingView = self
        eraser.drawingView = self
        
        isMultipleTouchEnabled = true
        
        defaultEditingPosition = CGPoint(x: self.center.x, y: self.center.y - 100.0)
        
        /// Content view for the additional content
        componentsView = UIView(frame: bounds)
        contentView.addSubview(componentsView!)
        contentView.bringSubview(toFront: componentsView!)
        componentsView?.autoPinEdgesToSuperviewEdges()
        
        /// Configure Object Gestures
        
        /// Begin editing, end editing
        tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                      action: #selector(handleTapGesture(_:)))
        tapGestureRecognizer?.numberOfTapsRequired = 1
        componentsView!.addGestureRecognizer(tapGestureRecognizer!)

        /// Move item
        panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                      action: #selector(handlePanGesture(_:)))
        panGestureRecognizer?.delegate = self
        componentsView!.addGestureRecognizer(panGestureRecognizer!)

        /// Rotate item
        rotateGestureRecognizer = UIRotationGestureRecognizer(target: self,
                                                              action: #selector(handleRotationGesture(_:)))
        rotateGestureRecognizer?.delegate = self
        componentsView!.addGestureRecognizer(rotateGestureRecognizer!)

        /// Pinch Item
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self,
                                                          action: #selector(handlePinchGesture(_:)))
        pinchGestureRecognizer?.delegate = self
        componentsView!.addGestureRecognizer(pinchGestureRecognizer!)
        
    }
    
    /**
     Handle creating a new input view or editing view
     */
    @objc fileprivate func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        
        parentViewController?.tapToTypeHint.isHidden = true
        let mode = parentViewController?.editorOptionsView.mode
        
        if gesture.state == .ended {
            
            if translatingView == nil {
                
                if mode == .text {
                    
                    if editingContentWithCenter == .zero && (editingView?.isFirstResponder ?? false) == false {
                        
                        insertNewTextField()
                        return
                        
                    }
                    
                }
                
            }
            
            if translatingView == nil || (deleteObjectButton?.isHidden ?? false) == false {
                
                let location = gesture.location(in: self)
                detectTranslatingView(withLocation: location)
                
                if let v = translatingView {
                    displayDeleteObjectButton(toView: v)
                }
                
            }
            
            if editingContentWithCenter != .zero && (editingView?.isFirstResponder ?? false) {
                
                adjustPositionWithSpring(forItem: editingView,
                                         position: editingContentWithCenter,
                                         newTransform: editingContentWithTransform)
                
                editingContentWithCenter = .zero
                editingContentWithTransform = .identity
                translatingView = nil
                
            }
            
        }
        parentViewController?.tapToTypeHint.isHidden = componentsView?.subviews.count ?? 0 > 0 || mode != .text
        
        if componentsView?.subviews.count == 1, let textViewToCheck = componentsView?.subviews[0] as? UITextView, textViewToCheck.text.isEmpty {
            
             parentViewController?.tapToTypeHint.isHidden = false
        
        }
        
        endEditing(true)
        
    }
    
    /**
     Handle dragging the view closest to the touch point
     */
    @objc fileprivate func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        
        var location = gesture.location(in: self)
        let velocity = gesture.translation(in: self)
        
        switch gesture.state {
        case .began:
            
            deleteObjectButton?.tag = -1
            deleteObjectButton?.isHidden = true
            detectTranslatingView(withLocation: location)
        
            if let v = translatingView {
                
                editingContentWithCenter = v.center
                
                location = editingContentWithCenter
                location.x += velocity.x
                location.y += velocity.y
            
                setCenter(center: location, ofView: v, centerBeforeUpdate: nil)
                
            }
            
        case .changed:
            
            if let v = translatingView {
                
                location = editingContentWithCenter
                location.x += velocity.x
                location.y += velocity.y
                
                setCenter(center: location, ofView: v, centerBeforeUpdate: nil)
                
            }
            
        case .ended:
            
            if let v = translatingView {
                
                setCenter(center: nil,
                          ofView: v,
                          centerBeforeUpdate: editingContentWithCenter)
                
            }
            
            editingContentWithCenter = .zero
            translatingView = nil
            
        default:
            break
        }
        
    }
    
    /**
     Sets the center of the provided view and adds the action to the undo manager
    */
    fileprivate func setCenter(center: CGPoint?, ofView v: UIView, centerBeforeUpdate: CGPoint?) {
        
        if center != nil {
            adjustPosition(forItem: v, position: center!)
        }
        
        // Add the inverse op to the undo stack
        if centerBeforeUpdate != nil {
            
            undoManager.registerUndo(withTarget: self) { this in
                
                UIView.setAnimationsEnabled(false)
                this.setCenter(center: centerBeforeUpdate!, ofView: v, centerBeforeUpdate: nil)
                UIView.setAnimationsEnabled(true)
                
            }
            undoManager.setActionName("Move")
            
        }

    }
    
    /**
     Handle rotating the view closest to the touch point
     */
    @objc fileprivate func handleRotationGesture(_ gesture: UIRotationGestureRecognizer) {
        
        if gesture.state == .began && translatingView == nil {
            
            deleteObjectButton?.tag = -1
            deleteObjectButton?.isHidden = true
            detectTranslatingView(withLocation: gesture.location(in: self))
            
            if let v = translatingView {
                editingContentWithTransform = v.transform
            }
            
        }
        
        if gesture.state == .changed {
            
            if let view = translatingView {
                
                setViewTransform(transform: view.transform.rotated(by: gesture.rotation),
                                 ofView: view,
                                 transformBeforeUpdate: nil)
                
                gesture.rotation = 0
                
            }
            
        }
        
        if gesture.state == .ended {
            
            if let view = translatingView {
                
                setViewTransform(transform: nil,
                                 ofView: view,
                                 transformBeforeUpdate: editingContentWithTransform)
                
                editingContentWithTransform = .identity
                editingContentWithCenter = .zero
                translatingView = nil
                
            }
            
        }
        
    }
    
    /**
     Handle scaling the view closest to the touch point
     */
    @objc fileprivate func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        
        if gesture.state == .began && translatingView == nil {
            
            deleteObjectButton?.tag = -1
            deleteObjectButton?.isHidden = true
            detectTranslatingView(withLocation: gesture.location(in: self))

            if let v = translatingView {
                editingContentWithTransform = v.transform
            }
            
        }
        
        if gesture.state == .changed {

            if let view = translatingView {
                
                setViewTransform(transform: view.transform.scaledBy(x: gesture.scale, y: gesture.scale),
                                 ofView: view,
                                 transformBeforeUpdate: editingContentWithTransform)
                gesture.scale = 1

            }

        }
        
        if gesture.state == .ended {
            
            if let view = translatingView {
                
                setViewTransform(transform: nil,
                                 ofView: view,
                                 transformBeforeUpdate: editingContentWithTransform)
                
                editingContentWithTransform = .identity
                translatingView = nil
                
            }
            
        }
        
    }
    
    /**
     Sets the transform of the provided view and adds the action to the undo manager
     */
    fileprivate func setViewTransform(transform: CGAffineTransform?, ofView v: UIView, transformBeforeUpdate: CGAffineTransform?) {
        
        if transform != nil {
            v.transform = transform!
        }
        
        if transformBeforeUpdate != nil {
            
            undoManager.registerUndo(withTarget: self) { this in
                
                UIView.setAnimationsEnabled(false)
                this.setViewTransform(transform: transformBeforeUpdate!, ofView: v, transformBeforeUpdate: nil)
                UIView.setAnimationsEnabled(true)
                
            }
            undoManager.setActionName("Transform")
            
        }
        
    }
    
    /**
     Calculate the distance between two points
     */
    fileprivate func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
        
    }
    
    /**
     Detect the view closest to the provided point
     */
    fileprivate func detectTranslatingView(withLocation point: CGPoint) {
        
        for item in componentsView!.subviews.reversed() {
            
            if item is UITextView || item is UIImageView {
                
                let d = distance(point, item.center)
                if d < 50 * abs(item.transform.a) {
                    
                    translatingView = item
                    componentsView!.bringSubview(toFront: item)
                    
                    if let tv = item as? UITextView {
                        editingView = tv
                        lastSelectedInputField = tv
                    }
                    break
                    
                }
            
            }
            
        }
        
    }
    
    /**
     Displays a delete icon on the touched image view
     */
    fileprivate func displayDeleteObjectButton(toView view: UIView) {
        
        // Enable delete for image views only
        guard let _ = view as? UIImageView else { return }
        
        if deleteObjectButton == nil {
            deleteObjectButton = UIButton(type: .custom)
            deleteObjectButton!.setBackgroundImage(R.image.recordDeleteObject(), for: .normal)
            deleteObjectButton!.addTarget(self, action: #selector(handleDeleteObjectTapped(_:)), for: .touchUpInside)
            componentsView!.addSubview(deleteObjectButton!)
        }
        
        var position = CGPoint(x: view.center.x + 50, y: view.center.y - 50)
        if !self.frame.contains(position) {
            position = CGPoint(x: view.center.x - 50, y: position.y)
        }
        
        for s in componentsView!.subviews {
            s.tag = 0
        }
        view.tag = 999
       
        componentsView!.bringSubview(toFront: deleteObjectButton!)
        deleteObjectButton!.isHidden = false
        deleteObjectButton!.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        deleteObjectButton!.center = CGPoint(x: position.x, y: position.y)
        
        
    }
    
    /**
     Removes the object based on the tag of the sender
     */
    @objc fileprivate func handleDeleteObjectTapped(_ sender: Any) {
        
        for subview in componentsView!.subviews {
        
            if subview.tag == 999 {
                translatingView = nil
                editingView = nil
                deleteObjectButton?.isHidden = true
                subview.removeFromSuperview()
                return
            }
            
        }
        
    }
    
    /**
     Adjusts the position of the provided view with a slight animation curve
     */
    fileprivate func adjustPosition(forItem item: UIView?, position: CGPoint) {
        
        UIView.animate(withDuration: 0.1,
                       delay: 0.0,
                       options: [.beginFromCurrentState, .curveLinear],
                       animations:
            {
                item?.center = position
        }, completion: nil)
        
    }
    
    /**
     Adjusts the position of the provided view with a slight animation bounce
     */
    fileprivate func adjustPositionWithSpring(forItem item: UIView?, position: CGPoint, newTransform: CGAffineTransform) {
        
        UIView.animate(withDuration: 0.225,
                       delay: 0.0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.3,
                       options: [.curveLinear],
                       animations:
            {
                
                item?.center = position
                item?.transform = newTransform
                
        }, completion: nil)
        
    }
    
    // MARK: - Overrides
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: -
    
    /**
     Required in order to export with this overlay
     */
    func requiresUpdateOnMainThread(atVideoTime time: TimeInterval, videoSize: CGSize) -> Bool {
        return true
    }
    
    func update(withVideoTime time: TimeInterval) {
        
        for v in subviews {
            v.frame = bounds
        }
        
    }
    
}

extension FilterTextOverlayView: UITextViewDelegate {
    
    /**
     Adjust the text view size when new input is provided
     */
    func textViewDidChange(_ textView: UITextView) {
        
        sizeToFit(forTextView: textView)
        
        textView.center = self.defaultEditingPosition
        
    }
    
    /**
     Allow edit if the option selector is set to text
    */
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return (parentViewController!.editorOptionsView.mode == .text)
    }
    
    /**
     Move the view into editing position
     */
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        componentsView?.bringSubview(toFront: textView)
        
        /// Track view under edit
        editingView = textView
        
        /// Disable gestures while editing
        panGestureRecognizer?.isEnabled = false
        rotateGestureRecognizer?.isEnabled = false
        pinchGestureRecognizer?.isEnabled = false
        
        /// Keep track of original position
        editingContentWithCenter = textView.center
        editingContentWithTransform = textView.transform
        
        /// Move the field to the editing position
        adjustPositionWithSpring(forItem: textView, position: defaultEditingPosition, newTransform: .identity)
        
    }
    
    /**
     Reset the editing views when editing is complete
     */
    func textViewDidEndEditing(_ textView: UITextView) {
        
        lastSelectedInputField = textView
        
        editingContentWithCenter = .zero
        translatingView = nil
        
        if textView.text.isEmpty {
            textView.removeFromSuperview()
        }
        
        /// Enable gestures after editing is complete
        panGestureRecognizer?.isEnabled = true
        rotateGestureRecognizer?.isEnabled = true
        pinchGestureRecognizer?.isEnabled = true
        
    }
    
    /**
     Calculate the size of the text view based on the input and screen size
     */
    fileprivate func sizeToFit(forTextView textView: UITextView) {
       
        let c = textView.center
        let t = textView.transform

        let v = UITextView(frame: textView.frame)
        v.font = textView.font
        
        v.text = textView.text

        let fixedWidth = bounds.size.width - 40
        let newSize = v.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = v.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)

        textView.transform = .identity
        textView.frame = newFrame
        
        textView.setNeedsLayout()
        textView.layoutIfNeeded()
      
        textView.center = c
        textView.transform = t
        
        
    }
    
}

extension FilterTextOverlayView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
}

extension FilterTextOverlayView: JotViewDelegate {
    
    func stepWidthForStroke() -> CGFloat {
        return activePen.stepWidthForStroke()
    }
    
    func supportsRotation() -> Bool {
        return activePen.supportsRotation()
    }
    
    func textureForStroke() -> JotBrushTexture! {
        return activePen.textureForStroke()
    }
    
    func smoothness(forCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) -> CGFloat {
        return activePen.smoothness(forCoalescedTouch: coalescedTouch, from: touch)
    }
    
    func color(forCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) -> UIColor! {
        return activePen.color(forCoalescedTouch: coalescedTouch, from: touch)
    }

    func width(forCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) -> CGFloat {
        return activePen.width(forCoalescedTouch: coalescedTouch, from: touch)
    }
    
    func willAddElements(_ elements: [Any]!, to stroke: JotStroke!, fromPreviousElement previousElement: AbstractBezierPathElement!) -> [Any]! {
        return activePen.willAddElements(elements, to: stroke, fromPreviousElement: previousElement)
    }
    
    func willBeginStroke(withCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) -> Bool {
        _ = activePen.willBeginStroke(withCoalescedTouch: coalescedTouch, from: touch)
        return true
    }
    
    func willMoveStroke(withCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) {
        activePen.willMoveStroke(withCoalescedTouch: coalescedTouch, from: touch)
    }
    
    func willEndStroke(withCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!, shortStrokeEnding: Bool) {
        // noop
    }
    
    func didEndStroke(withCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) {
        activePen.didEndStroke(withCoalescedTouch: coalescedTouch, from: touch)
        
        // Save State
        if let hasEdits = paperState?.hasEditsToSave(), hasEdits == true {
        
            drawingView?.exportImage(to: jotViewStateInkPath,
                                    andThumbnailTo: jotViewStateThumbPath,
                                    andStateTo: jotViewStatePlistPath,
                                    withThumbnailScale: 1.0)
            { (ink, thumbnail, state) in
    
                self.paperState?.wasSaved(at: state)
                
            }
            
        }
        
        // Register undo
        undoManager.registerUndo(withTarget: self) { this in
            this.drawingView?.undoAndForget()
        }
        undoManager.setActionName("End Stroke")
        
    }
    
    func willCancel(_ stroke: JotStroke!, withCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) {
        activePen.willCancel(stroke, withCoalescedTouch: coalescedTouch, from: touch)
    }
    
    func didCancel(_ stroke: JotStroke!, withCoalescedTouch coalescedTouch: UITouch!, from touch: UITouch!) {
        activePen.didCancel(stroke, withCoalescedTouch: coalescedTouch, from: touch)
    }
    
}

extension FilterTextOverlayView: JotViewStateProxyDelegate {

    var documentsDir: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    var jotViewStateInkPath: String! {
        
        let dir = parentViewController!.editorVideoComposition!.directoryPathForDrawing(forIndex: indexIdentifier)
        return dir.appendingPathComponent("ink").appendingPathExtension("png").path
         
    }
    
    var jotViewStatePlistPath: String! {
        
        let dir = parentViewController!.editorVideoComposition!.directoryPathForDrawing(forIndex: indexIdentifier)
        return dir.appendingPathComponent("info").appendingPathExtension("plist").path
        
    }
    
    var jotViewStateThumbPath: String! {
        
        let dir = parentViewController!.editorVideoComposition!.directoryPathForDrawing(forIndex: indexIdentifier)
        return dir.appendingPathComponent("ink.thumb").appendingPathExtension("png").path
        
    }
    
    func didLoadState(_ state: JotViewStateProxy!) {
        
        DispatchQueue.main.async {
            
            self.drawingView!.loadState(self.paperState!)
            
            self.drawingView?.alpha = 0
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                self.drawingView?.alpha = 1.0
            }
            
        }
        
    }
    
    func didUnloadState(_ state: JotViewStateProxy!) {
        
    }
    
    fileprivate func createFileIfNeeded(path: String) {
        
        if !FileManager.default.fileExists(atPath: path) {
            
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch { }
            
        }
            
    }
    
}
