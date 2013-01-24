CssAnimation
============

Provides a simple wrapper around the CSS3 animation functionalities. 


Introduction
------------

At the time of writing there did not appear to be a simple way to dynamically
generate the CSS3 keyframes necessary for animation within dart. Therefore 
the appropriate rules must be built manually and injected into a stylesheet.

CssAnimation provides a simple interface with varying degrees of control
that can dynamically build animation rules and apply them to elements.

Once a rule has been built it can be applied to any number of elements
using the same instance of CssAnimation since it is simply using the
name of that rule.

CssAnimation instances cannot be modified (yet) so re-use is not an option
at this stage, but be wary of creating large numbers of new instances since
it adds a new rule to the stylesheet which is not removed. This may have
an unfortunate effect on performance. 

Please note that it does not attempt to fallback to javascript/dart driven 
animations if the CSS3 capabilities are not there, it simply won't work in 
older browsers.


Examples
--------

### Single property

The simplest constructor for CssAnimation allows the keyframing of a single 
property.

```dart
import 'dart:html';
import 'package:css_animation/css_animation.dart';

main() 
{
  var element   = query('#element-of-interest');
  var animation = new CssAnimation('opacity', 0, 1);

  animation.apply(element, duration: 500);
}
```

The apply() function has a variety of optional named parameters which provide
convenient access to the corresponding animation styles.


### Multiple properties

The starting and ending state of multiple properties can be declared
using Map<String, Object> where the key is the CSS property name and
the object is the property value. The value must convert to a valid
form via toString().

```dart
import 'dart:html';
import 'package:css_animation/css_animation.dart';

main() 
{
  var element   = query('#element-of-interest');
  var animation = new CssAnimation.properties(
    { 'opacity': 0, 'top': '0px' }
    { 'opacity': 1, 'top': '8px' }
  );
	
  animation.apply(element, iterations: 2, alternate: true,);
}
```

The example above will fade the element in at the same time as moving it down a bit, 
then it will do the reverse (because alternate = true) before stopping (because 
iterations = 2).


### Keyframes

An animation in CSS3 is defined as set of keyframes (between 0% and 100%) with a 
specific property state at each point. The most flexible constructor allows 
any number of keyframes to be specified (within reason).

```dart
import 'dart:html';
import 'package:css_animation/css_animation.dart';

main() 
{
  var keyframes   = new Map<int, Map<String, Object>>();
  keyframes[0]    = { 'opacity': 0 };
  keyframes[50]   = { 'opacity': 1, 'background-color': '#fff' };
  keyframes[100]  = { 'opacity': 1, 'background-color': '#000' };
  
  var element   = query('#element-of-interest');
  var animation = new CssAnimation.keyframes(keyframes);
	
  animation.apply(element, onComplete: () => element.appendHtml('finished'));
}
```

This time the example provided a callback function which is invoked
when the animation has completed.


Future
------

The next step may be to allow some form of rule modification that results
in it rebuilding and overwriting the underlying stylesheet rule.

Since dart classes have no destructor an instance is unable to remove its rule
from the stylesheet when it is no longer required, but we could provide a
function that would allow a developer to indicate when they no longer plan to
use that instance and the rule can therefore be deleted.
