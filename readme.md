
# Outletgen Xcode Script

- Tired of dragging and crashing @IBOutlets? 😰
- Want to get rid of dozens of @IBOutlets cluttering your ViewControllers? 🗑
- Want to be cool like the Androids and have type safe auto generated references? 😎

Use this script that will automatically generate view outlets for you! The views are generated as VC extensions and are stored by object association ⚡️

**Very early version, buggy, feel free to test and contribute**

# Installation

## CocoaPods

1. Add `pod 'Outletgen'` to your Podfile 
2. Add `"$PODS_ROOT/Outletgen/Outletgen"` to to your Run Scripts in Xcode. **Drag it above the Compile Sources phase**.
3. Build and add generated `Outletgen.swift` to your project. Deselect *Copy files if needed*.

## Manual

1. Drag & Drop `Outletgen` to your project folder.
2. Add `"$SRCROOT/Outletgen"` to your Run Scripts in Xcode. **Drag it above the Compile Sources phase**.is
3. Build and add generated `Outletgen.swift` to your project. Deselect *Copy files if needed*.

# Using

Just add a "Restoration ID" to your views in XIBs/Storyboards and Outletgen will auto generate code for you to use.

## Before

<p align="center">
<img src="https://i.stack.imgur.com/UBBCs.png" height="266" width="513">
</p>

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

## After

No drag & dropping. Just add a "Restoration ID" in your views and references will be auto-generated for you:

```
class MyVc: UIViewController {

    // Aaah, no more clutter!
    
    override func viewDidLoad() {
        // These are auto generated in an extension of MyVc
        tableView.isHidden = true
        activityIndicator.isHidden = true
        emptyView.isHidden = true
        searchBar.isHidden = true
    }
```


### Thanks for contributing!

[kacperd](https://github.com/kacperd) <3
