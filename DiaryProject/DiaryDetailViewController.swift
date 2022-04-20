//
//  DiaryDetailViewController.swift
//  DiaryProject
//
//  Created by JUNO on 2022/04/19.
//

import UIKit

protocol DiaryFunctionDelegate: AnyObject {
    func didSelectDelete(indexPath: IndexPath)
}

class DiaryDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    weak var delegate: DiaryFunctionDelegate?
    
    var diary: Diary?
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    private func configView(){
        guard let diary = self.diary else { return }
        
        self.titleLabel.text = diary.title
        self.contentLabel.text = diary.contents
        self.dateLabel.text = dateToString(date: diary.date)
    }
    
    @IBAction func tapEditBtn(_ sender: UIButton) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WriteDiaryViewController") as? WriteDiaryViewController else { return }
        
        guard let indexPath = self.indexPath else { return }
        guard let diary = self.diary else { return }
        
        viewController.diaryEditMode = .edit(diary, indexPath)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editDiaryUpdateNotification(_:)),
            name: NSNotification.Name("editDiary"),
            object: nil
        )
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func tapDeleteBtn(_ sender: UIButton) {
        guard let indexPath = self.indexPath else { return }
        
        self.delegate?.didSelectDelete(indexPath: indexPath)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    @objc private func editDiaryUpdateNotification(_ notification: Notification){
        guard let diary = notification.object as? Diary else { return }
        
        self.diary = diary
        self.configView()
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
}
