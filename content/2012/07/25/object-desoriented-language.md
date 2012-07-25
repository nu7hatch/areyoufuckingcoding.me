---
title:      Object desoriented language
kind:       article
created_at: July 25, 2012
author:     nu7
---

Ugh, finally I have spare time back to write something here. I hope you missed me?
This time it will be a short note, which is gonna explain the question I hear
every time when I talk about Go, namely: 

<blockquote>
  <strong>is golang object oriented language?</strong>
</blockquote>

To be honest I'm sick of hearing that question over and over. My plan is
to describe this stuff here, print the URL out on a business card and give it
away every time when some OOP fans will ask me about it.

### Structs at a glance

<div class="meme">
  <img src="/img/meme-magic-1.jpg" alt="Magic!" />
</div>

Speaking shortly, there is no strict answer to our holy question. Golang structs at
a glance can act like objects and may seem to provide inheritance model, eg.

    #!go
    type Person struct {
            Name string
    }
    
    func (p *Person) Intro() string {
            return p.Name
    }
    
    type Woman struct {
            Person
    }
    
    func (w *Woman) Intro() string {
            return "Mrs. " + w.Person.Intro()
    }

In the example above we have the simplest example of something which most of you would
call **inheritance**. For now, let's say that `Woman` inherits from `Person`. The `Woman` type
contains all the fields from `Person`, can override its functions, can do something like
superclass calls. As I said, at a glance it may look like inheritance. Yeah... but it's 
just a trick!

### Is it?

Let's take a closer look and let me explain how it works under the hood. First of all, there's no
real inheritance here. It would be great if you could forget all you know about inheritance while 
you read this stuff... Snap!

<div class="meme">
  <img src="/img/meme-mib-1.jpg" alt="Inheritance? What's inheritance?" />
</div>

Now, imagine struct as a box. Simple, gray, carton box... and imagine fields as _things_, some magic
items you can put inside the box. Here's an example:

    #!go
    type SmallBox struct {
            BaseballCards   []string
            BubbleGumsCount int
            AnyMagicItem    bool
    }

Yeah, that's how our small box may look like. But some day a small box may not be enough, huh?
Or maybe you'd like to segregate your stuff. Then you can take a big box, and put small one
together with other stuff inside, for example:

    #!go
    type BigBox struct {
            SmallBox
            Books []string
            Toys  []string
    }

Splendid, we have a big box which contains all the stuff we have in the small one, plus
some books and toys. And now the magic happens... we can ask:

<blockquote>
  what's in the big box?
</blockquote>

We can answer in a various ways. We can say quickly, that there are books, toys and some small
box, or **we can be more specific** saying that there are toys, books, baseball cards and
some magic items. Both answers will be correct, only on different detail level.
Golang also allows you to specify that level of detail, eg.

    #!go
    bigBox := &BigBox{}
    bigBox.BubbleGumsCount = 4          // correct...
    bigBox.SmallBox.AnyMagicItem = true // also correct

Speaking shortly, `BigBox` **is not a kind of** `SmallBox`, it just **contains** one `SmallBox`
inside, and provides shorthands to `SmallBox` fields.

### Overriding?

In the very first example you saw something like method overriding. Again, you have to forget
about such a term. That magic thing was nothing more than calling a function of the
box sitting inside, from the outer box, like here:

    #!go
    func (sb *SmallBox) Capacity() int {
            return 20
    }
    
    func (bb *BigBox) Capacity() int {
            return bb.SmallBox.Capacity() * 3
    }
    
We defined that a `BigBox` can store three times more items than the small one, but we're
not overwriting the `SmallBox` function here. We can still access them both, obviously 
because they belong to different boxes.

    #!go
    fmt.Println(bigBox.Capacity())          // => 60
    fmt.Println(bigBox.SmallBox.Capacity()) // => 20

However, unambiguous functions may be called from outer box using shorthands:

    #!go
    func (sb *SmallBox) Color() string {
            return "gray"
    }

    // *snip*
    
    bigBox.SmallBox.Color() // => "gray"
    bigBox.Color()          // => "gray"

This is the killer feature which brings fresh breath of the inheritance into Go code.
The `Color` in both calls refers to the same function bound to `SmallBox`.

### Memory skinflints!

Golang in general is a system programming language, and allows us to manage memory
up to some abstract point by using pointers. We can use it to save up some memory
also by defining structs. We can assume that our `BigBox` may, or may not have
a `SmallBox` inside. Until now we've been always keeping memory allocated for a small
box, even though it was not used. We can do this little bit more efficient by embedding
a pointer in our struct:

    #!go
    type SkinflintBigBox struct {
            *SmallBox
            Books []string
            Toys  []string
    }

But there's one trick in here, this **embedded structure acts the same manner as any
other pointer**, so first of all we have to remember to **initialize it**, otherwise
a lot of bad things may happen:

    #!go
    bigBox := &SkinflintBigBox{}
    bigBox.SmallBox     // => nil
    bigBox.AnyMagicItem // ...

<div class="meme">
  <img src="/img/meme-panic-1.gif" alt="Panic!" />
</div>

We have to initialize our small box the same way as any other pointer field:

    #!go
    bigBox := &SkinflintBigBox{SmallBox: &SmallBox{AnyMagicItem: true}}
    bigBox.AnyMagicItem // => true

Yay! Everything works fine now! Also you may want to know that embedded pointer
**can be initialized at any time**, it doesn't have to be done during the outer
structure's initialization.

### It's not magic, it's a trick...

Summarizing, there's no magic here. So called inheritance it's just a special
kind of field which provides shorthands to its functions. Simple, clever and
enough to say OOP fanboys:

<blockquote>
  Sure, it's OOP... <strong>Go</strong> for it!
</blockquote>

<br />

<div class="meme">
  <img src="/img/meme-ilied-1.jpg" alt="I lied!" />
</div>

That's all folks, I hope you like and it and prepare for more stuff soon,
We have a lot to catch up with!
