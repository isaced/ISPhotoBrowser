# ISPhotoBrowser [![CI Status](http://img.shields.io/travis/isaced/ISPhotoBrowser.svg?style=flat)](https://travis-ci.org/isaced/ISPhotoBrowser) [![Version](https://img.shields.io/cocoapods/v/ISPhotoBrowser.svg?style=flat)](http://cocoapods.org/pods/ISPhotoBrowser)

ISPhotoBrowser 是一个新的照片浏览器基于 [IDMPhotoBrowser](https://github.com/thiagoperes/IDMPhotoBrowser), [MWPhotoBrowser](https://github.com/mwaterfall/MWPhotoBrowser), [SKPhotoBrowser](https://github.com/suzuki-0000/SKPhotoBrowser) 制作，感谢前辈们的积淀，内部重新采用了 UICollectionView 构建，并且优化了其他一些使用，让源码逻辑更清晰，使用更方便，并计划长期维护以及增加更多特性。

<img width="300" src="http://ww2.sinaimg.cn/large/006tKfTcgy1ff27gyoly7j30ku112x6k.jpg" />

## 特性

- [x] 从本地文件或网络 URL 加载单图或多图
- [x] 从网络异步下载并缓存
- [x] 大图双指缩放和移动
- [x] 类似 Facebook/微信/微博 大图浏览，支持上/下滑动关闭
- [x] 默认内置使用 [Kingfisher](https://github.com/onevcat/Kingfisher) 下载图片
- [x] 横屏支持
- [x] 高度定制化
- [ ] 长图显示优化
- [ ] 下载进度展示
- [ ] GIF 支持

## 要求

- iOS 8.0+
- Swift 3

## 示例

clone 这个项目，前先在 Example 文件夹运行 `pod install`

## 安装

ISPhotoBrowser 已加入 [CocoaPods](http://cocoapods.org) 豪华午餐. 在 Podfile 文件中添加如下代码即可引入到你的项目:

```ruby
pod "ISPhotoBrowser"
```

## 使用

通过以下代码片段示例来了解如何使用

1. 生成一个 ISPhoto 对象的照片数组:

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

2. 创建 PhotoBrowser 示例:

```
let photoBrowser = ISPhotoBrowser(photos: photos, originImage: imageView.image!, animatedFromView: imageView)
```

3. 弹出照片浏览器:

```Swift
self.present(photoBrowser, animated: true, completion: nil)
```

## 定制化

#### 相关属性：

```Swift
// 设置初始页
var initialPageIndex: Int = 0

// 获取当前页码
var currentPageIndex: Int = 0

// 背景颜色
var backgroundColor: UIColor = .black

// 是否启用单击退出
var enableSingleTapDismiss: Bool = true
```

#### 部分代理：

通过遵循 <ISPhotoBrowserDelegate> 代理来接收一些事件回调和动画效果的支持。

```Swift
// 当显示出一张照片
func didShowPhotoAtIndex(_ index: Int)

// 将要退出大图浏览器
func willDismissAtPageIndex(_ index: Int)

// 已经退出大图浏览器
func didDismissAtPageIndex(_ index: Int)

// 滑动到某一页
func didScrollToIndex(_ index: Int)

// 询问某一张照片的原 view，为了做收回动画
func viewForPhoto(_ browser: ISPhotoBrowser, index: Int) -> UIView?
```

#### 移出移入动画

如果你想实现类似微信点开大图隐藏原 view 并在退出大图浏览器后飞入的效果，可以通过以上代理中的 `didShowPhotoAtIndex` 和 `didDismissAtPageIndex` 来控制原 view 的隐藏和显示达到该效果，可以参照 Demo 的实现。

#### 自定义 ISPhoto

ISPhoto 其实也是遵循了 ISPhotoProtocol 这个协议来告知 ISPhotoBrowser 如何进行加载图片并回调，你完全可以不使用内置的 ISPhoto 而扩展自己的模型支持 ISPhotoBrowser 加载，同样只需要实现 ISPhotoProtocol 协议就好了，具体可参考 [ISPhoto](https://github.com/isaced/ISPhotoBrowser/blob/master/ISPhotoBrowser/Classes/ISPhoto.swift) 源码。

ISPhotoProtocol 大致的逻辑是这样，我们通过 `underlyingImage` 属性来存储待加载的图片，然后 ISPhotoBrowser 需要时会通过调用 `loadUnderlyingImageWithCallback` 来告知模型开始加载（从磁盘、或者网络）图片，这时模型内部开始执行加载逻辑，当完成后，设置  `underlyingImage` 属性并通过 `callback` 闭包回调 ISPhotoBrowser 告知图片已读取到内存，ISPhotoBrowser 这时就会刷新 UI 并展示该张图片。另外当 ISPhotoBrowser 收到内存警告时，会依次调用所有模型的 `unloadUnderlyingImage` 来清除图片以释放内存。

更多内容敬请查看示例工程

## 联系

如有任何使用上的问题或者其他想法，欢迎提交 issue 和 pull request 让我知道，如想联系我可以微博私信 [@isaced](http://weibo.com/u/2034474825/).

## 许可证

MIT
