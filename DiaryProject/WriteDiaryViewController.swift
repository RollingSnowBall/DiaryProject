//
//  WriteDiaryViewController.swift
//  DiaryProject
//
//  Created by JUNO on 2022/04/19.
//

import UIKit

enum DiaryEditMode {
    case new
    case edit(Diary, IndexPath)
}

protocol WriteDiaryViewDelegate : AnyObject {
    func registerDiary(diary: Diary)
}

class WriteDiaryViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    private let datePicker = UIDatePicker()
    private var diaryDate: Date?
    
    weak var delegate: WriteDiaryViewDelegate?
    
    var diaryEditMode: DiaryEditMode = .new
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configDatePicker()
        self.configInputField()
        self.configContentsTextView()
        self.configEditMode()
        self.confirmButton.isEnabled = false
    }
    
    private func configDatePicker(){
        self.datePicker.datePickerMode = .date
        self.datePicker.preferredDatePickerStyle = .wheels
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange), for: .valueChanged)
        self.datePicker.locale = Locale(identifier: "ko_KR")
        self.dateTextField.inputView = self.datePicker
    }
    
    private func configInputField(){
        self.contentsTextView.delegate = self
        self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChanged(_:)), for: .editingChanged)
        self.dateTextField.addTarget(self, action: #selector(dateTextFieldDidChanged(_:)), for: .editingChanged)
    }
    
    private func configContentsTextView(){
        let bordercolor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        self.contentsTextView.layer.borderColor = bordercolor.cgColor
        self.contentsTextView.layer.borderWidth = 0.5
        self.contentsTextView.layer.cornerRadius = 5.0
    }
    
    private func configEditMode(){
        switch self.diaryEditMode {
        case let .edit(diary, _) :
            self.titleTextField.text = diary.title
            self.contentsTextView.text = diary.contents
            self.dateTextField.text = dateToString(date: diary.date)
            self.diaryDate = diary.date
            self.confirmButton.title = "수정"
        
        default :
            break
        }
    }
    
    private func validateInputField(){
        self.confirmButton.isEnabled =
            !(self.titleTextField.text?.isEmpty ?? true)
         && !(self.dateTextField.text?.isEmpty ?? true)
         && !self.contentsTextView.text.isEmpty
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    @IBAction func tapConfirmBtn(_ sender: UIBarButtonItem) {
        guard let title = self.titleTextField.text else { return }
        guard let contents = self.contentsTextView.text else { return }
        guard let date = self.diaryDate else { return }
        
        switch self.diaryEditMode {
        case .new :
            let diary = Diary(
                uuidString: UUID().uuidString,
                title: title,
                contents: contents,
                date: date,
                isStar: false
            )
            self.delegate?.registerDiary(diary: diary)
            
        case let .edit(diary, IndexPath) :
            let diary = Diary(
                uuidString: diary.uuidString,
                title: title,
                contents: contents,
                date: date,
                isStar: diary.isStar
            )
            NotificationCenter.default.post(
                name: NSNotification.Name("editDiary"),
                object: diary,
                //userInfo: ["indexPath.row" : IndexPath.row]
                userInfo: nil
            )
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func datePickerValueDidChange(_ datePicker: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일 (EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        self.diaryDate = datePicker.date
        self.dateTextField.text = formatter.string(from: datePicker.date)
        self.dateTextField.sendActions(for: .editingChanged)
    }
    
    @objc private func titleTextFieldDidChanged(_ textField: UITextField){
        self.validateInputField()
    }
    
    @objc private func dateTextFieldDidChanged(_ textField: UITextView){
        self.validateInputField()
    }

}

extension WriteDiaryViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.validateInputField()
    }
}
