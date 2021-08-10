//
//  RocketDetails.swift
//  SpaceX_Fan
//
//  Created by YeshwantSatya on 04/08/21.
//

import UIKit
import Alamofire
import AlamofireImage

class RocketDetails: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableRef: UITableView!
    @IBOutlet var colVw: UICollectionView!
    
    @IBOutlet weak var pageView: UIPageControl!
    
    var timer = Timer()
    var counter = 0
    
    var idStr = String ()
    var urlStr = String ()
    
    var rocketName = String ()
    var rocketDetails = String()
    var rocketFlightNum = String ()
    var colImgArr = [Any]()
    
    
    
    @objc func changeImage () {
        
        if counter < colImgArr.count {
            
            let index = IndexPath.init(item: counter, section: 0)
            self.colVw .scrollToItem(at: index, at: .centeredHorizontally, animated: true)
            counter += 1
            pageView.currentPage = counter
        }
        
        else {
            
            counter = 0
            let index = IndexPath.init(item: counter, section: 0)
            self.colVw .scrollToItem(at: index, at: .centeredHorizontally, animated: true)
            pageView.currentPage = counter
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlStr = "https://api.spacexdata.com/v4/launches/" + idStr
        
        print(urlStr)
        
        getRocketDetailsService()
        

        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 150
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:RocketsListCell! = tableRef.dequeueReusableCell(withIdentifier: "cell") as? RocketsListCell
        
        let nameStr = "Name: "
        let rocketNmStr = self.rocketName
        cell.rocketName.text = nameStr + rocketNmStr


        let infoStr = "Flight Number: "
        let rocketNumStr = self.rocketFlightNum
        cell.flightNum.text = infoStr + rocketNumStr

        
        
        return cell
    }
    

    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func getRocketDetailsService() {
        
        AF.request(urlStr).responseJSON { response in
            
            print(response)
            
            if let value = response.value {
                
                print(value)
                
                
                let dict = value as! NSDictionary
                
                self.rocketName = (dict["name"] as! NSString) as String
                
                
                let str = dict["flight_number"] as! NSNumber
                self.rocketFlightNum = str.stringValue
                
                
                let linksDict = dict["links"] as! NSDictionary
                let patchDict = linksDict["flickr"] as! NSDictionary
                
                
                let imgArr = patchDict["original"] as! NSArray
                
                print(imgArr.count)
                
                
                
                if  (imgArr.count != 0) {
                    
                    self.colImgArr.append(contentsOf: imgArr)
                    
                    
                }
                

                self.pageView.numberOfPages = self.colImgArr.count
                self.pageView.currentPage = 0
                
                DispatchQueue.main.async {
                    //
                    self.timer = Timer.scheduledTimer(timeInterval: 2.0, target:self , selector: #selector(self.changeImage), userInfo: nil, repeats: true)
                    
                    
                    self.tableRef.reloadData()
                    self.colVw.reloadData()
                    
                }
                
                
            }
            
            
        }
        
        
        
    }
    
}



extension RocketDetails: UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        if (colImgArr.count == 0) {
            
            return 1
        }
        else {
            
            return colImgArr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell:RocketDetailsCell! = colVw
            .dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? RocketDetailsCell
        
        
        if (cell.viewWithTag(111) as? UIImageView) != nil {
            
            if (colImgArr.count == 0) {
                cell.imgVw.image = UIImage(named: "NoImage")
            }
            else {
                
                
                AF.request(self.colImgArr[indexPath.row] as! String).responseImage { response in
                    if let image = response.data {
                        DispatchQueue.main.async {
                            cell.imgVw.image = UIImage(data: image)
                            cell.imgVw.setNeedsLayout()
                        }
                    }
                }
       
            }
        }
        
        else if let pgVw = cell.viewWithTag(222) as? UIPageControl {
            
            pgVw.currentPage = indexPath.row
            
        }
        
        
        return cell
        
        
    }
}

extension RocketDetails:UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize (width: colVw.bounds.size.width, height: colVw.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets (top: 0, left: 0, bottom: 0, right: 0)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0.0
    }
    
}




