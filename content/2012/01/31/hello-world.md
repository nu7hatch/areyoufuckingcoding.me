---
title:      Hello World!
kind:       article
created_at: January 31, 2012
author:     nu7
---

## Hello World!

I do programming stuff over 10 years, in my life I had many personal websites,
portfolios and weblogs... Yeah i had weblogs! The problem is that all 
of them get rusted just after writing a *"Hello World"* post.

Well, now it shall be different. I see myself as a mature and reasonable
software developer. I grew up enough to use issue trackers, version control
systems, to understand and use in practice [**The Philosophy of Unix**](http://www.faqs.org/docs/artu/ch01s06.html)... 
woah, I even use Google Calendar to manage my time and Gmail's labels to organize
my mails! Finally, what's the most important, I do have something to say and 
to share with the people.

### The name...

Why _**Are you fucking coding me**_? Huh, because I'm considered to be an asshole
and stubborn perfectionist. I was always looking for the best solution of the 
problems, the fastest algorighms, the best practices etc. Besides my face looks
exactly the same when for example someone writes in Ruby:

    #!ruby
    class Hello
      ["Laurel", "Hardy"].each do |who|
        define_method("hello_#{who.downcase}") do
          "Hello #{who}!"
        end
      end
    end
    
The [**K.I.S.S. principle**](http://www.faqs.org/docs/artu/ch01s07.html) is the 
thing! If you're programming skills are inspired by Hogwarth then <strike>spierdalaj</strike>
go somewhere else, because you'll find nothing interesting here. No metaprogramming, 
no magic tricks, no sophisticated solutions! I will Keep It Simple, Stupid!

### The content?

Like I mentioned at the beginning, I have lot of things to say. Most of that
things are related to **distributed computing**, **messaging queues** (**MQ**),
**cloud computing**, and [**Go programming language**](http://golang.org/).
Recently I become full time Go developer and I have no little piece of will
to go back to Ruby or even Python world! Why? Hmm, maybe it will be good topic
for one the next blog posts. 

Regardless my love to Go, from time to time you may  find useful information about
**Ruby**, **Python** or even **JavaScript**. You will for sure read some **Emacs** 
tricks and tips, **Bash** tutorials or thoughts about **data structures** and weird
**algorithms**. 

### The author?

My name is Krzysiek (Happy pronouncing :P). I'm a 23 years old freak from Poland. 
It's easy to recognize me by my strange hairdos! I'm an [Open Source contributor](http://github.com/nu7hatch), 
BSD and Arch Linux enthusiast, and inline-skating addict. I live in [Montevideo](http://en.wikipedia.org/wiki/Montevideo) 
and work for [Cubox](http://cuboxlabs.com), crafting awesome Go, Ruby, Python, and C code, 
and implementing clever ideas. I play with *nix systems since I got my first computer... 
Woah, it's about 11 years since I installed my first Slackware... 7 times... in one day :D. 
As I said, I'm a typical optimization monster and The Unix Philosophy evangelist.

From time to time you can also meet me as a speaker on various conferences, i.a.
on [The Last RubyKaigi](http://rubykaigi.org/2011/en) or [StarTechConf 2011](http://startechconf.com/).

I'm not very social person, so it's very easy to [follow me on twitter](http://twitter.com/nu7hatch).
You may find there lot of useful links and tricks, and from time to time mentions
of stupid things I've done being drunk on the party.

### Hello Go World!

Ok, it's a *Hello World* post, so lets write some hello world code at the end.
Thus this is going to be a Go related weblog, let it be in Go then:

    #!go
    package main
    
    import "fmt"
    
    func main() {
        fmt.Println("Hello Go World!")
    }

You can run this code, play with your own stuff and share it online using 
[Go playground](http://play.golang.org). 

**Important!** At the moment Go playground allows to run code compliant with r60 release 
version. Because of that a lot of my future examples may be broken while I'm using 
weekly releases in my work. Anyway, you should do the same! Faster you start working
on weekly release, then easier will be transition of your apps to Go 1 (which is very
close to release!). 

### Stay tuned!

That's all in this post, I hope you get interested in my stuff. Feel free to comment
above, I will appreciate any feedback! And of course stay tuned, bunch of posts shall
show up soon. Cheers!
