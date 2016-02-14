![Slaminate](https://github.com/trenskow/Slaminate/raw/gh-pages/images/slaminate.png)


The power of Core Animation - with the animation API of UIKit.

## How it works

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
   
The above code makes the first two `slaminate` animations go together by `add`ing them - then the third in animated. Completion handlers are available at all three steps!

#### Advanced Animations

Now you can do stuff like this.

	protocol Transitionable {
		func transitionIn() -> Animation
		func transitionOut() -> Animation
	}
	
	class myViewController: UIViewController, Transitionable {
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
			let oldViewController = self.childViewControllers.last! as! Transitionable
			super.addChildViewController(childViewController)
			if let newViewController = childViewController as? Transitionable {
				oldViewController.transitionOut()
				.then(newViewController.transitionIn()).
				.on(.End, then: { _ in
					oldViewController.removeFromParentViewController()
				})
			}
		}
	}

See what happened? We **organized the animations** of our application!

#### One last thing

Lastly you can animate non-UI properties by using `setValue(_, forKey:)`.

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

#### More things are coming - like convenience methods for showing and hiding view easily!

Things are still very new, and kind of hacky implemented – a refactoring is probably coming up soon — but it works!

Documentation is coming... :/
