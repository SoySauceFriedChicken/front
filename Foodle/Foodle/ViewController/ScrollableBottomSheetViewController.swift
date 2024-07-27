
import UIKit

class ScrollableBottomSheetViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var targetIndex: Int?
    var newMeeting: Meeting?
    
    @IBAction func addPlaceToList(_ sender: UIButton) {
        targetIndex = sender.tag
        performSegue(withIdentifier: "addPlaceToList", sender: nil)
    }
    
    @IBAction func addMeetingPlace(_ sender: UIButton) {
        NotificationCenter.default.post(name: .meetingPlaceAdded, object: nil, userInfo: ["placeToMeet":resultPlaces[sender.tag]])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPlaceToList"{
            if let vc = segue.destination as? AddPlaceViewController{
                if let targetIndex{
                    vc.place = resultPlaces[targetIndex]
                }
            }
        } else if segue.identifier == "showDetail"{
            if let vc = segue.destination as? DetailPlaceViewController{
                if let targetIndex{
                    vc.place = resultPlaces[targetIndex]
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(forName: .placeAdded, object: nil, queue: .main) { _ in
            self.tableView.reloadData()
        }
        
    }
    
}

extension ScrollableBottomSheetViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultTableViewCell") as! ResultTableViewcell
        let target = resultPlaces[indexPath.row]
        if target.getIsStarred(){
            cell.starButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            cell.starButton.setImage(UIImage(systemName: "star"), for: .normal)
        }
        if newMeeting != nil{
            cell.addMeetingPlaceButton.isHidden = false
        } else {
            cell.addMeetingPlaceButton.isHidden = true
        }
        cell.addressLabel.text = target.address
        cell.breakLabel.text = "휴일 " + target.close
        cell.distanceLabel.text = target.distance
        cell.isOpenLabel.text = target.isWorking
        cell.placeCategoryLabel.text = target.category
        cell.placeNameLabel.text = target.placeName
        
        if let imageUrlString = target.images?.first {
            cell.placeImageView.setImageFromStringURL(imageUrlString)
        }
        
        cell.starButton.tag = indexPath.row
        cell.addMeetingPlaceButton.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        targetIndex = indexPath.row
        performSegue(withIdentifier: "showDetail", sender: nil)
    }
    
}

extension Notification.Name{
    static let meetingPlaceAdded = Notification.Name("meetingPlaceAdded")
}
