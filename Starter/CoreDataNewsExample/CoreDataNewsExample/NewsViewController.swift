import Alamofire
import Kingfisher
import UIKit

class NewsViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    private var refControl = UIRefreshControl()
    private var model = NewsModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        getData()
    }

    func initView() {
        // Navigation Bar
        UIHelper().setCustomNavigationTitle(title: "CoreDataNewsExample", navItem: navigationItem)
        UIHelper().setNavigationBar(tintColor: .white, navController: navigationController, navItem: navigationItem)
        // TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = .jcRed
        tableView.register(NewsCell.nib, forCellReuseIdentifier: NewsCell.identifier)
        // Pull To Refresh
        refControl.tintColor = .white
        refControl.addTarget(self, action: #selector(handleRefresh(refreshControl:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refControl)
    }

    @objc func handleRefresh(refreshControl: UIRefreshControl) {
        DispatchQueue.global().async {
            // Fake background loading task
            sleep(2)
            // Refresh the data
            self.getData()
            DispatchQueue.main.async {
                refreshControl.endRefreshing()
            }
        }
    }

    func getData() {
        var urlRequest = URLRequest(url: URL(string: "https://raw.githubusercontent.com/johncodeos-blog/CoreDataNewsExample/main/news.json")!)
        urlRequest.cachePolicy = .reloadIgnoringLocalCacheData // We don't want Alamofire to store the data in the memory or disk.
        AF.request(urlRequest).responseDecodable(of: NewsModel.self) { response in
            self.model = response.value!
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.identifier, for: indexPath) as? NewsCell else { fatalError("xib doesn't exist") }
        let currentPost = model[indexPath.row]
        // Thumbnail
        cell.thumbnailImageView.kf.setImage(with: URL(string: currentPost.imageURL!)!, placeholder: nil, options: [.transition(.fade(0.33))])
        // Title
        cell.titleLabel.text = currentPost.title
        // Date
        cell.dateLabel.text = currentPost.date?.iso8601Value()?.timeAgoSinceDate()
        // Source
        cell.sourceLabel.text = "Source: \(currentPost.source ?? "N/A")"
        return cell
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? NewsCell else { fatalError("xib doesn't exist") }
        cell.bgView.backgroundColor = .jcRedVeryDark
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? NewsCell else { fatalError("xib doesn't exist") }
        cell.bgView.backgroundColor = .jcRedDark
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentPost = model[indexPath.row]
        // Open the URL on browser
        UIApplication.shared.open(URL(string: currentPost.url!)!, options: [:], completionHandler: nil)
    }
}
