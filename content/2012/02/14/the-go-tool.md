---
title:      The go tool
kind:       article
created_at: February 14, 2012
author:     nu7
---

On the wave of the latest weekly release introducing **new go command** I decided to write
a little about it. I have to admit that when I heard about the idea of unified **go** tool
for the first time I was little bit skeptic and full of fears. I was worrying that it's gonna
be fucked up like most of the other language-specific package managers. IMHO most of such 
package managers are reinventing the wheel and coliding with the operating system PMs which
makes sysadmins' life much harder. What's more, I actually really liked makefiles, they were
simple and straightforward, and just worked fine. Fortunetely, **new go tool dispelled 
all my fears!**

### Don't repeat...

Lot of information about new go tool shown up recently on the 
[**go nuts**](http://groups.google.com/group/golang-nuts/browse_thread/thread/b4bb313b64b8ca84/4bc3cda688c04b57?lnk=gst&q=the+go+command#4bc3cda688c04b57)
mailing list. The official go documentation also includes now some short article about
[**how to write go code**](http://weekly.golang.org/doc/code.html) using new go tool. 

Anyway, I think there's still a gap in the docs at this point, so it makes reasonable to write
fast introduction to new go tool and demonstrate some usefull tricks.  

### Convention over configuration

That was a source of my biggest fears, mostly because of my experience with Ruby on Rails. 
All Rails-familiar developers shall agree with me that every time when you try to do 
something a little bit hacky, a little bit tricky, something which doesn't follow the 
rules, it's just...

<div class="meme">
  <img src="/img/meme-impossibru.jpg" alt="IMPOSSIBRU!" />
</div>

But let's talk about good practices. First of all, each of the go tools does only one
thing, and does it right. We have there i.a:

* **`go build`** - to compile the package, 
* **`go get`** - to resolve and install the dependencies,
* **`go test`** - to run test suites and benchmakrs, 
* **`go install`** - to install the package,
* **`go doc`** - to generate documentation, 
* **`go fmt`** - to properly format your code, 
* **`go run`** - to build and run the apps,
* **`go tool`** - to call extra tools,
* etc...

Go packages **don't have any build configuration** at all. There's no makefiles, no 
descriptions of dependencies etc. How it works then? Everything is retrieved from the
**source code**. To let the magic happen one thing has to be done first. You need to 
specify where your go stuff will be located. The **`GOPATH`** environment variable defines
paths to the go trees. For example, the following line in your `~/.bashrc`:

    #!sh
    GOPATH="/home/nu7/gocode"
    
...tells the go tool that your go tree is located in the specified directory. But you
may ask **what the go tree actually is**? Speaking shortly, it's a place where **all your
go sources, packages and commands will be located**. Take a look:

    $ ls /home/nu7/gocode/
    bin   pkg   src
    
All the sources will be located in the `src` folder. By all the sources I mean both, 
your applications, packages and dependencies as well. The `pkg` folder contains compiled 
and installed packages, and `bin` installed commands.

The `GOPATH` variable works very similar to `PATH`, you can set as many go paths
as you want. You have to only remember that first one is the main one, so all 
the stuff installed via `go install` will go there.

### Resolving dependencies

There's no configuration files describing dependecies... so how the heck go tool may 
know what to install and from where to download it! You think there's some repository? 
Nope, there's not! Go introduces something called **importpath**, take a look:

    #!go
    import "github.com/nu7hatch/gouuid"

The import path is 2 in 1. It's a repository URL and path to the location where the
package has been installed locally. The **`go get`** tool just by looking at the import
path knows from where to fetch the dependency, and **`go build`** knows from where to
import them locally.

To **install dependencies in your system**, you have to use `go get` tool that way:

    $ go get package-name
    
Wait, wait, wait... what's the package name here? It's the name of the package you 
want to install dependencies for. Assuming you have a package named `foo` in your go 
sources, calling `go get foo` will install all its dependencies. You can run the tool
directly from the package as well:

    $ cd ~/gocode/src/foo
    $ go get .
    
All other go tools works the same and can be called directly from the package or
by specifying it's import path. It's also possible to **execute a tool on the group 
of nested packages** using **`...`** (three dots) wildcard. If our `foo` package contains
some nested packages, dependecies for all of them can be installed at the same time just
by calling:

    $ go get ./...  

If you already have specific dependency installed in your go tree, then **it will be 
not updated** until you explicitly request that. To update packages while installing
dependencies you need to run **`go get`** with **`-u`** flag:

    $ go get -u package-name

Simple, isn't it?

### The dependency hell!

There's one more convention of the go tool I really like, but I'm afraid of at the
same time... Go tool resolves dependencies by **checking out HEAD version** of the 
repository. That forces package maintainers to [**keep backward compatibility**](http://semver.org/)
and...

<div class="meme">
  <img src="/img/meme-jules-1.jpg" alt="GREEN MASTER MOTHERFUCKER! DO YOU HAVE IT?" />
</div>

**Green master policy** is something I was always insisting at my work. The default 
branch is something that people always check out at the beginning, so **it shall be
green**, or at least **it have to work**! Once officially published, or once reaches
maturity **it should be backward compatible** as well - we can't deprecate things or 
change the API between the patch or minor versions. 

But we all know how it looks like in practice. Lot of people don't give a shit about
backward compatibility, they treat default branch as a playground, etc. For all those, 
and acually for all developers who want to live in peace with new go tool I have some
set of rules...

<div class="important">
  <h4>Rules you should follow in your fucking programmer's life:</h4>
  <ul>
    <li><strong>Keep your fucking master green!</strong></li>
    <li><strong>Work on fucking new feature in a fucking separate branch!</strong></li>
    <li>Once you published your code and someone is using it, <strong>don't fucking 
    change the API!</strong></li>
    <li>If you want or need to change the API, <strong>change the fucking major 
    version</strong> and <strong>work on a fucking separate repository derived 
    from the original one!</strong></li>
    <li>If you highly, <strong>very highly</strong> need to use some particular tag, 
    branch or commit as a dependency, <strong>use your fucking own fork of the repository 
    pointed by default to the fucking commit you need!</strong></li>
    <li>Oh, and <strong>keep it simple</strong>, motherfucker!</li>
  </ul>
</div>

And don't make me recite the Ezechiel's book to make you remember that...

### Building and installing

Ok, let's go back to the go command. The `go build` command is used to compile the
package. It only builds the package, doesn't install it. What's also important, 
**it requires the package to be checked out in the local source tree**. To install
remote package you will use `go get` instead:

    $ go get github.com/nu7hatch/gouuid
    
To install local package obviously `go install` tool will be used. It builds the
package first (if it's necessary) and then installs it under `$GOPATH/pkg` or/and
`$GOPATH/bin`.

The go tool is also able to **ignore files during the build**, obvioulsy without
extra flags and special configuration. The only thing you have to do to ignore a file,
is to prefix its name with underscore:

    $ ls
    _bar.go   foo.go
    $ go build .
    
In the example above `_bar.go` will be ignored during the build.

Hmm, and that's it... I think there's nothing more to say about it, let's move forward.

### C extensions with CGO

Go comes with really great support for **building C extensions** with [cgo command](http://http://weekly.golang.org/cmd/cgo/).
Actually, to build most of C-powered applications you don't even need to know about `cgo`, 
the `go build` tool is more than enough.

To be honest there's not too much to say about `cgo`, while most of stuff is described 
clearly in the docs and in [**article from the go users wiki**](http://code.google.com/p/go-wiki/wiki/cgo). 

First thing I'd like to mention is something I really don't like, namely putting C 
source code within the comments as it is presented in most of the official examples. 
You have to know that those examples are presented that way mainly to minimize amount 
of code and show each example in a single file. In a real-life application **C code 
shouldn't be placed in the comments block**! The `go build` tool is smart enough to 
handle `.h` and `.c` files in your package.

Some example? Let's say we want to write simple `echo` command which prints all 
arguments on the screen, but using the `printf` function from `stdio.h`. As it's 
mentioned on the wiki page, **go doesn't allow to call C function with variable
number of parameters**, so we have to write a small wrapper for the `printf` function.
Our code may look like this (also available [on github](http://github.com/nu7hatch/cgoecho)):

`echo.h`:

    #!c
    #ifndef _ECHO_H_
    #define _ECHO_H_
    
    #include <stdio.h>

    void echo(char*);

    #endif /* _ECHO_H_ */

`echo.c`:

    #!c
    #include "echo.h"
    
    void echo(char* s)
    {
        printf("%s\n", s);
    }

`echo.go`:

    #!go
    package main
    
    /*
    #include <stdlib.h>
    #include "echo.h"
    */
    import "C"
    
    import (
            "flag"
            "unsafe"
            "strings"
    )
    
    func main() {
            flag.Parse()
            cs := C.CString(strings.Join(flag.Args(), " "))
            C.echo(cs)
            C.free(unsafe.Pointer(cs))
    }

Now you can build all the things seamlessly with the `go build` tool. It will 
recognize and compile all C files found in your package. Speaking shortly it
just works!

<div class="meme">
  <img src="/img/meme-notbad-1.jpg" alt="NOT BAD" />
</div>
   
### Platform specific builds

Another cool and interesting thing is that `go build` can handle compilation of
platform specific files. It recognizes such files by its names (it has to be like
`file_GOOS_GOARCH.go` or `file_GOARCH.go`):

    foo_darwin_amd64.go
    foo_386.go
    foo.go

This feature works with C files as well:

    foo_amd64.c
    foo_386.c
    foo.h
    foo.go

As they say in the docs, you may never need that features, but I wanted to mention
it to give you a picture of how flexible the go tool is despite its simplicity.

Ok, but some of you may ask, what if there's a need to do some tricky thing which 
requires weird compiler flags or some configuration, etc...

### Makefile to the rescue!

Yes, don't be afraid of using makefiles! It's the easiest and quite convenient
way to deal with extra configuration, some prerequisites etc. Makefiles can
be helpful not only in C extensions but in multi-package applications as well
(eg. in [webrocket](http://github.com/webrocket/webrocket) we're using a top 
level  makefile to make our life easier). 

More explicit example... Imagine an application which contains a core package and
a command line tool based on it. We can stick to the echo example, but in more
modular way:

    echo/
      pkg/
        echo/
          echo.c
          echo.h
          echo.go
      cmd/
        echo/
          echo.go

We want the `pkg/echo` package to provide a reusable wrapper for C `printf` function, 
and its source looks almost the same as in previous example. The `cmd/echo` command 
is going to be an executable which is using the core package to display things on the 
screen. The `cmd/echo` command may look like this:

    #!go
    package main
    
    import (
            "github.com/nu7hatch/cgoecho2/pkg/echo"
            "flag"
    )
    
    func main() {
            flag.Parse()
            echo.Echo(flag.Args()...)
    }
    
**Note:** For those who don't know what `slice...` means, it just maps a slice to 
variable number of arguments, something like `*args` in Ruby. 

Going back, to simplyfy our work with the package we need some `Makefile`. It may look 
like this: 

    #!make
    all: echo-pkg echo-cmd
    
    echo-pkg:
        go build ./pkg/echo
    
    echo-cmd:
        go build ./cmd/echo
        
Now we are able to quickly compile both, package and command just by calling **`make`**,
and what's more important, **we can still use the go command to install it remotely**:

    $ go get github.com/nu7hatch/cgoecho2/cmd/echo

Of course this is very simple example, we can use the wildcard call to build all the stuff
quicky and with no fuss:

    $ go build ./...
    
But dealing with bigger applications, containing many packages and/or commands may 
be tricky. Then **it's very reasonable** to use makefiles, shell scripts or any other 
build tool you like.

### Summary

I have to say it clearly, **I fucking love new go tool**! I encountered bunch of problems
while playing with it for the first time, but most of the issues was caused by some bad 
habits I've gained while using other package mangers/tools. Hah, recently I asked a lot 
of stupid question on the go-nuts IRC channel and the answers I get were ridiculously 
obvious and simple...

Now looking through my shoulder at all the tools I was using before, like `easy_install`, 
`rubygems` or `bundler`, I have only one picture of them in my mind... Oh, I'll better
not publish it because more people may hate me :). Instead, I can show you how do I 
see the new go tool...

<div class="meme">
  <img src="/img/meme-superman-1.jpg" alt="..." />
</div>

I'm very happy to see Go going in a good direction! That's all for today, take care 
Gophers!
