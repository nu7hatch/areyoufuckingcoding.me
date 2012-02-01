---
title:      NetChan is no more, shall be ChanIO?
kind:       article
created_at: february 1, 2012
author:     nu7
---

## NetChan is no more, shall be ChanIO?

Just to be clear, it's not gonna be a weblog for total newbies. You have to know at
least basics of Go and you can learn it by going through [**Interactive Go Tour**](http://tour.golang.org/#1).
If you haven't seen it yet, go there and come back when you finish!

### NetChan

Current stable release of Go (r60) still have netchan in standard packages, 
but it already has changed in weekly and netchan will be not included to Go 1.
What do we have in exchange? Nothing!

There's no official package which provides network wrappers for the channels, 
but [this TLTR thread](http://groups.google.com/group/golang-nuts/browse_thread/thread/12bdd37ad9ed4a68?pli=1) 
on [Go nuts mailing list](http://groups.google.com/group/golang-nuts/) brought
few nice ideas. The one I liked the most is a wrapper which allows to bind the
channel with any kind of [`io.Reader`](http://weekly.golang.org/pkg/io/#Reader) or 
[`io.Writer`](http://weekly.golang.org/pkg/io/#Writer) so I started working on it.

When I finished my implementation of it, then I realized that it was trivial
enough to do it without generic solutions. But let's start from the beginning...

### Specification

Let's start from the specification! We want to have a package which solves
the following problems:

* reading data from an `io.Reader` via the Go channel,
* writing data to an `io.Writer` via the Go channel,
* reading or writeing any kind of Go value,
* threadsafety

### Any kind of value?

First two requirements seems to be very obvious, let's take a look at third one.
As you should know, channel needs to have defined type of the data it can 
handle, eg: 

    #!go
    ch := make(chan int)
    ch <- "hello" // wrong! type error during compilation
    ch <- 1       // ok

Yay, great let's allow to define an IO channel for the specified type!... Nope!
Why not? Because it's impossible to use a type as a parameter/variable. In ruby
you can do this:

    #!ruby
    arr = Array
    hello = arr.new("hello", "world")    

In Go you can't do it. I hear you now saying "oh, that language sucks!" :)...
We can use [reflection](http://weekly.golang.org/pkg/reflect/) to get known what's
the type of the value:

    #!go
    switch reflect.TypeOf(x) {
    case reflect.Bool:
            tf := x.(bool)
    case reflect.String:
            str := x.(string)
    case // ...
    }

Unfortunetelly, this is not a good solution because it doesn't allow us to 
operate on any kind of value. We can only distinguish the values for which 
we have defined reflections, and this sucks...

But why should we care about the type? If user defines the channel, he shall
know what types to use and he can assert them by his own. 

    #!go
    ch := make(chan interface{})
    ch <- "hello" // ok
    ch <- 1       // ok too!

Kwak kwak! For the power of duck typing! So now things get simpler, we just
need to write a wrapper for the `chan interface{}`. Everything's cool but am 
I only one worying that this solution is not idiot-proof? An example:

    #!go
    x <- ch
    fmt.Println(x.(string))
    
The code above will compile, while we're using type assertion about which 
you should heard from the Go Tour... But if channel will receive a value of
any other kind different than string, then it will panic! To prevent that
situation you have to check first if the type assertion was correct:

    #!go
    x <- ch
    if str, ok := x.(string); ok {
            fmt.Println(str)
    } else {
            fmt.Fprintf(os.Stderr, "%v is not a string!", x)
    }

So our solution may be confusing for the users, but so far it's the best
thing we have, so let's move forward.

### Reading and Writing

As I said, first two requirements seems to be clear and explicit. But now
we have to consider them to be compliant with the third one. So we need to
be able to write (serialize) any kind of the data into IO stream. 

Go provides an awesome solution of this problem in its standard library.
There's a pacage called [`encoding/gob`](http://weekly.golang.org/pkg/encoding/gob/), 
which implements exchanging of binary encoded Go values between transmiter
(io.Writer) and receiver (io.Reader). This is it! Although the gob package has 
its limitations, it fits the best to our problem:

    #!go
    f, _ := os.Open("~/wire.gob")
    en := gob.NewEncoder(f)
    en.Encode(1)
    en.Encode("hello")

    //...

    f.Seek(0, os.SEEK_SET)
    de := gob.Decoder(f)
    var i int
    var s string
    _ = en.Decode(i) // => 1
    _ = en.Decode(s) // => "hello"

**Note!** I'm leaving `"_"` (ignored value) declaration in single-value context
intentionaly, it's just to let you know that error shall be handled there.

### Implementing Writer

Ok, let's write some real code - binding a channel with specified io.Writer.
We can do it in two ways:

* get a channel as a parameter,
* create new channel, bind it with given writer and return it

First approach seems reasonable and may give a lot of flexibility to the user, 
but also may allow him to fuck things up. For example: user can read data from
the same channel he specified in other goroutine, which may cause data corruption.

To keep this implementation simple and clean, let's assume that it shall not
allow user to bind an IO with existing channel. We also have to prevent the
user from reading data from the returned channel. We can do it by specifying
directional (write-only) channel:

    #!go
    ch := make(chan<- interface{})

Ups, but we have a problem here... If we will create a write only channel,
then we're screwed, becase we can't read from it! But no worries, Go has
great solution for that. We can use bi-directional channel as directional
one just by reference:

    #!go
    var wch chan<- interface{}
    var rch <-chan interface{}
    ch := make(chan interface{}
    wch, rch := ch, ch

We can use that ability to create a channel internally and read from it under
the hood, exposing the write-only part to the user. That's how our `NewWriter`
definition may look like:

    #!go
    func NewWriter(w io.Writer) chan<- interface{} {
	        ch := make(chan interface{})
	        go write(w, ch)
	        return ch
    }

