---
title:      "GoTip #1 - Adapt blocking IO to a channel"
kind:       article
created_at: August 03, 2012
author:     nu7
---

And here it is, my first of many short notes with gotricks and gotips. Today
I'm going to describe a trick which allows to **combine blocking IO 
reads together with Go channels**.

### The problem

Let's take a look at this example:

    #!go
    func run() {
            for {
                    select {
                    case <-stop:
                            return
                    case <-time.After(5 * time.Second):
                            if _, err := conn.Write([]byte("ping\n")); err != nil {
                                    return
                            }
                    }
            }
    }

Pretty simple, huh? We have a control function which either waits for
notification on `stop` channel, or sends ping every 5 second. Now the problem
is how to add reading from the connection to this statement. We can't just
add it since `net.Conn.Read()` is **blocking IO operation**.

### The solution

The most neat solution for this problem is to write a **generator function**,
which adapts IO reader to a channel. Generator __pattern__ is a function
which runs goroutine inside of it and returns a channel being a tie between
current context and the goroutine.

    #!go
    func listen() <-chan []byte {
            c := make(chan []byte)

            go func() {
                    b := make([]byte, 1024)

                    for {
                            n, err := conn.Read(b)
                            if n > 0 {
                                    c <- b[:n]
                            }
                            if err != nil {
                                    c <- nil
                                    break
                            }
                     }
            }()
            
            return c 
    }

What are we doing here? The `listen` func above opens a channel - this is
where the data read from the IO will be passed. From my previous notes you
should know that in such situations **it's good to return read only version of 
the channel** to avoid quirks. Second thing `listen` does - it runs 
new goroutine with a loop, which reads from our IO and passes stuff
forward to the channel. Note, that when connection meets
`EOF` error, it passes `nil` there - we will use that value to exit
from `run` when IO is closed. Of course this is very dummy example, in
more sophisticated apps you can use a message strucst containing all the
error information, data, etc. It's all up to you.

Anyway, now we have to tie it up together with our `run` control func:

    #!go
    func run() {
            read := listen()
            
            for {
                    select {
                    case <-stop:
                            return
                    case b := <-read:
                            if b == nil {
                                    return
                            }
                            // Do something with the data... 
                    case <-time.After(5 * time.Second):
                            if _, err := conn.Write([]byte("ping\n")); err != nil {
                                    return
                            }
                    }
            }
    }

We simply get the `read` channel returned from `listen` and have to
add a case for it to the `select` statement. According to what I said before
about passing `nil` data on `EOF`, we just exiting when it happens.

Oh, you may ask why passing `nil` around instead of sending something
to `stop` channel. Good question, but we can't do this... I'm short on time
now, so I'll explain it in next __GoTips__ episode. Stay tuned!
