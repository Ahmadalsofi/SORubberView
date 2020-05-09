
import UIKit
import SORubberView

struct AppModel {
    var name: String
    var iconName: String
}

class ViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rubberView: SORubberView!
    @IBOutlet weak var rubberViewHeight: NSLayoutConstraint!
    
    var collapsedHeight: CGFloat = 46
    var expandableHeight: CGFloat = 126
    var backgroundColor: UIColor = .clear
    var animateDurationTime: TimeInterval = 0.4
    
    let data: [AppModel] = [AppModel(name: "Car \n dummy", iconName: "car"),
                            AppModel(name: "airplane \n dummy", iconName: "airplane"),
                            AppModel(name: "fly \n dummy", iconName: "fly"),
                            AppModel(name: "motorbike \n dummy", iconName: "motorbike"),
                            AppModel(name: "ship \n dummy", iconName: "ship"),
                            AppModel(name: "van \n dummy", iconName: "van")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rubberView.delegate = self
        rubberView.dataSource = self
        rubberView.reloadView()
        rubberView.rubberViewHeightConstraint = self.rubberViewHeight
    }
}

extension ViewController: SORubberViewDelegate, SORubberViewDataSource  {
    func animationStatus(_ rubberViewSection: SORubberViewSection, viewStatus: SORubberViewStatus) {
        let rubberView = rubberViewSection as! CategoryRubberViewCell
        switch viewStatus {
        case .collapsed:
            rubberView.nameLbl.alpha = 0
            rubberView.iconLeadingConstraint.priority = UILayoutPriority(999)
            rubberView.iconCenterXConstraint.priority = UILayoutPriority(1000)
        case .expandable:
            rubberView.nameLbl.alpha = 1
            rubberView.iconCenterXConstraint.priority = UILayoutPriority(999)
            rubberView.iconLeadingConstraint.priority = UILayoutPriority(1000)
        }
    }
    
    func didSelectSection(_ rubberViewSection: SORubberViewSection, at section: Int) {
        
    }
    
    func numberOfSections(_ rubberView: SORubberView) -> Int {
        return data.count
    }
    func viewForSection(_ rubberView: SORubberView, section: Int) -> SORubberViewSection {
        let cell =  CategoryRubberViewCell()
        cell.setupCell(obj: data[section])
        return cell
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id")
        let view = cell?.viewWithTag(1)
        view?.layer.cornerRadius = 5
        view?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard tableView.contentSize.height - self.view.frame.height > expandableHeight else { return }
        if (0 < scrollView.contentOffset.y) {
            self.rubberView.animate(.collapsed)
        } else {
            self.rubberView.animate(.expandable)
        }
    }
}
