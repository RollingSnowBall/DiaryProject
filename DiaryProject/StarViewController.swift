//
//  StarViewController.swift
//  DiaryProject
//
//  Created by JUNO on 2022/04/19.
//

import UIKit

class StarViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var diaryList = [Diary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configCollectionView()
        loadStarDiaryList()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editDiaryNoti(_:)),
            name: NSNotification.Name("editDiary"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deleteDiaryNoti(_:)),
            name: NSNotification.Name("deleteDiary"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(starDiaryNoti(_:)),
            name: NSNotification.Name("starDiary"),
            object: nil
        )
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        loadStarDiaryList()
//    }
    
    private func configCollectionView(){
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func loadStarDiaryList(){
        let userDefualt = UserDefaults.standard
        
        guard let data = userDefualt.object(forKey: "diaryList") as? [[String: Any]] else { return }
        self.diaryList = data.compactMap{
            guard let uuidString = $0["uuidString"] as? String else { return nil }
            guard let title = $0["title"] as? String else { return nil }
            guard let contents = $0["contents"] as? String else { return nil }
            guard let date = $0["date"] as? Date else { return nil }
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            
            return Diary(uuidString: uuidString, title: title, contents: contents, date: date, isStar: isStar)
        }.filter({
            $0.isStar == true
        }).sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        
        //self.collectionView.reloadData()
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    @objc func editDiaryNoti(_ noti: Notification){
        guard let diary = noti.object as? Diary else { return }
        //guard let row = noti.userInfo?["indexPath.row"] as? Int else { return }
        guard let idx = self.diaryList.firstIndex(where: { $0.uuidString == diary.uuidString }) else { return }
        
        //self.diaryList[row] = diary
        self.diaryList[idx] = diary
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        
        self.collectionView.reloadData()
    }
    
    @objc func starDiaryNoti(_ noti: Notification){
        guard let starDiary = noti.object as? [String: Any] else { return }
        guard let isStar = starDiary["isStar"] as? Bool else { return }
        //guard let indexPath = starDiary["indexPath"] as? IndexPath else { return }
        guard let uuidString = starDiary["uuidString"] as? String else { return }
        guard let diary = starDiary["diary"] as? Diary else { return }
        
        if isStar{
            self.diaryList.append(diary)
            self.diaryList = self.diaryList.sorted(by: {
                $0.date.compare($1.date) == .orderedDescending
            })
            self.collectionView.reloadData()
        } else {
            guard let idx = self.diaryList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
            self.diaryList.remove(at: idx)
            self.collectionView.reloadData()
            //self.collectionView.deleteItems(at: [IndexPath(row: idx, section: 0)])
        }
    }
    
    @objc func deleteDiaryNoti(_ noti: Notification){
        //guard let indexPath = noti.object as? IndexPath else { return }
        guard let uuidString = noti.object as? String else { return }
        guard let idx = self.diaryList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
        
        self.diaryList.remove(at: idx)
        self.collectionView.reloadData()
        //self.collectionView.deleteItems(at: [IndexPath(row: idx, section: 0)])
    }
}

extension StarViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: UIScreen.main.bounds.width - 20, height: 80)
    }
}

extension StarViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
        
        let diary = self.diaryList[indexPath.row]
        viewController.diary = diary
        viewController.indexPath = indexPath
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension StarViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diaryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StarCell", for: indexPath) as? StarCell else { return UICollectionViewCell() }
        
        let diary = self.diaryList[indexPath.row]
        
        cell.titleLabel.text = diary.title
        cell.dateLabel.text = dateToString(date: diary.date)
        
        return cell
    }
}
