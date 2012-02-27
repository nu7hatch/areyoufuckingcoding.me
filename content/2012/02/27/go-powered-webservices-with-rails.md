---
title:      Go-powered web-services with Rails
kind:       article
created_at: February 27, 2012
author:     nu7
---

Today's episode will be about **using right tools to solve concrete problem** and is
influenced by all the questions about Rails-like frameworks in Go which recently shown
up on the _golang-nuts_ mailing list.

Hater mode ON. I stubbornly believe that efforts to clone Rails in any other 
programming language, not only Go, are just ridiculous. If you want to use Rails, 
**learn Ruby motherfucker**! Second thing which I strongly believe in, is to know 
strengths and weaknesses of **all the tools we're using**, and choosing those which 
may solve the problem with **minimal effort and maximal benefits**. That's why, no 
matter how much I like Go, I wouldn't decide to write full-stack web application
in it. Btw, to all the people looking Rails-like framework in Go...

<div class="meme">
  <img src="/img/meme-obama-disappoint-1.jpg" alt="I'm disappoint" />
</div>

Hater mode OFF.

### But, but... there are websites in Go!?

Yes, of course there are. The same as we have D programming language forum written
in D or web applications framework for C++. You can do it, the main question of
this article is, **if it's worth it**? Let me explain you everything by example...

Let's figure out some app we could do in Rails in few hours. Oh, it would be
fun to have some small web app, where you can upload your picture, apply
some filter, and share it with your friends. Yeap gophers, I choose 
this in purpose, to compare with [mustachio](http://moustach-io.appspot.com/).
Here's how the project specification could look like:

* As an anonymous user I want to go to the home page, select a picture from
  my hard drive and click "Upload" button it then I want to see it uploaded.
* When I am on the uploaded picture page, I want to see my original picture
  and buttons with available filters.
* When I am on the uploaded picture page, and I click one of the filter
  buttons, then I want to see my picture with that filter applied.
* When I am on the uploaded picture page, after I select filters to apply 
  and click "Done" button, then I want to see link which I can share with my 
  friends.

Simple stuff to do, isn't it? We can build it very quickly using Rails, 
[CarrierWave](https://github.com/jnicklas/carrierwave) and [ImageMagick](http://www.imagemagick.org/script/index.php), 
powered up with some NoSQL datastore if needed. But true is, that we could write 
such an app in Go quite easily. It would be slightly more difficult, could get bigger
code base and take little longer, but in exchange of splendidly performant 
application... Mentioned [mustachio](http://moustach-io.appspot.com/) is good
example of it, so why not to do this?

### Expectations

Let's take a look at the problem from the **business side**. We are building something 
new, we know how to do this, but we have no idea how many people is going to use 
it, how much resources we may need to maintain that app, etc. We want to try it out, 
write a minimum viable product, show it to the people and check how many of them 
is going to use it. That's why we're going to implement stuff with **minimum effort**, 
using technologies **we know the best**. Of course there may be a problem that site 
will go down under the flood of enthusiastic users... but, isn't it a problem
we want to have? When this happens, then we can extract the most loaded parts of 
our app into **fast web-services written in Go**.

<div class="meme">
  <img src="/img/meme-i-dont-always-1.jpg" alt="I don't always write websites in Go" />
</div>

### Tweaking up!

So let's imagine that our application encountered huge amount of users. It's easy 
to figure out that the most loaded part of the app will be images processing and
applying filters. What we can do in that case is to left ImageMagick behind
and use the [**image**](http://weekly.golang.org/pkg/image) package from Go
standard library instead. Everything nicely wrapped around with **HTTP web service**.

First, we have to tell our Rails app where images are going to come from.
Rails 3.x allows us to specify the `asset_host` in controller's configuration:

    #!ruby
    ActionController::Base.asset_host = Proc.new { |source|
      if source.starts_with?('/uploads')
        "http://filters.ournicepage.com"
      else
        "http://ournicepage.com"
      end
    }
    
As you can see, we can tell Rails to load images only from different location,
and keep using all other assets normally. You can find out more about it in [the
AssetTagHelper documentation](http://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html).

Now we need to have something to serve on _filters.ourpage.com_. This is not a post
about image processing etc, if you're hungry of the full implementation, you can find 
it [on my github](http://github.com/nu7hatch/golaroid). Here I will show you just few 
tricks I found useful while writing this stuff.

### Custom HTTP handlers

After going through [**Interactive Go Tour**](http://tour.golang.org/#1) you probably
know how to write simple HTTP service. Here's how our image filtering may look like
with default `net/http` stuff:

    #!go
    func ImageHandler(w http.ResponseWriter, r *http.Request) {
            r.ParseForm() // we have to parse form before using its values
            path = filepath.Join(ImagesRoot, r.FormValue("image"))
            // *snip*
    }
    
    func main() {
            http.HandleFunc("/filter", ImageHandler)
            log.Fatal(http.ListenAndServe(Addr, nil))
    }

Works, but sucks - because it gets information from GET parameters. To get processed image
we have to request something like this: `/filter?image=image/path&filter=sepia`. If our 
Rails application provides nice URLs, like `/image/path?filter=sepia`, then we have 
to figure our something better. One option we can use instead is [**pat.go**](https://github.com/bmizerany/pat.go) - 
a Sinatra style pattern multiplexer from Blake Mizerany. Our improved implementation 
may look like this:

    #!go
    func ImageHandler(w http.ResponseWriter, r *http.Request) {
            r.ParseForm()
            path = filepath.Join(ImagesRoot, r.FormValue(":splat"))
            // *snip*
    }
    
    func main() {
            mux := pat.New()
            mux.Get("/*", ImageHandler)
            log.Fatal(http.ListenAndServe(Addr, mux))
    }

This looks much better, we can apply filter to the image by requesting `/image/path?filter=sepia`.
But to be honest, do we really need any external mux to serve just one thing? This 
web-service does only one thing right, so we can just use full request path to distinguish an
image. To achieve that we have to define our [custom `http.Handler`](http://weekly.golang.org/pkg/net/http/#Handler).
Handler is an interface which requires `ServeHTTP` function to be implemented. Let's implement
it then:

    #!go
    type ImageHandler struct {}
    
    func (h *ImageHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	        path := filepath.Join(ImagesRoot, r.URL.Path)
	        // *snip*
    }
    
    func main() {
            srv := &http.Server{
                    Addr:    Addr,
                    Handler: &ImageHandler{},
            }
            log.Fatal(srv.ListenAndServe())
    }

### Distinguishing file errors

If you take a look at full [`ServeHTTP` implementation](https://github.com/nu7hatch/golaroid/blob/master/handler.go#L21).
you will notice that I'm checking out what kind of the error has been returned from
`pic.Load()` to produce either `404` or `500` error page. The [**os** package](http://weekly.golang.org/pkg/os/)
has few helpers to do this, i.a to check if returned error was caused by missing
file, we can use the [`IfNotExist` helper](http://weekly.golang.org/pkg/os/#IsNotExist):

    #!go
    if err := pic.Load(); err != nil {
            if os.IsNotExist(err) {
                    http.NotFound(w, r)
            } else {
                    w.WriteHeader(http.StatusInternalServerError)
            }
            return
    }

### Custom iterators

To apply custom filters to the picture in most of cases we have to iterate over
all the pixels. When our iteration contains some duplications, we can DRY it out
using **custom iterator**, like this one for example:

    #!go
    func EachPixel(img image.Image, fn func(x, y int, r, g, b, a uint8)) {
	        rect := img.Bounds()
	        for i := 0; i < rect.Dx() * rect.Dy(); i++ {
                    // Bunch of calculations you shouldn't care about...
                    x, y := i % rect.Dx() + rect.Min.X, i / rect.Dx() + rect.Min.Y
	                pixel := img.At(x, y)
	                r32, g32, b32, a32 := pixel.RGBA()
	                r8, g8, b8, a8 := uint8(r32), uint8(g32), uint8(b32), uint8(a32)

                    // Exectuting callback on given pixel coordinates and RGBA
                    // color values.
                    fn(x, y, r8, g8, b8, a8)
            }
    }

Such defined iterator can be used as follow:

    #!go
    EachPixel(img, func(x, y int, r, g, b, a uint8)) {
            // do something with colors...
    }

### Anonymous imports

While playing with the [**image**](http://weekly.golang.org/pkg/image) package
I found very nice thing. Go allows you to **anonymously import the package**, only
for its initialization side effects. For example, the _image_ package defines
[`Decode`](http://weekly.golang.org/pkg/image#Decode) function, which is used to 
read image information from the stream. Function is using registered image formats 
to properly decode the information from the `io.Reader`. Now, each of format-specific
sub packages registers its decoder in initializer. The [image/png](http://weekly.golang.org/pkg/image/png) 
for example does it this way:

    #!go
    func init() {
             image.RegisterFormat("png", pngHeader, Decode, DecodeConfig)
    }

Now, if we want to decode information from the _png_ image, we can just anonymously
import `image/png` package:

    #!go
    import _ "image/png"
    
... and use global `image.Decode` function:

    #!go
    f, _ := os.Open("file.png")
    img, _ := image.Decode(f)

We can obviously still import this package normally and use [`png.Decode`](http://weekly.golang.org/pkg/image/png#Decode)
directly if needed.

<div class="meme">
  <img src="/img/meme-stallone-big-1.jpg" alt="This feature is such a big!" />
</div>

### Summary

Ok, enough cool features for today, let's go back to our example. Just to clarify
things at the end of this article. I'm not saying that writing web apps in Go
is something totally wrong or bad, nor that you should use Rails to write all 
your web apps. What I want to say is that Go is little bit different language than
ruby, and looking for ruby solutions there is just pointless. Rails, Django or Sinatra
works good for full stack web application, while Go performs splendidly while 
powering them up with web-services or tools.
