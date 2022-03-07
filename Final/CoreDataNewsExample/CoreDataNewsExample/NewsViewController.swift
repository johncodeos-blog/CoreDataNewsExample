import Alamofire
import CoreData
import Kingfisher
import UIKit

class NewsViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    private var refControl = UIRefreshControl()

    lazy var dataProvider: NewsPostsProvider = {
        let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
        let provider = NewsPostsProvider(with: managedContext, fetchedResultsControllerDelegate: self)
        return provider
    }()

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
            self.processFectchedNewsPosts(news: response.value!)
        }
    }

    private func processFectchedNewsPosts(news: NewsModel) {
        for item in news {
            NewsPosts.createOrUpdate(item: item, with: AppDelegate.sharedAppDelegate.coreDataStack)
        }
        AppDelegate.sharedAppDelegate.coreDataStack.saveContext()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataProvider.fetchedResultsController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = dataProvider.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.identifier, for: indexPath) as? NewsCell else { fatalError("xib doesn't exist") }
        let currentPost = dataProvider.fetchedResultsController.object(at: indexPath)
        // Thumbnail
        cell.thumbnailImageView.kf.setImage(with: URL(string: currentPost.image!)!, placeholder: nil, options: [.transition(.fade(0.33))])
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
        let currentPost = dataProvider.fetchedResultsController.object(at: indexPath)
        // Open the URL on browser
        UIApplication.shared.open(URL(string: currentPost.url!)!, options: [:], completionHandler: nil)
    }
}

// MARK: - Fetched Results Delegate

extension NewsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .none)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .none)
        default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .none)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .none)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .none)
            tableView.insertRows(at: [newIndexPath!], with: .none)
        case .update:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.identifier, for: indexPath!) as? NewsCell else { fatalError("xib doesn't exist") }
            let post = dataProvider.fetchedResultsController.object(at: indexPath!)
            // Thumbnail
            cell.thumbnailImageView.kf.setImage(with: URL(string: post.image!)!, placeholder: nil, options: [.transition(.fade(0.33))])
            // Title
            cell.titleLabel.text = post.title
            // Date
            cell.dateLabel.text = post.date?.iso8601Value()?.timeAgoSinceDate()
            // Source
            cell.sourceLabel.text = "Source: \(post.source!)"
        default:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
