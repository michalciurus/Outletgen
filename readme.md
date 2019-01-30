
#Outletgen Xcode Script

- Tired of dragging and crashing @IBOutlets? 😰
- Want to get rid of dozens of @IBOutlets cluttering your ViewControllers? 🗑
- Want to be cool like the Androids and have type safe auto generated references? 😎

Use this script that will automatically generate view outlets for you! ⚡️

# Installation

## CocoaPods

1. Add `pod 'Outletgen'` to your Podfile 
2. Add `"$PODS_ROOT/Outletgen/Outletgen"` to to your Run Scripts in Xcode.
3. Build and add generated `Outletgen.swift` to your project.

## Manual

1. Drag & Drop `Outletgen` to your project folder.
2. Add `"$SRCROOT/Outletgen"` to to your Run Scripts in Xcode.
3. Build and add generated `Outletgen.swift` to your project.

I'll maybe add it to CocoaPods if y'all are nice enough :)

# Using

Just add a "Restoration ID" to your views in xibs/storyboards and Outletgen will auto generate code for you to use.

## Before

```
class MyVc: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyView: UIScrollView!
    @IBOutlet weak var searchBar: UISearchBar!
   
    override func viewDidLoad() {
        tableView.isHidden = true
        activityIndicator.isHidden = true
        emptyView.isHidden = true
        searchBar.isHidden = true
    }
```

### After

```
class MyVc: UIViewController {
    
    override func viewDidLoad() {
        // These are auto generated in an extension of MyVc
        tableView.isHidden = true
        activityIndicator.isHidden = true
        emptyView.isHidden = true
        searchBar.isHidden = true
    }
```

