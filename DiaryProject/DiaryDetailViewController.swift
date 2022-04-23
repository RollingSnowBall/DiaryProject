//
//  DiaryDetailViewController.swift
//  DiaryProject
//
//  Created by JUNO on 2022/04/19.
//

import UIKit

protocol DiaryFunctionDelegate: AnyObject {
    //func didSelectDelete(indexPath: IndexPath)
    //func didSelectStar(indexPath: IndexPath, isStar: Bool)
}

class DiaryDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var starButton: UIBarButtonItem?
    
    weak var delegate: DiaryFunctionDelegate?
    
    var diary: Diary?
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(starDiaryNoti(_:)),
            name: NSNotification.Name("starDiary"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editDiaryUpdateNoti(_:)),
            name: NSNotification.Name("editDiary"),
            object: nil
        )
        
        NotificationCenter.default.post(
            name: NSNotification.Name("deleteDiary"),
            object: self.diary?.uuidString,
            userInfo: nil
        )
    }
    
    private func configView(){
        guard let diary = self.diary else { return }
        
        self.titleLabel.text = diary.title
        self.contentLabel.text = diary.contents
        self.dateLabel.text = dateToString(date: diary.date)
        
        self.starButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(tapStarButton))
        self.starButton?.image = diary.isStar ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        self.starButton?.tintColor = .orange
        self.navigationItem.rightBarButtonItem = self.starButton
    }
    
    @IBAction func tapEditBtn(_ sender: UIButton) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WriteDiaryViewController") as? WriteDiaryViewController else { return }
        
        guard let indexPath = self.indexPath else { return }
        guard let diary = self.diary else { return }
        
        viewController.diaryEditMode = .edit(diary, indexPath)
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func tapDeleteBtn(_ sender: UIButton) {
        //guard let indexPath = self.indexPath else { return }
        guard let uuidString = self.diary?.uuidString else { return }
        
        NotificationCenter.default.post(
            name: NSNotification.Name("deleteDiary"),
            object: uuidString,
            userInfo: nil
        )
        
        //self.delegate?.didSelectDelete(indexPath: indexPath)
        self.navigationController?.popViewController(animated: true)
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    @objc private func tapStarButton(){
        guard let isStar = self.diary?.isStar else { return }
        //guard let indexPath = self.indexPath else { return }
        
        if isStar {
            self.starButton?.image = UIImage(systemName: "star")
        }else{
            self.starButton?.image = UIImage(systemName: "star.fill")
        }
        
        self.diary?.isStar = !isStar
        //self.delegate?.didSelectStar(indexPath: indexPath, isStar: self.diary!.isStar)
        NotificationCenter.default.post(
            name: Notification.Name("starDiary"),
            object: [
                "diary" : self.diary,
                "isStar" : self.diary!.isStar,
                //"indexPath" : indexPath
                "uuidString" : self.diary!.uuidString
            ],
            userInfo: nil)
    }
    
    @objc private func editDiaryUpdateNoti(_ notification: Notification){
        guard let diary = notification.object as? Diary else { return }
        
        self.diary = diary
        self.configView()
    }
    
    @objc private func starDiaryNoti(_ noti: Notification){
        guard let starDiary = noti.object as? [String: Any] else { return }
        guard let isStar = starDiary["isStar"] as? Bool else { return }
        guard let uuidString = starDiary["uuidString"] as? String else { return }
        guard let diary = self.diary else { return }
        
        if diary.uuidString == uuidString {
            self.diary?.isStar = isStar
            self.titleLabel.text = diary.title
            self.contentLabel.text = diary.contents
            self.dateLabel.text = dateToString(date: diary.date)
            self.configView()
        }
        
        //self.diary?.isStar = !isStar
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
}
