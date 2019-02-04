
# Outletgen Xcode Script

- No more drag & dropping @IBOutlets 🙌
- No more clutter in ViewControllers 🗑
- Type safe, no more mystical crashes due to missing @IBOutlets ✨

This script will automatically generate view outlets for you! The views are generated as VC extensions and are stored by object association ⚡️

**Very early version, buggy, feel free to test and contribute**

Features:

- Storyboard/XIB support
- Outlets for subviews
- Outlets for subviews in cells storyboard prototypes
- Outlets for constraints
- Outlets for UIBarButtonItems

## Installation

1. Add `pod 'Outletgen'` to your Podfile 
2. Add `"$PODS_ROOT/Outletgen/Outletgen"` to to your Run Scripts in Xcode. **Drag it above the Compile Sources phase**.
3. Build and add generated `Outletgen.swift` to your project. Deselect *Copy files if needed*.

*Adding `Outletgen.swift` to `.gitignore` is recommended.*

or:

<details><summary>Manual Installation</summary>
<p>

1. Drag & Drop `Outletgen` to your project folder.
2. Add `"$SRCROOT/Outletgen"` to your Run Scripts in Xcode. **Drag it above the Compile Sources phase**.is
3. Build and add generated `Outletgen.swift` to your project. Deselect *Copy files if needed*.

</p>
</details>

## Using

Just add an "Outlet identifier" to your views in XIBs/Storyboards and Outletgen will auto generate code for you to use.

### Before

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

### After

No drag & dropping. Just add an "Outlet identifier" in your views and references will be auto-generated for you:

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

## Contributing

Just make a PR! There are some issues to solve in the "Issues" section.

### Thanks for contributing!

[kacperd](https://github.com/kacperd) <3
