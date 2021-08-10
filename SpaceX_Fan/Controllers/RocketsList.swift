//
//  RocketsList.swift
//  SpaceX_Fan
//
//  Created by YeshwantSatya on 04/08/21.
//

import UIKit
import Alamofire
import AlamofireImage
import Firebase
import LocalAuthentication


class RocketsList: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    let db = Firestore.firestore()
    var reuse = ReuseModelClass()
    
    enum AuthenticationState {
        
        case loggedin, loggedout
    }
    
    var context = LAContext()
    var state = AuthenticationState.loggedout
    
    var tag = Int ()
    
    @IBOutlet weak var tableRef: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reuse.urlStr = "https://api.spacexdata.com/v4/launches/"
        getRocketsListService()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        tableRef.rowHeight = 130
        tableRef.estimatedRowHeight = UITableView.automaticDimension
        tableRef.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    
    private func setDocument() {


            db.collection("rockets").document("list").setData([
                "name": reuse.rocketNameArr[tag],
                "fligtNumber": reuse.rocketFlightNumArr[tag],
                "image": reuse.imgArr[tag],
                "id":reuse.idArr[tag]
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
            
        }
    
    private func setData() {
        let data: [String: Any] = [:]

        db.collection("rockets").document("new-rocket-id").setData(data)

    }
    
    private func addDocument() {
        
        var ref: DocumentReference? = nil
        ref = db.collection("rockets").addDocument(data: [
            "name": reuse.rocketNameArr[tag],
            "fligtNumber": reuse.rocketFlightNumArr[tag],
            "image": reuse.imgArr[tag],
            "id":reuse.idArr[tag]
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
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
        
       
        
        cell.likeBtn.addTarget(self, action: #selector(connected(sender:)), for: .touchUpInside)
        cell.likeBtn.tag = indexPath.row
        
        AF.request(reuse.imgArr[indexPath.row] as! String).responseData { (response) in

                
                // Show the downloaded image:
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
    
    
    
    
    @objc func connected(sender: UIButton){
        
        
        if sender.isSelected == true
        {
            
            sender.setImage(UIImage (systemName: "bookmark"), for: .normal)
            
            sender.isSelected = false

            
        }
        
        else
        
        {
            sender.setImage(UIImage (systemName: "bookmark.fill"), for: .normal)
            sender.isSelected = true
            
            tag = sender.tag
    
            setDocument ()
            addDocument()

            
        }
     
        authenticationAlert()
        
    }
    
    
    
    func authenticationAlert()
    {
        
        
        let ac = UIAlertController(title: "Authentication", message: " ", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Email", style: .default, handler: {action in
            
            Auth.auth().signIn(withEmail: self.reuse.email, password:self.reuse.password) { (authresultdata, error) in
                if let err = error
                {
                    self.showAlert(message: err.localizedDescription)
                    
                    Auth.auth().createUser(withEmail: self.reuse.email, password: self.reuse.password, completion: { (resultdata, error) in
                        if let err = error
                        {
                            self.accountCreated(message: err.localizedDescription)
                        }
                        else
                        {
                            self.accountCreated(message: "Account Created")
                            
                        }
                        
                    })
                    
                }
                else
                {
                    self.showAlert(message: "Success")
                }
            }
            
        }))
        ac.addAction(UIAlertAction(title: "FaceID", style: .default, handler: {action in
            
            if self.state == .loggedin {
   
                
            }
            
            else {

                self.context = LAContext()
                
                self.context.localizedCancelTitle = "Enter Username/Password"
                
                // First check if we have the needed hardware support.
                var error: NSError?
                if self.context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                    
                    let reason = "Log in to your account"
                    self.context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
                        
                        if success {
                            
                            
                            DispatchQueue.main.async { [unowned self] in
                                self.state = .loggedin
                            }
                            
                        } else {
                            print(error?.localizedDescription ?? "Failed to authenticate")
                            
                            
                        }
                    }
                } else {
                    print(error?.localizedDescription ?? "Can't evaluate policy")
                    
                }
            }
            
        }))
        
        present(ac, animated: true, completion: nil)
    }
    
    
    
    func showAlert(message: String)
    {
        let ac = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(ac, animated: true, completion: nil)
    }
    
    
    func accountCreated(message: String)
    {
        let ac = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(ac, animated: true, completion: nil)
    }
    
    
    
    
    func getRocketsListService() {
        
        AF.request(reuse.urlStr).responseJSON { response in
            
            print(response)
            
            if let value = response.value {
                
                print(value)
                
                let arr = value as! NSArray
                
                print(arr.count)
                
                for i in (0..<arr.count).reversed() {
                    
                    let dict = arr [i] as! NSDictionary
                    
                    self.reuse.rocketNameArr .append(dict["name"] as! NSString)
                    self.reuse.idArr .append(dict["id"] as! NSString)
                    
                    let str = dict["flight_number"] as! NSNumber
                    self.reuse.rocketFlightNumArr .append(str.stringValue)
                    
                   
                    let linksDict = dict["links"] as! NSDictionary
                    let patchDict = linksDict["patch"] as! NSDictionary
                    
                    
                    if  (patchDict["small"] is NSNull) {
                        
                        self.reuse.imgArr .append(" ")
                        
                    }
                    
                    else{
                        
                        self.reuse.imgArr .append(patchDict["small"] as? NSString ?? String())
                        
                        
                        
                        
                    }
   
                }
                
                self.tableRef.reloadData()
                
            }
   
        }
        
    }

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
