---
title:      NetChan is no more, shall be ChanIO?
kind:       article
created_at: February 6, 2012
author:     nu7
---

Aaah, I just came back from a short backpacking trip to Argentina, refreshed 
and full of energy! Yeap, it's a great time to write my first real blog post...

### No for such a newbies...

I have to clarify something first. You have to be aware that it's not gonna
be a blog for total newbies. You have to know at least basics of Go and you can 
learn it by going through [**Interactive Go Tour**](http://tour.golang.org/#1). 
If you haven't seen it yet, **go there** and **come back when you finish**! 

**Yes, you have to read it!**

### What's up with NetChan?

Current stable release of Go (r60) still have netchan in standard packages, but 
it has already been changed in weekly and netchan will be not included to Go 1. 
What do we have in exchange then? Nothing!

There's no official package which provides network wrappers for the channels, 
but [this TLTR thread](http://groups.google.com/group/golang-nuts/browse_thread/thread/12bdd37ad9ed4a68?pli=1) 
on [Go nuts mailing list](http://groups.google.com/group/golang-nuts/) brought 
few nice ideas. The one I liked the most is a wrapper which allows to bind the 
channel with any kind of [`io.Reader`](http://weekly.golang.org/pkg/io/#Reader) 
or [`io.Writer`](http://weekly.golang.org/pkg/io/#Writer). It sounds like a fun 
thing to do and great exercise to learn something, let's implement it then!

### Specification

So, we want to have a package implementing the following features:

* it should allow to read data from an `io.Reader` by consuming from the channel
* it should allow to write data to an `io.Writer` by publishing to the channel
* it should be able to read and write any kind of Go values
* it should be thread-safe

### Any kind of value?

First two requirements seems to be very obvious, let's take a look at the third 
one. As you should know, channel needs to have defined a type of the data which 
can operate: 

    #!go
    ch := make(chan int)
    ch <- "hello" // wrong! type error during the compilation
    ch <- 1       // ok

Cool, so let's define a constructor which takes an `io.Reader`/`io.Writer` and 
type of the data as a paramemeters... Yay!

<div class="meme">
  <img src="/img/meme-nope-1.jpg" alt="NOPE!" />
</div>

Why not? Because it's simply impossible to use a type as a parameter/variable. 
In Ruby, for example, you can do this:

    #!ruby
    arr = Array
    hello = arr.new("hello", "world")    

But this is not Ruby and you can't do it... Problem? Oh, do I hear rubyists 
saying now _"naah, that language sucks!"_? :)

Ok, let's think about it for a second... Do we actually need to care about the 
type at all? We could give users more freedom by working on interface channels. 
Take a look:

    #!go
    ch := make(chan interface{})
    ch <- "hello" // ok
    ch <- 1       // ok too!

Kwak kwak! For the power of duck typing! So now things get simpler, we just
need to write a wrapper for the `chan interface{}`. Looks cool, but has one 
small disadvantage... it's not idiot-proof:

    #!go
    x := <-ch
    fmt.Println(x.(string))
    
The code above will compile, because it uses type assertion to get a string
value from the interface. But what do you think is going to happen when the
channel will receive a value of any other type, different than string... 

<div class="meme">
  <img src="/img/meme-panic-1.gif" alt="PANIC!" />
</div>

We can prevent that situation by checking if the type assertion was correct:

    #!go
    x := <- ch
    if str, ok := x.(string); ok {
            fmt.Println(str)
    } else {
            fmt.Fprintf(os.Stderr, "%v is not a string!", x)
    }

I think that I don't need to explain how it works... you should remember it 
from the Go Tutorial. Anyway, it's very important to **check if assertion was 
correct** always when you are **not sure** about the type of the interface's value.
 
Regardless type assertions, this way looks good and simple enough to implement,
let's move forward then.

### Reading and Writing

As I said, first two requirements seems to be clear and explicit. But now
we have to consider them to be compliant with the third one. So we need to
be able to write (serialize) any kind of the data into IO stream. 

Go provides an awesome solution of this problem in its standard library.
There's a pacage called [`encoding/gob`](http://weekly.golang.org/pkg/encoding/gob/), 
which implements **exchanging of binary encoded Go values** between transmiter
(`io.Writer`) and receiver (`io.Reader`). This is it! Here's a trivial example
how it works:

    #!go
    f, _ := os.Open("~/wire.gob")
    en := gob.NewEncoder(f)
    en.Encode(1)
    en.Encode("hello")

    f.Seek(0, os.SEEK_SET)
    de := gob.NewDecoder(f)
    var i int
    var s string
    _ = de.Decode(i) // => 1
    _ = de.Decode(s) // => "hello"

**Note!** I'm leaving `"_"` (ignored value) declaration in single-value context
intentionaly, it's just to let you know that error shall be handled there.

Current gob implementation has a few limitations, for example to serialize/deserialize
some custom structure, first you need to **register it**:

    #!go
    type Cat struct {
        Cuteness int 
    }
    
    func init() {
        gob.Register(&Cat{})
    }

Chuck Testa already explained you that it's not possible to pass a type as a
parameter, so gob uses neat trick to register new type. It gets an **empty 
pointer to the struct** as a parameter. That allows it to identify the struct's
fields, functions, etc, and later, quickly and efficiently serialize/deserialize
values of that type.

Btw, you know what `init` function does... right? If not, get the fuck out and
go through that [**Go Tour**](http://tour.golang.org/#1)!

### Implementing a Writer

Let's write some real, working code now. Binding a channel with specified 
`io.Writer` can be done in two ways:

* get a channel as a parameter
* create new channel, bind it with given writer and return it

First approach seems reasonable and may give a lot of flexibility to the users, 
but if we will look at it closer it may also allow them to **fuck things up**. 
For example, user can read data from the same channel he specified as a binding
for the writer, which may cause **data corruption**.

To keep this implementation simple and clean, let's assume that users shall not
allow be able to bind an IO with existing channel. We should also prevent users 
from reading data from the returned channel. It can be done by returning the 
directional (write-only) channel:

    #!go
    ch := make(chan<- interface{})

Ups, we have a problem here... If we will create a write only channel, then we're 
screwed, becase we can't read from it! But no worries, don't be panic, everything's
gonna be alright! Go has a neat solution for that as well. We can use bi-directional
channel as directional one just by assignment:

    #!go
    var wch chan<- string   // write-only channel
    var rch <-chan string   // read-only channel
    ch := make(chan string) // bi-directional channel
    wch, rch := ch, ch
    wch <- "hello"
    fmt.Println(<-rch)      // => "hello"

As you can see, we can assign the bi-directional channel to both directional ones,
which allows us to use write-only channel to publish data, and read-only channel 
to consume it.     

<div class="meme">
  <img src="/img/meme-marvelous-1.jpg" alt="MARVELOUS!" />
</div>

Now we can use that ability and create an internal channel for reading under
the hood, exposing the write-only part to the user. That's how our writer
implementation may look like:

    #!go
    func NewWriter(w io.Writer) chan<- interface{} {
	        ch := make(chan interface{})
	        go write(w, ch) // spawning the worker function into another goroutine
	        return ch
    }
    
    func write(w io.Writer, ch chan interface{}) {
            enc := gob.NewEncoder(w)
            for x := range ch {
                    if err := enc.Encode(&packet{x}); err == io.EOF {
                        break
			        } else if err != nil {
                        continue
                    }
            }
            // ...
    }

Yeap, that's it. Trivial, isn't it? I don't know if I need to explain aything, 
you should understand this code easily. From the same reason I'm not going to 
describing reader's implementation here. You can find fully working, tested
and goinstallable package [here](http://github.com/nu7hatch/gochanio). Feel free
to fork and play with it.

### Be or not to be (in standard packages)

Looking at the snippet above now, I have to admit that @kevlar_work was absolutelly
right during our IRC conversation - **it's extremally easy to exchange data via 
channels over the network**. Thus now I'm sure there's no need to have such generic
solution in standard library. 

But there's one more thing I can't stop thinking about. During our conversation
about chanio on go-nuts mailing list, Kyle Lemons came across with a huge problem
of sharing channels over the network. By sharing channels I mean sending channels
via network channels and converting them into network channels...

<div class="meme">
  <img src="/img/meme-inception-1.jpg" />
</div>

Yeah, sounds ridiculous, but idea is actually really nice. Imagine that you can
share a structure containing internal channel over the network chan. If the
network channel (or serializer) would be able to figure out how to convert that
internal chan into chanio on the fly it would be awesome! Right!? Right?...

Actually... **no**! The [**K.I.S.S. principle**](http://www.faqs.org/docs/artu/ch01s07.html),
you remember that? Besides keeping it simple, we have to be [**lean**](http://en.wikipedia.org/wiki/Lean_software_development),
and think about possible _clients/users_ and their use cases (_Eliminate waste_). 
If you start thinking about real life use cases you'll figure it out quickly that 
all of them can be solved easier, more efficient and reliable with some dedicated 
solutions. There's humongous number of possible configurations, consistency and verbosity
levels, efficiency requirements etc. For example, to share important financial data 
requiring maximal consistency I would choose something like [Majordomo](http://rfc.zeromq.org/spec:7). 
From the other hand, real time weather notifications can be fault tolerant so we 
can skip whole heartbeat mechanism and just don't give a shit when messages are 
lost. **Using right tool to solve concrete problem**, that's the thing...

### Summary

Ok, that's all folks in this first real post in here. Here's what you should remember
from this lesson:

* Always check if type assertion was correct if you're not sure about the type of
  the interface's value.
* You can expose bi-directional channels easily to read/write-only ones just by
  assignment.
* The gob package is a great tool to serialize and exchange Go values between
  instances - of course remember about registering custom structures.
* Eliminate waste - first rule of _Lean Software Development_, first validate if
  there's real need for your feature.
* And obviously... Keep It Simple, Stupid!

Hope you enjoyed this article, comments are just down here, **don't be shy**! I'm 
very curious about your feedback :).
