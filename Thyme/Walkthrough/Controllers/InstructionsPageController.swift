import UIKit

public class InstructionsPageController: UIPageViewController, InstructionDelegate {

  var index: NSInteger = 0

  lazy var instructions: [InstructionController] = {
    var instructions = [InstructionController]()
    var array = [
      [
        "image":"instructions",
        "title":"InstructionTitle",
        "message":"InstructionMessage"
      ],
      [
        "image":"instructionsA",
        "title":"InstructionTitleA",
        "message":"InstructionMessageA"
      ],
      [
        "image":"instructionsB",
        "title":"InstructionTitleB",
        "message":"InstructionMessageB"
      ],
      [
        "image":"instructionsC",
        "title":"InstructionTitleC",
        "message":"InstructionMessageC"
      ],
      [
        "image":"instructionsD",
        "title":"InstructionTitleD",
        "message":"InstructionMessageD"
      ]
    ]

    for (index, entry) in enumerate(array) {
      let hasAction = index == array.count ? true : false
      let controller = InstructionController(image: UIImage(named: entry["image"]!)!,
        title: entry["title"]!,
        message: entry["message"]!,
        hasAction: hasAction,
        isWelcome: false,
        index: index as NSInteger)
      instructions.append(controller)
    }

    return instructions
  }()

  public override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [NSObject : AnyObject]?) {
    super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
    
    dataSource = self
    view.backgroundColor = UIColor(fromHex: "EDFFFF")
    setViewControllers([instructions.first!],
      direction: UIPageViewControllerNavigationDirection.Forward,
      animated: true, completion: nil)
  }

  public required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

}

// MARK: - UIViewController

extension InstructionsPageController {

  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    self.setNeedsStatusBarAppearanceUpdate()
  }

  public override func prefersStatusBarHidden() -> Bool {
    return true
  }

}

// MARK: - UIPageViewControllerDataSource

extension InstructionsPageController: UIPageViewControllerDataSource {

  public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    if viewController.view.tag == 0 { return nil }

    let index = viewController.view.tag - 1
    let controller = instructions[index]

    return controller
  }

  public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    if viewController.view.tag == instructions.count - 1 { return nil }

    let index = viewController.view.tag + 1
    let controller = instructions[index]

    return controller
  }

  public func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
    return instructions.count
  }

  public func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
    return index
  }
}

// MARK: - InstructionDelegate

extension InstructionsPageController {

  public func instructionControllerDidTapAcceptButton(controller: InstructionController) {
    let types: UIUserNotificationType = .Alert | .Badge
    let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
    UIApplication.sharedApplication().registerUserNotificationSettings(settings)
  }
  public func instructionControllerDidTapNextButton(controller: InstructionController) {
    if index == self.instructions.count - 1 { return }

    index = controller.view.tag + 1

    let controller = self.instructions[index]
    setViewControllers([controller],
      direction: UIPageViewControllerNavigationDirection.Reverse,
      animated: true, completion: nil)
  }
  public func instructionControllerDidTapPreviousButton(controller: InstructionController) {
    if index == 0 { return }

    index = controller.view.tag - 1

    let controller = self.instructions[index]
    setViewControllers([controller],
      direction: UIPageViewControllerNavigationDirection.Forward,
      animated: true, completion: nil)
  }
}



