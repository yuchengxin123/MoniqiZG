//
//  CustomDatePickerView.swift
//  MoniqiZG
//
//  Created by ycx on 2025/8/25.
//

import UIKit

protocol CustomDatePickerDelegate: AnyObject {
    func datePickerDidConfirm(_ date: String)
}

class CustomDatePickerView: UIView {
    
    enum DateComponent {
        case year
        case month
        case day
        case hour
        case minute
        case second
    }
    
    // MARK: - Properties
    weak var delegate: CustomDatePickerDelegate?
    
    var visibleComponents: [DateComponent] = [.year, .month, .day, .hour, .minute, .second] {
        didSet {
            datePicker.reloadAllComponents()
            setCurrentTimeAsDefault()
        }
    }
    
    private var years: [Int] = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let maxYear:Int =  Int(formatter.string(from: Date())) ?? 2030
        return Array(1900...maxYear)
    }()
    private var months: [Int] = Array(1...12)
    private var days: [Int] = Array(1...31)
    private var hours: [Int] = Array(0...23)
    private var minutes: [Int] = Array(0...59)
    private var seconds: [Int] = Array(0...59)
    
    private lazy var datePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setCurrentTimeAsDefault()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setCurrentTimeAsDefault()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .white
        datePicker.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height - bottomSafeAreaHeight - 40)
        addSubview(datePicker)
        
        let confirmButton = UIButton(frame: CGRect(x: 15, y: self.frame.height - bottomSafeAreaHeight - 40, width: self.frame.width - 30, height: 40))
        confirmButton.setTitle("确认", for: .normal)
        confirmButton.backgroundColor = Main_Color
        confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        addSubview(confirmButton)
        
        ViewRadius(confirmButton, 20)
        setupAppearance()
    }
    
    private func setupAppearance() {
        layer.cornerRadius = 12
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.masksToBounds = true
    }
    
    // MARK: - Public Methods
    func setDefaultDate(_ dateString: String?) {
        guard let dateString = dateString, !dateString.isEmpty else {
            setCurrentTimeAsDefault()
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = dateFormatter.date(from: dateString) {
            setDate(date)
        } else {
            setCurrentTimeAsDefault()
        }
    }
    
    func setDate(_ date: Date) {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        
        for (componentIndex, dateComponent) in visibleComponents.enumerated() {
            switch dateComponent {
            case .year:
                if let index = years.firstIndex(of: year) {
                    datePicker.selectRow(index, inComponent: componentIndex, animated: false)
                }
            case .month:
                if let index = months.firstIndex(of: month) {
                    datePicker.selectRow(index, inComponent: componentIndex, animated: false)
                }
            case .day:
                if let index = days.firstIndex(of: day) {
                    datePicker.selectRow(index, inComponent: componentIndex, animated: false)
                }
            case .hour:
                if let index = hours.firstIndex(of: hour) {
                    datePicker.selectRow(index, inComponent: componentIndex, animated: false)
                }
            case .minute:
                if let index = minutes.firstIndex(of: minute) {
                    datePicker.selectRow(index, inComponent: componentIndex, animated: false)
                }
            case .second:
                if let index = seconds.firstIndex(of: second) {
                    datePicker.selectRow(index, inComponent: componentIndex, animated: false)
                }
            }
        }
    }
    
    func getSelectedDate() -> String {
        var components: [String] = []
        
        for (componentIndex, dateComponent) in visibleComponents.enumerated() {
            let selectedRow = datePicker.selectedRow(inComponent: componentIndex)
            
            switch dateComponent {
            case .year:
                let selectedYear = years[selectedRow]
                components.append(String(format: "%04d", selectedYear))
            case .month:
                let selectedMonth = months[selectedRow]
                components.append(String(format: "%02d", selectedMonth))
            case .day:
                let selectedDay = days[selectedRow]
                components.append(String(format: "%02d", selectedDay))
            case .hour:
                let selectedHour = hours[selectedRow]
                components.append(String(format: "%02d", selectedHour))
            case .minute:
                let selectedMinute = minutes[selectedRow]
                components.append(String(format: "%02d", selectedMinute))
            case .second:
                let selectedSecond = seconds[selectedRow]
                components.append(String(format: "%02d", selectedSecond))
            }
        }
        
        // 根据显示的组件构建日期字符串
        if components.count >= 3 && visibleComponents.contains(.year) && visibleComponents.contains(.month) && visibleComponents.contains(.day) {
            let datePart = components[0..<3].joined(separator: "-")
            let timePart = components.count > 3 ? components[3..<components.count].joined(separator: ":") : ""
            
            if !timePart.isEmpty {
                return "\(datePart) \(timePart)"
            } else {
                return datePart
            }
        } else {
            return components.joined(separator: ":")
        }
    }
    
    // MARK: - Private Methods
    private func setCurrentTimeAsDefault() {
        setDate(Date())
    }
    
    // MARK: - Actions
    @objc private func confirmAction() {
        let selectedDate = getSelectedDate()
        delegate?.datePickerDidConfirm(selectedDate)
    }
}

// MARK: - UIPickerViewDelegate & UIPickerViewDataSource
extension CustomDatePickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return visibleComponents.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let dateComponent = visibleComponents[component]
        switch dateComponent {
        case .year: return years.count
        case .month: return months.count
        case .day: return days.count
        case .hour: return hours.count
        case .minute: return minutes.count
        case .second: return seconds.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let dateComponent = visibleComponents[component]
        let title: String
        
        switch dateComponent {
        case .year: title = "\(years[row])"
        case .month: title = "\(months[row])"
        case .day: title = "\(days[row])"
        case .hour: title = String(format: "%02d", hours[row])
        case .minute: title = String(format: "%02d", minutes[row])
        case .second: title = String(format: "%02d", seconds[row])
        }
        
        let label = creatLabel(CGRect.zero, title, fontMedium(20), Main_TextColor)
        label.backgroundColor = .white
        label.textAlignment = .center
        
        return label
    }
    
//    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
//        let dateComponent = visibleComponents[component]
//        switch dateComponent {
//        case .year: return 80
//        case .month: return 60
//        case .day: return 60
//        case .hour: return 60
//        case .minute: return 60
//        case .second: return 60
//        }
//    }
}
