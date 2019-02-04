import UIKit

class HalfModalInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    var presentingViewController: UIViewController
    var presentedViewController: UIViewController
    var panGestureRecognizer: UIPanGestureRecognizer
    
    var shouldComplete: Bool = false
    
    init(presentingViewController: UIViewController, withView view: UIView, presentedViewController: UIViewController) {
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController
        self.panGestureRecognizer = UIPanGestureRecognizer()
        
        super.init()
        
        self.panGestureRecognizer.addTarget(self, action: #selector(onPan(pan:)))
        view.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        super.startInteractiveTransition(transitionContext)
        print("start interactive")
    }
    
    override var completionSpeed: CGFloat {
        get {
            return 1.0 - self.percentComplete
        }
        set {}
    }
    
    @objc func onPan(pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: pan.view?.superview)
        
        switch pan.state {
        case .began:
            presentedViewController.dismiss(animated: true, completion: nil)
            break
        case .changed:
            // TODO: Почему 50???
            let screenHeight = UIScreen.main.bounds.size.height - 50
            var percent: Float = Float(translation.y) / Float(screenHeight)
            percent = fmaxf(percent, 0)
            percent = fminf(percent, 1.0)
            
            update(CGFloat(percent))
            shouldComplete = percent > 0.2
            break
            
        case .cancelled:
            cancel()
            break
        case .ended:
            if !shouldComplete {
                cancel()
            } else {
                finish()
            }
            break
        default:
            cancel()
            break
        }
    }
}
