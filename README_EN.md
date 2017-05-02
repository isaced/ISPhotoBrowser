# ISPhotoBrowser [![CI Status](http://img.shields.io/travis/isaced/ISPhotoBrowser.svg?style=flat)](https://travis-ci.org/isaced/ISPhotoBrowser) [![Version](https://img.shields.io/cocoapods/v/ISPhotoBrowser.svg?style=flat)](http://cocoapods.org/pods/ISPhotoBrowser)

ISPhotoBrowser is a new implementation based on [IDMPhotoBrowser](https://github.com/thiagoperes/IDMPhotoBrowser), [MWPhotoBrowser](https://github.com/mwaterfall/MWPhotoBrowser), [SKPhotoBrowser](https://github.com/suzuki-0000/SKPhotoBrowser).

<img width="300" src="http://ww2.sinaimg.cn/large/006tKfTcgy1ff27gyoly7j30ku112x6k.jpg" />

## Features

- [x] Can display one or more images by providing either UIImage objects, file paths or URLs
- [x] Handles the downloading and caching of photos from the web seamlessly
- [x] Photos can be zoomed and panned
- [x] Minimalistic Facebook-like interface, swipe up/down to dismiss
- [x] Uses Kingfisher for image loading
- [x] Landscape handling
- [x] Highly customized
- [ ] Long pictures optimization
- [ ] Image progress shown
- [ ] GIF support

## Requirements

- iOS 8.0+
- Swift 3

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

ISPhotoBrowser is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ISPhotoBrowser"
```

## Useage

See the code snippet below for an example of how to implement the photo browser.

1. First create a photos array containing ISPhoto objects:

```Swift
// URLs array
let urls = ["http://farm4.static.flickr.com/3567/3523321514_371d9ac42f_b.jpg",
            "http://farm4.static.flickr.com/3629/3339128908_7aecabc34b_b.jpg",
            "http://farm4.static.flickr.com/3364/3338617424_7ff836d55f_b.jpg",
            "http://farm4.static.flickr.com/3590/3329114220_5fbc5bc92b_b.jpg"]

// Create an array to store ISPhoto objects
let photos: [ISPhoto] = urls.map({ (url) -> ISPhoto in
        return ISPhoto(url: URL(string: url)!)
    })
```

2. Create PhotoBrowser Instance:

```
let photoBrowser = ISPhotoBrowser(photos: photos, originImage: imageView.image!, animatedFromView: imageView)
```

3. Presenting using a modal view controller:

```Swift
self.present(photoBrowser, animated: true, completion: nil)
```

## Customize


```Swift
// initial page
var initialPageIndex: Int = 0

// get current page index
var currentPageIndex: Int = 0

// background color
var backgroundColor: UIColor = .black

// single tap dismiss
var enableSingleTapDismiss: Bool = true
```

delegate

```Swift
func didShowPhotoAtIndex(_ index: Int)
func willDismissAtPageIndex(_ index: Int)
func didDismissAtPageIndex(_ index: Int)
func didScrollToIndex(_ index: Int)
func viewForPhoto(_ browser: ISPhotoBrowser, index: Int) -> UIView?
```

For more, please see the example project

## Author

isaced, isaced@163.com

## License

ISPhotoBrowser is available under the MIT license. See the LICENSE file for more info.
