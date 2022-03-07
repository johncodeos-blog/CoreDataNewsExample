import CoreData
import Foundation

public extension NewsPosts {
    @nonobjc class func fetchRequest() -> NSFetchRequest<NewsPosts> {
        return NSFetchRequest<NewsPosts>(entityName: "NewsPosts")
    }

    @NSManaged var date: String?
    @NSManaged var image: String?
    @NSManaged var source: String?
    @NSManaged var title: String?
    @NSManaged var postID: Int32
    @NSManaged var url: String?

    internal class func createOrUpdate(item: NewsModelItem, with stack: CoreDataStack) {
        let newsItemID = item.id
        var currentNewsPost: NewsPosts? // Entity name
        let newsPostFetch: NSFetchRequest<NewsPosts> = NewsPosts.fetchRequest()
        if let newsItemID = newsItemID {
            let newsItemIDPredicate = NSPredicate(format: "%K == %i", #keyPath(NewsPosts.postID), newsItemID)
            newsPostFetch.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [newsItemIDPredicate])
        }
        do {
            let results = try stack.managedContext.fetch(newsPostFetch)
            if results.isEmpty {
                // News post not found, create a new.
                currentNewsPost = NewsPosts(context: stack.managedContext)
                if let postID = newsItemID {
                    currentNewsPost?.postID = Int32(postID)
                }
            } else {
                // News post found, use it.
                currentNewsPost = results.first
            }
            currentNewsPost?.update(item: item)
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }

    internal func update(item: NewsModelItem) {
        // Title
        self.title = item.title
        // Thumbnail
        self.image = item.imageURL
        // Date
        self.date = item.date
        // Source
        self.source = item.source
        // Post URL
        self.url = item.url
    }
}

extension NewsPosts: Identifiable {}
