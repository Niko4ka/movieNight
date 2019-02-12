import UIKit


class HalfModalTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum animatorType {
        case present
        case dismiss
    }

    var type: animatorType
    
    init(type: animatorType) {
        self.type = type
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animateFrom = transitionContext.viewController(forKey: .from)
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, animations: {
            animateFrom?.view.frame.origin.y = 800
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
}
