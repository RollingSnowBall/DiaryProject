//
//  ViewController.swift
//  DiaryProject
//
//  Created by JUNO on 2022/04/19.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var diaryList = [Diary](){
        didSet{
            self.saveDiaryList()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configCollectionView()
        loadDiaryList()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editDiaryUpdateNotification(_:)),
            name: NSNotification.Name("editDiary"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(starDairyNotification(_:)),
            name: NSNotification.Name("starDiary"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deleteDiaryNotification(_:)),
            name: NSNotification.Name("deleteDiary"),
            object: nil
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let writeDiaryViewController = segue.destination as? WriteDiaryViewController {
            writeDiaryViewController.delegate = self
        }
    }
    
    private func configCollectionView(){
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    private func loadDiaryList(){
        let userDefualt = UserDefaults.standard
        
        guard let data = userDefualt.object(forKey: "diaryList") as? [[String: Any]] else { return }
        
        self.diaryList = data.compactMap{
            guard let uuidString = $0["uuidString"] as? String else { return nil}
            guard let title = $0["title"] as? String else { return nil }
            guard let contents = $0["contents"] as? String else { return nil }
            guard let date = $0["date"] as? Date else { return nil }
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            
            return Diary(uuidString: uuidString,title: title, contents: contents, date: date, isStar: isStar)
         }
        
        self.diaryList = self.diaryList.sorted(by: {$0.date.compare($1.date) == .orderedDescending})
    }
    
    private func saveDiaryList(){
        let data = self.diaryList.map {
            [
                "uuidString" : $0.uuidString,
                "title" : $0.title,
                "contents" : $0.contents,
                "date" : $0.date,
                "isStar" : $0.isStar
            ]
        }
        
        let userDefault = UserDefaults.standard
        userDefault.set(data, forKey: "diaryList")
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy??? MM??? dd???(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    @objc private func editDiaryUpdateNotification(_ notification: Notification){
        guard let diary = notification.object as? Diary else { return }
        //guard let row = notification.userInfo?["indexPath.row"] as? Int else { return }
        guard let idx = self.diaryList.firstIndex(where: { $0.uuidString == diary.uuidString}) else { return }
        
        //self.diaryList[row] = diary
        self.diaryList[idx] = diary
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        self.collectionView.reloadData()
    }
    
    @objc private func starDairyNotification(_ noti: Notification){
        guard let starDiary = noti.object as? [String: Any] else { return }
        guard let isStar = starDiary["isStar"] as? Bool else { return }
        //guard let indexPath = starDiary["indexPath"] as? IndexPath else { return }
        guard let uuidString = starDiary["uuidString"] as? String else { return }
        
        guard let idx = self.diaryList.firstIndex(where: { $0.uuidString == uuidString}) else { return }
        
        self.diaryList[idx].isStar = isStar
    }
    
    @objc private func deleteDiaryNotification(_ noti: Notification){
        //guard let indexPath = noti.object as? IndexPath else { return }
        guard let uuidString = noti.object as? String else { return }
        guard let idx = self.diaryList.firstIndex(where: { $0.uuidString == uuidString}) else { return }
        
        self.diaryList.remove(at: idx)
        self.collectionView.reloadData()
        //self.collectionView.deleteItems(at: [IndexPath(row: idx, section: 0)])
    }
}

extension ViewController : WriteDiaryViewDelegate {
    func registerDiary(diary: Diary) {
        self.diaryList.append(diary)
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        self.collectionView.reloadData()
    }
}

extension ViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
        
        let diary = self.diaryList[indexPath.row]
        viewController.diary = diary
        viewController.indexPath = indexPath
        //viewController.delegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diaryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else { return UICollectionViewCell() }
        
        let diary = self.diaryList[indexPath.row]
        cell.titleLabel.text = diary.title
        cell.dateLabel.text = dateToString(date: diary.date)
        
        return cell
    }
}

extension ViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: 200)
    }
}

extension ViewController : DiaryFunctionDelegate {
//    func didSelectDelete(indexPath: IndexPath) {
//        self.diaryList.remove(at: indexPath.row)
//        self.collectionView.deleteItems(at: [indexPath])
//    }
    
//    func didSelectStar(indexPath: IndexPath, isStar: Bool) {
//        self.diaryList[indexPath.row].isStar = isStar
//    }
}
