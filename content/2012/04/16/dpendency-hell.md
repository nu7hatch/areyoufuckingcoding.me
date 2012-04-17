---
title:      Dependency Hell
kind:       article
created_at: April 16, 2012
author:     nu7
---

The recent wave of hate about Go's dependencies management and subsequent wave of ideas on
how to "fix" it, i.a. [goven by Keith Rarick](https://github.com/kr/goven) and 
[this thread](http://groups.google.com/group/golang-nuts/browse_thread/thread/d1abee8965114909/b48d73c43943b9bc)
on the go-nuts mailing list pushed me to some thoughts. In this post we
will take a closer look at the _problem_ so many people found in Go
and possible solutions for it.

### The problem(?)

First of all... what's the problem? That evil thing, shouted loudly by
everyone is that the current way of dependency management does **not protect**
them against bugs and changes in external packages. Some external
dependency may change and break our code in the future or break our
production environment!

<div class="meme">
  <img src="/img/meme-omg.jpg" alt="OMG" />
</div>

Hmm, is that actually the problem? IMHO that's not the real problem but
just the effect of another, separate problem. Namely: misunderstanding of versioning
and dependencies recognition. So, let's clarify some things, and
let's do it from very very beginning...

So, what's **software versioning**? Or more explicitly, why do we need
software versioning? Speaking shortly, **software versioning is the way
to distinguish changes in the code**. The main job of versioning is to
tell developers what has changed between the different versions. It also
serves users by telling them  whether their software is stable or not, or to
make the bug reporting process easier and more accurate.

Now, what's the **dependency**? Dependency my friends is **someone elses's
piece of crap without which your piece of crap doesn't work**.

### Versioning vs. dependencies resolving

Now, some homework for you guys... Find a reasonable relationship between
software versioning and dependencies resolving.

Speaking for myself, I found none. Because there are no relationships
between them. Software versioning and dependencies resolving are totally
different things. Now I can already hear you guys screaming:

<blockquote>
  So how can I specify on which version of the software my code depends?
</blockquote>

And here we are: **You don't have to know that**! Let me put it
this way: your code depends on packages _X_ and _Y_. Now, package
_Y_ also depends on package _X_. If you make both dependencies
fixed on an explicit version (or range of versions) then you may cause
**dependency hell** between those packages or get blocked in
the future. For example you may not be able update _Y_ without
updating _X_.

Once again, this is not the problem, only a side effect of using versions
in deps resolving. Of course, instead of eliminating the source of the
problem many people try to make the effect less painful - like the
Bundler gem in ruby or some super smart package managers. **But you don't
need that**. In case of dependency management you **should depend
on the major version exclsively** - moreover, you should consider
different major versions as **different packages** (eg. _foo-1.0_ 
and _foo-2.0_ should be treated as different package with no relation
whatsoever between them, more explicitly _foo1_ != _foo2_).

There's also very important thing all the maintainers should know:
**There should be no API changes between minor version changes and patch releases, motherfuckers!**.

<div class="meme">
  <img src="/img/meme-bugs-1.jpg" alt="Bugs, bugs, buuugs!" />
</div>

Yeah, but even if you follow the rules and you don't change the API
between minor versions other problems or bugs might still pop up,
nobody's perfect. What then?

The simplest solution is to just downgrade the package to the first
working version and report the bug, including infromation like from which
version you have being forced to downgrad and which one solved the problem. 
**This is the moment when versioning is usefull**. This is also how
software improves and gets rid of bugs :P.

Anyway, now we're finally comming back to the big _"problem"_ that everybody seems to be whining about...

### I can't deploy shit!

Now, again, I can just hear a bunch of pepole screaming:

<blockquote>
  Are you fucking insane? I want to do a one click deploy without dealing
  with packages on the production server.
</blockquote>

It's reasonable that you want to make deploys fast and safe. But why do you
want to deal with those packages anyway? There's one thing I can't 
understand at all: why the hell do you treat dependencies as a separate part of 
the software!? If you work on production-ready applications, you should
not care about dependency management. Without this external piece of 
crap your crap doesn't work... more explicitly: this external crap 
is part of your crap now. Instead of specifying a bunch of fixed dependencies 
in a text file or complaining about the dependecy management in Go 
just add this external stuff to your repository and **keep it together**.

Having all the dependencies versioned in your project's repository
relieves you from having to care about the installation of dependencies in the production
environment - **because you're deploying the whole env**. You also have
full flexibility to deal with the upgrading and downgrading of those
dependencies. If you use `git` then you can use **submodules**. If the
dependencies are versioned with `hg` then you can keep mercurial information
there and have access to the repo. You can also apply **monkey patches
or bugfixes directly in your environment**. Finally, you can keep
**different versions of the packages for different projects**.

### Go approach

I hope that after the following examples the approach that spawned so many
controversies will finally be considered as a great feature, not a
problem. For those who don't know how it works: Go's import path is 
3 in one - it shows from where to download the external package, where to install
it and later load it from at compile time, and what import name you should
use in your code:

    #!go
    import "github.com/nu7hatch/gouuid"

The convention is simple to implement and really powerful, but needs a
pivot in your programmer's mindset. I also agree that it requires a few
tweaks to make it work in a handy way.

### Tweaking!

To make it work as expected first we should describe exactly what we
want to achieve. I want to tweak the Go tool in a way which will meet the
following requirements:

1. I don't want to change the code I wrote so far (no difference in import paths).
2. I want to keep tracking dependencies (be able to update/downgrade versions).
3. I want to be able to monkey patch or bugfix directly into the package.
4. I want to deploy code safely with a single command (safely = with the same effect
   in production as in development).
5. I want to set a project up on a different machine with one command
   (eg. to bootstrap another copy for some other developer).
6. Deployment should not be dependent on any external resources or repositories.

The first point is obvious so we'll just skip it. The second one - I want to track
dependencies, which means I don't want to vendor them like `goven`
does. Point three affects the previous one as well - I want to keep track
of the external package and at the same time I want to be able to fix 
it or change it. The remaining points are also obvious - we want to deploy or
setup our project as fast as possible - preferably with one command.

How do we implement something like this in real life? The first thing that came to
my mind was the `GOPATH` behaviour. I didn't feel like it is really needed and I
had right, it's not needed at all. Instead of specifying `GOPATH` or dealing with
it for different environments we can just add something unique which will allow
`go` tool to say _woot! we're under gopath, let's use local stuff now!_. It may be done
in the same way version control systems work - eg. by adding an empty `.go`
file to our environment:

    myappenv/
      .go
      bin/
      pkg/
      src/
      
The implementation is very simple. I just patched the `src/pkg/go/build.go` file
with this code:

    #!go
    func discoverLocalGOPATH() (gopath string, ok bool) {
	        var pwd, dotgo string
	        var err error
	
	        if pwd, err = os.Getwd(); err != nil {
		            return
	        }
	        for ; pwd != "/"; pwd = pathpkg.Dir(pwd) {
		            dotgo = pathpkg.Join(pwd, ".go")
		            if _, err = os.Stat(dotgo); err == nil {
			                gopath, ok = pwd, true
			                return
		            }
	        }
	        return
    }
    
    func defaultContext() Context {
	        var c Context

	        c.GOARCH = envOr("GOARCH", runtime.GOARCH)
	        c.GOOS = envOr("GOOS", runtime.GOOS)
	        c.GOROOT = runtime.GOROOT()
	        c.GOPATH = envOr("GOPATH", "")

	        // We have to prepend a local GOPATH if we find an `.go` file
	        // in one of the parent locations of current directory.
	        if localGOPATH, ok := discoverLocalGOPATH(); ok {
		            c.GOPATH = localGOPATH + ":" + c.GOPATH
	        }
            
            // *snip*
      
That's how we get rid of the annoying `GOPATH`, or actually make it more
useful and intuitive - different environments with no configuration at 
all. The local env is recognized by its `.go` file and the path to this directory
will be prepended to `GOPATH`.

Now the hardest part - dependnecy tracking. Lets say our application
is `myappenv/src/acme.com/foobar` and depends on a few other packages.
Instead of versioning this application only and looking for the way
to track dependencies, let's version `~/myappenv` directly. Lets do it
with git as an example:

    $ cd ~/myappenv
    $ git init

If we depend on mercurial based projects, then it's easy - just add them
to the repo with all the `hg` files. If we have git based dependencies
then it's more tricky, because git doesn't allow the tracking of nested repositories
without using submodules. It forces us to patch one more thing out there.
This time in the `src/cmd/go/vcs.go` file:

    #!go
    // first we have to add submoduleCmd to vcs configurations:
    var vcsGit = &vcsCmd{
           // *snip*
       	   submoduleCmd: "submodule add {repo} {dir}",
           // *snip*
    }
    
    // ... Now we have to extend create function:
    
    func (v *vcsCmd) create(dir, repo string) error {
	        rootV, root, ok := vcsForLocalRoot(v)
	        if ok {
		            dir = strings.TrimLeft(strings.TrimLeft(dir, root), "/")
		            return rootV.run(root, rootV.submoduleCmd, "dir", dir, "repo", repo)
	        }
	        return v.run(".", v.createCmd, "dir", dir, "repo", repo)
    }

To avoid overhead of code I can just tell you that `vcsForLocalRoot` func
checks if we're in a local env, if so it checks if it's versioned with
the same version control system as our dependency, and if so it adds that
dependency as a submodule instead of cloning it directly. Everything else 
remains the same. [You can get the patched version and try it out](http://code.google.com/r/chris-go/source/checkout).

How do we use it now? Very simple - first of all throw your `GOPATH` configuration
away, you don't need it anymore. There's one more new feature added there,
the `init` command:

    $ go init ~/myappenv
    
You can also specify which version control system you want to use:

    $ go init -c hg ~/myappenv
    
This command will create the environment structure in a specified directory
(the directory doesn't need to exist). I'm a lazy bastard, I didn't add a
few things there yet, i.a you have to create the ignore file on your own, 
it should contain:

    /bin/*
    /pkg/*
    
You also have to make initial commit manually, eg:

    $ git add . && git commit -m "hello go"
    
When you write some code and want to download dependencies, just run
`go get` as usual. Remember that you have to commit changes after 
dependnecies are installed:

    $ cd ~/myappenv
    $ go get ./...
    $ git add . && git commit -m "added X and Y deps"

### Bootstrap, deploy...

Using this approach you have the whole environment necessary to run
your application in one place, safely versioned in your application's
repository. You can deploy or boostrap this application quickly and
in 2 steps.

    $ git clone git@acme.com:myappenv.git
    $ cd ~/myappenv
    $ git submodule init && git submodule update

We can definitely call it a one click deploy :P. What's more important,
the deploy doesn't depend on any external sources, everything's bundled
there with your project. We also have full control over each part of
the system - each dependency can be separately updated, changed or
patched. You can even replace the repository source with your monkey patched
fork without affecting the import paths in your sources!

<div class="meme">
  <img src="/img/meme-marvelous-1.jpg" alt="Marvelous!" />
</div>

### Summary

I'm curious about your oppinions and feedback about the stuff I wrote. From the short
reaserch I've been doing everyone appears to love getting rid of `GOPATH` in favor
of local environments. A few persons I asked around are still confused about
dealing with submodules - to be honest I'm not 100% convinced to this
approach yet, but so far it's the best I've found and matches the requirements
I wrote down. I'm sure we can improve that part together. That's all folks,
waiting for your comments.

Like always thanks to [pote](http://twitter.com/poteland) for reviewing
my ugly english.
