import Foundation
import UWP
import WinAppSDK
import WindowsFoundation
import WinUI

@main
public class PreviewApp: SwiftApplication {
    /// A required initializer for the application. Non-UI setup for your application can be done here.
    /// Subscribing to unhandledException is a good place to handle any unhandled exceptions that may occur
    /// in your application.
    public required init() {
        super.init()
        unhandledException.addHandler { (_, args:UnhandledExceptionEventArgs!) in
            print("Unhandled exception: \(args.message)")
        }
    }

    /// onShutdown is called once Application.start returns. This is a good place to do any cleanup
    /// that is necessary for your application before it terminates.
    override public func onShutdown() {    }

    /// onLaunched is called when the application is launched. This is the main entry point for your
    /// application and when you can create a window and display UI.s
    override public func onLaunched(_ args: WinUI.LaunchActivatedEventArgs) {
        let window = Window()
        window.title = "WinUI3TreeViewPreview"

        // Create the main layout panel
        let mainPanel = StackPanel()
        mainPanel.orientation = .vertical
        mainPanel.spacing = 10
        mainPanel.horizontalAlignment = .center
        mainPanel.verticalAlignment = .center

        // Create TreeView
        let sampleTreeView = TreeView()
        loadTreeViewData(treeView: sampleTreeView)

        // Create buttons
        let myButton = Button()
        myButton.content = "Click Me"
        myButton.click.addHandler { _, _ in
            myButton.content = "Clicked"
        }

        let secondButton = Button()
        secondButton.content = "Second Button"
        secondButton.click.addHandler { _, _ in
            secondButton.content = "clicked second"
        }

        // Add controls to panel
        mainPanel.children.append(sampleTreeView)
        mainPanel.children.append(myButton)
        mainPanel.children.append(secondButton)

        // Set window content and activate
        window.content = mainPanel
        try! window.activate()
    }

    private func loadTreeViewData(treeView: TreeView) {
        // Create nodes
        let rootNode = TreeViewNode()
        let childNode1 = TreeViewNode()
        let childNode2 = TreeViewNode()

        // Set content for nodes
        rootNode.content = "Root"
        childNode1.content = "Child 1"
        childNode2.content = "Child 2"

        // Build tree structure
        rootNode.children.append(childNode1)
        rootNode.children.append(childNode2)

        // Add root node to TreeView
        treeView.rootNodes.append(rootNode)

        // Optional: Set up event handlers for TreeView
        treeView.itemInvoked.addHandler { [weak self] sender, args in
            if let node = args?.invokedItem as? TreeViewNode {
                print("Selected node: \(String(describing: node.content))")
            }
        }
    }

    lazy var compositor: WinAppSDK.Compositor = WinUI.CompositionTarget.getCompositorForCurrentThread()
    lazy var springAnimation: WinAppSDK.SpringVector3NaturalMotionAnimation = {
        // swiftlint:disable:next force_try
        let animation: WinAppSDK.SpringVector3NaturalMotionAnimation = try! compositor.createSpringVector3Animation()
        animation.target = "Scale"
        animation.dampingRatio = 0.6
        animation.period = TimeSpan(duration: 500000)
        return animation
    }()

    private func elementPointerEntered(sender: Any!, args: PointerRoutedEventArgs!) {
        // Scale up to 1.5
        springAnimation.finalValue = Vector3(x: 1.5, y: 1.5, z: 1.5)
        // swiftlint:disable:next force_cast
        let senderAsUElement = sender as! UIElement
        try? senderAsUElement.startAnimation(springAnimation)
    }

    private func elementPointerExited(sender: Any!, args: PointerRoutedEventArgs!) {
        // Scale back down to 1.0
        springAnimation.finalValue = Vector3(x: 1.0, y: 1.0, z: 1.0)
        // swiftlint:disable:next force_cast
        let senderAsUElement = sender as! UIElement
        try? senderAsUElement.startAnimation(springAnimation)
    }
}
