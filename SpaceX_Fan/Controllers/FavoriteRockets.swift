//
//  FavoriteRockets.swift
//  SpaceX_Fan
//
//  Created by YeshwantSatya on 04/08/21.
//

import UIKit
import Alamofire
import AlamofireImage
import Firebase

class FavoriteRockets: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableRef: UITableView!
    
    let db = Firestore.firestore()
    
    
    var reuse = ReuseModelClass()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        getMultipleAll()
       
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tableRef.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 150
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return reuse.rocketNameArr.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:RocketsListCell! = tableRef.dequeueReusableCell(withIdentifier: "cell") as? RocketsListCell
        
        
        let nameStr = "Name: "
        let rocketNmStr = reuse.rocketNameArr[indexPath.row] as? String
        cell.rocketName.text = nameStr + rocketNmStr!
        
        let infoStr = "Flight Number: "
        let rocketNumStr = reuse.rocketFlightNumArr[indexPath.row] as? String
        cell.flightNum.text = infoStr + rocketNumStr!
        
        
        AF.request(reuse.imgArr[indexPath.row] as! String).responseData { (response) in
            
            if let data = response.data {
                cell.tbImgRef.image = UIImage(data: data)
            }
        
            else{
                
                cell.tbImgRef.image = UIImage(named: "NoImage")
                
            }
        
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "RocketDetails") as? RocketDetails
        vc?.idStr = (reuse.idArr[indexPath.row] as? String)!
        
        self.navigationController?.pushViewController(vc!, animated: false)
        
    }
    
 
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    private func getMultipleAll() {
        // [START get_multiple_all]
        db.collection("rockets").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    
                    if  (document.data()["image"] != nil) {
                        
                        self.reuse.imgArr . append(document.data()["image"] as! NSString)
                        
                        
                        
                    }

                    if  (document.data()["details"] != nil) {
                        
                        self.reuse.rocketDetailsArr .append(document.data()["details"] as! NSString)
                        
                        
                        
                    }
                    
                    else{
                        
                        
                        self.reuse.rocketDetailsArr .append("No details about this rocket")
                        
                    }
                    
                    self.reuse.idArr .append(document.data()["id"] as! NSString)
                    
                    self.reuse.rocketNameArr .append(document.data()["name"] as! NSString)
                    self.reuse.rocketFlightNumArr . append(document.data()["fligtNumber"] as! NSString)

      
                }
                
                self.tableRef.reloadData()
            }
        }

    }
    
}
