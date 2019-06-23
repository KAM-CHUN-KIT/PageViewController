# KPageViewController

A flexiable and easy to use view pager library for Swift.

## Preview
<img src="Screenshot/ezgif-4-2168d0e5043a.gif" width=350/>

## Setup
You need to inherit the library from KPageViewController:
```
import KPageViewController

class YourViewController: PageViewController {
```

Simply assign the segmented titles and view controllers:
```
self.segmentedTitles = titles
self.viewControllers = vcs
```

Show it:
```
self.reveal()
```

## Example
```
class ExampleViewController: PageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.dynamicWidthTab = true
        self.segmentedTitles = ["Tab 1", "Tab 2", "Tab 3", "Tab 4", "Tab 5"]
        self.viewControllers = [UIViewController(), UIViewController(), UIViewController(), UIViewController(), UIViewController()]
        self.reveal()
    }
}
```

## Requirements
iOS 9.0 or above <br/>
Support Swift 5.0

## Installation
PageViewController is available through CocoaPods. To install it, simply add the following line to your Podfile:

```
pod "KPageViewController"
```

## Author
Mr. Kam Chun Kit

## License
KPageViewController is available under the MIT license. See the LICENSE file for more info.
