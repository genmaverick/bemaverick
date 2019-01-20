//
//  MaverickDatePicker.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 1/24/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

protocol MaverickDatePickerDelegate {
    func didOpenDropdown()
    func didSelectDropdownItem(category: DateType, value: String)
}

public enum DateType {
    case day
    case month
    case year
}

class MaverickDatePicker : UIView {
    
    
    
    // MARK: - IBOutlets
    
    /// Main View
    @IBOutlet weak var view: UIView!
    /// horizontal stackview with labels/buttons
    @IBOutlet weak var dateButtonStackView: UIStackView!
    ///picker for dat/month/year
    @IBOutlet var pickerContainer: UIView!
    /// Constraint that activates/deactivates based on picker visibility
    @IBOutlet weak var datePickerContainerBottomConstraint: NSLayoutConstraint!
    /// Constraint that activates/deactivates based on picker visibility
    @IBOutlet weak var dateButtonStackViewBottomConstraint: NSLayoutConstraint!
    /// Constraint that reflects the x position of the selected drop down
    @IBOutlet weak var pickerLeadingConstraint: NSLayoutConstraint!
    /// Constraint that reflects the width position of the selected drop down
    @IBOutlet weak var pickerWidthConstraint: NSLayoutConstraint!
    /// the actual picker view
    @IBOutlet weak var pickerView: UIPickerView!
    /// label for the date picker
    @IBOutlet weak var pickerLabel: UILabel!
    /// Selected value for month
    @IBOutlet weak var selectedMonthLabel: UILabel!
    /// Selected value for year
    @IBOutlet weak var selectedYearLabel: UILabel!
    /// Selected value for day
    @IBOutlet weak var selectedDayLabel: UILabel!
    /// Month view used for styling rounded border
    @IBOutlet weak var monthContainer: UIControl!
    /// Year view used for styling rounded border
    @IBOutlet weak var yearContainer: UIControl!
    /// Day view used for styling rounded border
    @IBOutlet weak var dayContainer: UIControl!
    
    // MARK: - IBActions
    
    
    /**
     Called when month field is tapped, open picker there
     */
    @IBAction func birthMonthPressed(_ sender: Any) {
        
        birthType = .month
        pickerLabel.text = "Month"
        pickerWidthConstraint.constant = (selectedMonthLabel.superview?.superview?.frame.width)!
        let point = selectedMonthLabel.convert(selectedMonthLabel.frame.origin, to: view)
        pickerLeadingConstraint.constant = point.x - 15
        resetPicker()
        if selectedMonthIndex >= 0 {
            
            pickerView.selectRow(selectedMonthIndex, inComponent: 0, animated: false)
        
        } else {
            
            pickerView.selectRow(6, inComponent: 0, animated: false)
        
        }
        
    }
    
    /**
     Called when year field is tapped, open picker there
     */
    @IBAction func birthYearPressed(_ sender: Any) {
        
        birthType = .year
        pickerLabel.text = "Year"
        pickerWidthConstraint.constant = (selectedYearLabel.superview?.superview?.frame.width)!
        let point = selectedYearLabel.convert(selectedYearLabel.frame.origin, to: view)
        pickerLeadingConstraint.constant = point.x - 15
        
        resetPicker()
        if selectedYearIndex >= 0 {
            
            pickerView.selectRow(selectedYearIndex, inComponent: 0, animated: false)
     
        } else {
            
            pickerView.selectRow(numberOfYears - 10, inComponent: 0, animated: false)
        
        }
    
    }
    
    /**
     Called when day field is tapped, open picker there
     */
    @IBAction func birthDayPressed(_ sender: Any) {
        
        birthType = .day
        pickerLabel.text = "Day"
        pickerWidthConstraint.constant = (selectedDayLabel.superview?.superview?.frame.width)!
        let point = selectedDayLabel.convert(selectedDayLabel.frame.origin, to: view)
        pickerLeadingConstraint.constant = point.x - 15
        resetPicker()
        if selectedDayIndex >= 0 {
            
            pickerView.selectRow(selectedDayIndex, inComponent: 0, animated: false)
        
        } else {
            
            pickerView.selectRow( 10, inComponent: 0, animated: false)
        
        }
        
    }

    // MARK: - Public Properties
    
    public var delegate: MaverickDatePickerDelegate? = nil
    
    // MARK: - Private Properties
    /// enum to track what is being selected from picker
    private var birthType: DateType = .day
    /// Selected Year Row
    private var selectedYearIndex = -1
    /// Selected Month Row
    private var selectedMonthIndex = -1
    /// Selected Day Row
    private var selectedDayIndex = -1
    
    /// List of months
    private let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    /// dictionary of days in month
    private let
    daysInMonth = ["January" : 31, "February" : 29, "March" : 31, "April" : 30, "May" : 31, "June" : 30, "July" : 31, "August" : 31, "September" : 30, "October" : 31, "November" : 30, "December" : 31]
    
    /// how far back picker should go in years
    private var numberOfYears = 80
    
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    func instanceFromNib() -> UIView {
        return R.nib.maverickDatePicker.firstView(owner: self)!
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        configureView()
        
    }
    
    private func setup() {
        view = instanceFromNib()
        addSubview(view)
        view.frame = self.bounds
        view.backgroundColor = UIColor.clear
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    
    // MARK: - Public Methods
    
    /**
     Validate fields and return date if valid
     */
    public func getSelectedDate() -> Date? {
        
        guard validateFields() else { return nil }
        let c = NSDateComponents()
        c.year = Int(selectedYearLabel.text ?? "0") ?? 0
        c.month = selectedMonthIndex + 1
        c.day =  Int(selectedDayLabel.text ?? "0") ?? 0
        
        // Get NSDate given the above date components
        return NSCalendar(identifier: NSCalendar.Identifier.gregorian)?.date(from: c as DateComponents)
        
    }
    
    // MARK: - Private Methods
    
    /**
     Check for filled fields, color red if not selected
     */
    private func validateFields() -> Bool {
        
        var allFieldsValid = true
        if selectedYearIndex < 0 {
            
            yearContainer.layer.borderColor = UIColor.red.cgColor
            allFieldsValid = false
       
        } else {
            
            yearContainer.layer.borderColor = UIColor.maverickGrey.cgColor
        
        }
        if selectedDayIndex < 0 {
            
            dayContainer.layer.borderColor = UIColor.red.cgColor
            allFieldsValid = false
        
        } else {
            
            dayContainer.layer.borderColor = UIColor.maverickGrey.cgColor
       
        }
        if selectedMonthIndex < 0 {
            
            monthContainer.layer.borderColor = UIColor.red.cgColor
            allFieldsValid = false
       
        } else {
            
            monthContainer.layer.borderColor = UIColor.maverickGrey.cgColor
        
        }
        
        return allFieldsValid
    
    }
    
    /**
     Utility function to reload picker for new values and display
    */
    private func resetPicker() {
        
        datePickerContainerBottomConstraint.isActive = true
        dateButtonStackViewBottomConstraint.isActive = false
        pickerView.setNeedsLayout()
        pickerView.reloadAllComponents()
        delegate?.didOpenDropdown()
        
    }
    
   
    /**
     Initialize Views
     */
    private func configureView() {
        
        styleTextViewBorder(monthContainer)
        styleTextViewBorder(yearContainer)
        styleTextViewBorder(dayContainer)
        pickerWidthConstraint.constant = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(pickerTapped(tapRecognizer:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        pickerView.addGestureRecognizer(tap)
        pickerContainer.layer.borderColor = UIColor.maverickGrey.cgColor
        pickerContainer.layer.borderWidth = 1.0
        pickerContainer.layer.cornerRadius = 22
        
    }
    
    /**
     Utility function to draw border around field
     */
    private func styleTextViewBorder(_ inputView: UIView) {
        
        inputView.layer.borderColor = UIColor.maverickGrey.cgColor
        inputView.layer.borderWidth = 1.0
        inputView.layer.cornerRadius = inputView.frame.height / 2
        
    }
    
    /**
     Fired when an item in the picker is tapped, determines if tap is on selected
     item and then dismisses picker and sets value to the field
     */
    @objc private func pickerTapped(tapRecognizer:UITapGestureRecognizer)
    {
        
        if (tapRecognizer.state == UIGestureRecognizerState.ended)
        {
            
            let rowHeight : CGFloat  = self.pickerView.rowSize(forComponent: 0).height
            let selectedRowFrame = self.pickerView.bounds.insetBy(dx: 0, dy: (self.pickerView.frame.height - rowHeight) / 2.0)
            let userTappedOnSelectedRow = (selectedRowFrame.contains(tapRecognizer.location(in: pickerView)))
            if (userTappedOnSelectedRow)
            {
                
                let selectedRow = self.pickerView.selectedRow(inComponent: 0)
                switch birthType {
                    
                case .month:
                    selectedMonthLabel.text = valueForRow(row: selectedRow)
                    selectedMonthIndex = selectedRow
                    monthContainer.layer.borderColor = UIColor.maverickGrey.cgColor
                case .day:
                    selectedDayLabel.text = valueForRow(row: selectedRow)
                    selectedDayIndex = selectedRow
                    dayContainer.layer.borderColor = UIColor.maverickGrey.cgColor
                case .year:
                    selectedYearLabel.text = valueForRow(row: selectedRow)
                    selectedYearIndex = selectedRow
                    yearContainer.layer.borderColor = UIColor.maverickGrey.cgColor
               
                }
                
                self.pickerWidthConstraint.constant = 0
                self.datePickerContainerBottomConstraint.isActive = false
                self.dateButtonStackViewBottomConstraint.isActive = true
                self.pickerView.setNeedsLayout()
                delegate?.didSelectDropdownItem(category: birthType, value: valueForRow(row: selectedRow))
                
            }
            
        }
        
    }
    
}

// MARK: - Extensions

extension MaverickDatePicker : UIPickerViewDelegate, UIPickerViewDataSource {
    
    private func valueForRow(row: Int, dateType: DateType? = nil) -> String {
        
        var type = birthType
        if let dateType = dateType { type = dateType }
        let date = Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        
        switch type {
            
        case .month:
            return months[row]
        case .day:
            return String(row + 1)
        case .year:
            return String(year - (numberOfYears - row))
            
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pickerLabel = view as? UILabel;
        
        if (pickerLabel == nil)
        {
            
            pickerLabel = UILabel()
            pickerLabel?.font = R.font.openSansRegular(size: 16.0)
            pickerLabel?.textAlignment = NSTextAlignment.center
            
        }
        
        pickerLabel?.text = valueForRow(row: row)
        return pickerLabel!
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch birthType {
            
        case .month:
            return 12
        case .day:
            if selectedMonthIndex >= 0, let days = daysInMonth[months[selectedMonthIndex]] {
                
                return days
                
            } else { return 31 }
        case .year:
            return numberOfYears
            
        }
        
    }

}

extension MaverickDatePicker : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
        
    }
    
}
