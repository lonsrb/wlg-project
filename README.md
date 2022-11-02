# wlg-project
This repo is my submission for the Mobile Code exercise. I ended up writing a bit more than I'd initially inteded but I think now you've got a good chunk of code that we can walk through.

I decided to use some of the newer language features to give me an opportunity to play with them. So we've got SwiftUI and Async/Await in here and even a little Combine. The architecture is set up as MVVM since that's what tends to work well with SwiftUI

There are 4 main groups in the project:
- Views
- View Models
- Models
- Services

I built both the List and Map centric search expereinces. They're not perfect from a UX perspective but definitley suffice for the purposes of a coding exercise. I also built in a "filter" feature for the search that would filter on "kind" of marker, eg: Marina vs Ramp vs Landmark but either I'm misscalling the API or maybe the API doesn't restrict results by kind. So while that feature doesn't work, I left it in because I wanted to show off that I wrote it.

I didn't write any tests with this but did try and build it in a way that would facilitate testing. We can chate about this on a call. 

It should run out of the box on a simulator. I didn't try it on a device.  
I built it for iOS 14+ since the current iOS release is 16 and that gives us 2 versions back.

