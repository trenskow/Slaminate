![Slaminate](https://github.com/trenskow/Slaminate/raw/gh-pages/images/slaminate.png)


The power of Core Animation - with the animation API of UIKit.

## How it Works

Have you ever wanted to do something like this?

	UIView.animateWithDuration(0.3, {
		myHeightConstraint.constant = 300
	})

– and just expected things to work?

What about this?

	UIView.animateWithDuration(0.3, {
		myView.removeConstraint(myOldConstraint)
		myView.addConstraint(myNewConstraint)
	})

– and also just expected it to work?

*Well it didn't...*

What about advanced or custom curves? Chainable animations? Animating non-UI properties?

### Introducing Slaminate

Using Slaminate this is **all possible** - with the simplicity of the UIKit animations API.

With Slaminate you can do something like this.

	slaminate(
		duration: 0.3,
		animation: {
			myView.removeConstraint(myOldConstraint)
			myView.addConstraint(myNewConstraint)
			myOtherConstraint.constant = 200
			myView.alpha = 0.3
		},
		curve: Curve.easeOutBack,
		delay: 0.0,
		completion: { finished in
			print("Wow?!? Did this just work?!?")
		}
	)

You can even group and chain animations – like this.

	var myAnimation = slaminate(...)
	myAnimation.and(slamniate(...))
	myAnimation.then(slamniate(...))
   
The above code makes the first two `slaminate` animations go together by `add`ing them - then the third is animated. Completion handlers are available at all three steps!

#### Advanced Animations

Now you can do stuff like this.

	protocol Transitionable {
		func transitionIn() -> Animation
		func transitionOut() -> Animation
	}
	
	class MyViewController: UIViewController, Transitionable {
		var myFirstTransitioningView: Transitionable!
		var mySecondTransitioningView: Transitionable!
		func transitionIn() -> Animations {
			return myFirstTransitioningView
			      .transitionIn()
			      .and(animation: mySecondTransitioningView.transitionIn())
		}
	}
	
	class MyContainerViewController {
		public override func addChildViewController(childViewController: UIViewController) {
			let oldViewController = self.childViewControllers.last
			super.addChildViewController(childViewController)
			if let oldViewController = oldViewController as? Tranistionable
			   let newViewController = childViewController as? Transitionable {
				oldViewController.transitionOut()
				.then(newViewController.transitionIn()).
				.on(.End, then: { _ in
					oldViewController.removeFromParentViewController()
				})
			}
		}
	}

See what happened? We **organized the animations** of our application!

#### Oh - and this...

The `position` offset lets you apply a position in time of the animation – and when you can `begin()` the animation will take off from that position.

Sp you could create something like an navigation controller pan gesture dismiss like this. 

	class MyNavigationController {
		var panGesture: UIScreenEdgePanGestureRecognizer
		var animation: Animation?
		..
		func panGestureStateChanged:(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
			switch gestureRecognizer.state {
			case .Began:
				// Create animation for popping
				animation = slaminate(...).postpone()
			case .Changed:
				let location = gestureRecognizer.locationInView(self.view.window)
				// We calculate the delta and set the position of the animation
				animation.position = (location. x / self.view.window.bounds.size.width) * location.x
			case .Ended:
				// Animate the animation from whatever the current position is
				animation.begin()
			default:
				break
			}
		}
	}

#### Oh – and this, too...

You can also animate non-UI properties by using `setValue(_, forKey:)`.

	slaminate(
		duration: 1.0,
		animation: {
			myAudioPlayer.setValue(0.0, forKey: "volume")
		},
		curve: Curve.easeOutSine,
		delay: 0.0,
		completion: { finished in
			myAudioPlayer.stop()
		}
	)

#### More things are coming - like convenience methods for showing and hiding views easily!

Things are still very new, and the implementation is very hacky, but give it a spin. It works!

----

Documentation is coming... :/
