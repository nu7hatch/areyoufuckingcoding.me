---
title:      Nothing really matters
kind:       article
created_at: March 25, 2012
author:     nu7
---

It's been over a year since I joined [Cubox](http://cuboxlabs.com/). Last
few days, visiting my motherland and participating amazing
[wroc_love.rb conference](http://wrocloverb.com) led me to reflections.
The most funny is that all my technical and non-technical reflections 
started joining together and clarifying my hacker's mindset.

These reflections were also heaviliy inspired by many people, i.a. drunk 
[apotonick](http://twitter.com/apotonick) all the time repeating that 
__Nothing really matters__ :). Let me tell you how true this sentence is
in case of your business, code and even life.

### Hack or not to hack?

I joined Cubox as a hacker, geek and crazy optimization monster, doing
lot of cool stuff, tweaking things up, learning and enjoying the code.
This blog post will be a retrospection of all the things I screwed and
the cool things I figured out during last year. All the things about 
designing applications, about building them, about choosing right tools... 
and about business behind all of this. It will be about my metamorphose 
from a typical optimization monster into devoted K.I.S.S. evangelist and
lean approach enthusiast. It will also show you how I understand Lean
Startup and how do I think lean code should look like.

### Integration vs. acceptance testing

First idea I was working on at new job was a way to speed up slow Selenium 
tests. I was figuring out many weird things, from improving speed of ExtJS, 
through faster ruby driver for V8 engine and at the headless browser
C++ library ending. Woah, that was a total failure. It was like this...

<blockquote>
Yeah, there's V8 engine and it's awesome, and there's therubyracer
but is very slow so let's speed it up, oh but if we use ExtJS it still
sucks, I can write everything in C...
</blockquote>

But meanwhile I realized way more important thing. Instead of speeding up
the tool, very complicated tool, we should speed our tests up. Besides
**the idea of running integration tests is to test if all the parts of
a system are composed into one integral application in production
environment**. There's no point to test the app in some virtual environment
which just symulates (poorly) all the others, widely used.

Also, I started listening to many people around, and they all spoke 
laudly and with confidence:

<blockquote>
It's Cucumber fault that our tests are slow! Cucumber is too slow!
</blockquote>

Or others, including me:

<blockquote>
It's Rails fault! It's too slow at boot so our tests are slow!
</blockquote>

And we started using some pure RSpec tests based on Capybara, figuring out
how to optimize Rails etc. But it was the same... Capybara, Cucumber, RSpec 
and Rails are only tools. They don't matter, it's **only a delivery method** 
for some part of our logic. **The logic which supposted to be tested**.

Few days ago, I was on horrible hangover, drinking some [mate](https://twitter.com/#!/nu7hatch/status/179605961886015488)
with [DrummerHead](http://twitter.com/DrummerHead) and reading again
[godfoca's](http://twitter.com/godfoca) internal mail about the bussiness 
value of splitting stories up into tasks (maybe he will publish it, worth
reading), juggling with some DCI papers around and listening to 
[Uncle Bob Martin's talk at Ruby Midwest](http://confreaks.com/videos/759-rubymidwest2011-keynote-architecture-the-lost-years). 

Then I figured something out... I didn't figured out actually, I just realized
something. I think that user stories havily and laudly promoted by BDD 
and Cucumber are simply describing wrong things. Let me put it this way, 
they test things that don't matter at all for your business. Take a look
at the story:

    In order to drink a beer
    As a bar client
    I want to go to the bar
    Order a beer
    And when I pay for it with cash
    I want to see my beer on the table
    
Hey, guys, no offence... but that sounds retarded. Besides, that's just 
a GUI testing! Some people may want to pay for the beer by card, or open 
a check and pay everything at the end. Others may want to order a beer from
the table without going to the bar. That kind of the story doesn't test
your business requiremenets, they don't apply to your domain logic! Your 
`Client` domains should be:

    - Drink a beer
    - Be able to pay with cash or by card
    - Be able to open check and pay at the end

You may notice that I don't mention the `bar` at all, because that's only
our **delivery method**, that's only framework which may change in the
future. Going to the `bar` is not `client` domain here. We may change `bar` 
into `delivery service` or `cute blonde waitress` and his domain
doesn't chage. He will be able to drink beer and pay for it whatever
he wants. **Acceptance tests are supposed to test domain logic, not 
the delivery method**. Delivery method is only a tool, a plugin which 
may be replaced at any time, without affecting your business model.
Delivery method should be tested by **integration tool** and be part
of the **continuous integration process** only!

Uncle Bob said something great, something I was repeating many times
but some laud Rubyists around had different oppinions...

<blockquote>
Suite of tests is not there to satisfy the QA groups, suite of tests 
is not there to proof to other people that our code works. The suite 
of tests is there so that we can refactor. So that when we bring the 
code up to our screen then we're not afraid of it. 
</blockquote>

Think about it guys...

### More and more hammers

Second thing I recently realized was how patological is application
design process. Most of the projects we were realizing from scratch 
starts from pointless discussion which framework is better, what database
should we use, what templating system should we apply, etc. **We are
discussing not important crap**!

<blockquote>
- I bet we gonna have a lot of writes, let's use Cassandra! <br />
- Bullshit, there will be lot of reads too, Redis is the best! <br />
- Fuck you! Let's do something simple first and then optimize, 
  we gonna start with MySQL! <br />
- I don't wanna live on this planet anymore... <br />
</blockquote>

Maybe I am exaggerating, but there's a lot of bootstrap conversatons
looking like this. But you know what, __nothing really matters__...
Those who have seen Uncle Bob's talk at Ruby Midwest should already 
know that databases and frameworks are **only tools**, all this stuff, 
all the hammers are **only plugins** and should be treated so.

### Lean hacking?

Besides, thus databases and frameworks are only delivery methods, we
don't know at the beginning which one to use anyway. To be lean you 
have to deliver minimum viable domain model to your users and learn
from how they react. **The way how you deliver your domain logic
is not important at all**. 

Lean startup book becomes extremally popular in the last time. It has
been especially adopted by all the Rails developers and dev shops. 

<blockquote>
Yeah, we're fantastic because we can build a Rails app in 2 weeks
and validate your idea!
</blockquote>

But again, Rails is only a tool, Rails doesn't determine the process
of the lean product building. None of tools does it! **Lean approach
is this one which allows you to validate your domain model fast by
measuring reactions of the users of your product**. A minimum viable
product. If you make your domain logic (your idea) validation dependent
on the tool, on the framework or on the database then you're not lean, 
then you are lost in dependencies' and tools' hell every time when you
want to change something. You are not lean, just an Agile Rails Development
shop or any other framework hyper! **Lean is about eliminating any kind 
of waste**. Oh, what's that? Aren't all the dependencies, plugins
and tools which affects your domain model such a waste? 

### Clients from hell...

Yeah, but we have to do the clients work, we have to deliver things,
we have to match their expectations, right? You know what... now
with humongous confidence I can say NO! Clients has some ideas, wants
to realize them to check if they're ok. **But the time of designing 
the app client wants is the time of first validation** as well. Most of 
developers used to say:

<blockquote>
Oh, that client wants to do some shitty reports there. We know that's
shit but they want to have it, let's do it then...
</blockquote>

But that's wrong! **Lean consultants should help the client to find
the best way to validate his product and eliminate waste**. If you 
think that something client wants is a piece of crap and nobody is 
going to use it **say about it**. Insist to measure user needs. Doing 
all the features required by the client in super fast time doesn't mean
to be lean. **Being lean means that you are a logical filter for all 
the client's bad ideas** - this is the very first validation of his
product. 

Second problem with the clients is that they used to come with a sentence:

<blockquote>
We have an idea for a <strong>Rails application</strong>.
</blockquote>

No motherfucker! You don't want to build a Rails app, what you want to
build is **an application**. It may become a Rails app, it may become a 
Sinatra app, it may be even a console app, it doesn't matter. As I said 
before that's only a delivery method, and from the lean perspective... 
it's nothing else than **waste**. Mocks are friends of lean approach,
**mock everything you can, that's the fastest way to see if your potential
users are going to like it or not**.

### (C)lean code...

You know what, let's drink some beer now. But let's do it little bit
different way. We gonna do it from Ruby today, sorry to all the Gophers
reading this article. I'll make some special episode about DDD in Go next
time. We're going to start from writing the story and tests - that's how
TDD, BDD and other *DD variations works. **You have to write tests first**,
otherwise you just waisting time (eliminate waste, remember?).

    #!gherkin
    Feature: Drinking beer
    
      Scenario: Drink a beer
        When I pick a beer
        Then I want to drink the beer I choose

Let's say we want to have a beer drinking service:

    #!ruby
    When /I pick a beer/ do
      @drinking = BeerDrinkingService.new
    end
    
    Then /I want to drink the beer I choose/ do
      @drinking.call.should == "Pssst! Gulp, gulp, gulp... aaaah!"
    end

Now we exactly know what we want to do, we need a beer:

    #!ruby
    class Beer
      def drink
        "Pssst! Gulp, gulp, gulp... aaaah!"
      end
    end

... and some client who wants to drink it:

    #!ruby
    class Client
      def drink_a_beer
        Beer.new.drink
      end
    end
    
Finally, we have to provide some way for the client o drink the beer 
easily, we need some **interaction**:

    #!ruby
    class BeerDrinkingService
      def initialize
        @client = Client.new
      end
      
      def call
        @client.drink_a_beer
      end
    end

And you know what, that's already our minimum viable product! We have
a client who can drink a beer, lovely! After we show it to potential clients 
they may not want to drink just some random beer. Maybe they want to select
their favorite... Scenario first:

    #!gherkin
    Feature: Drining beer
    
      Scenario: Drink a favorite beer
        When I pick my favorite "Belfast" beer
        Then I want to drink the beer I choose
    
Tests may looks like this:

    #!ruby
    When /I pick my favorite "(.*)" beer/ do |beer_brand|
      @drinking = BeerDrinkingService.new(beer_brand)
    end
    
    Then /I want to drink the beer I choose/ do
      @drinking.call.should == "Pssst! Gulp, gulp, gulp... aaaah!"
    end

And the code...

    #!ruby
    class Client
      def drink_a_beer(brand)
        Beer.new(brand).drink
      end
    end
    
    class Beer < Struct.new(:brand)
      def drink
        puts "Pssssst! Gulp, gulp, gulp... aaaah!"
      end
    end
    
    class BeerDrinkingService
      def initialize(beer_brand)
        @client = Client.new
        @beer_brand = beer_brand
      end
      
      def call
        @client.drink_a_beer(beer_brand)
      end
    end

Going further, now we may want to know how drunk the guy is. Maybe we
don't want to sell him a beer when he looks like sack of potatoes.
Scenarios, scenarios, scenarios:

    #!gherkin
    Feature: Drining beer
    
      Scenario: Drink a favorite beer
        When I pick my favorite "Belfast" beer
        Then I want to drink the beer I choose

      Scenario: Getting waisted
        When I drink favorite "Belfast" beer until I get look like sack of potaoes
        Then I should not get another beer
        
Tests, tests, tests!

    #!ruby
    Then /I want drink favorite "(.*)" beer until I get look like sack of potaoes/ do |beer_brand|
      @beer_brand = beer_brand
      10.times do
        step(%(I pick my favorite "#{@beer_brand}" beer))
        step(%(I want to drink the beer I choose))
      end
    end
    
    Then /I should not get another beer/ do
      step(%(I pick my favorite "#{@beer_brand}" beer))
      @drinking.call.should == false
    end

And the code is growing:

    #!ruby
    class Client < Struct.new(:drunkeness)
      def drink_a_beer(brand)
        self.drunkenness += 1
        Beer.new(brand).drink
      end
      
      def drunkeness
        @drunkeness ||= 0
      end
      
      def waisted?
        self.drunkenness > 6
      end
      
      def sack_of_potatoes?
        self.drunkenness > 9
      end
    end
    
    class BeerDrinkingService
      def initialize(client_id, beer_brand)
        @client = ClientsRepository.find_by_id_or_create(client_id)
        @beer_brand = beer_brand
      end
      
      def valid?
        !@client.sack_of_potatoes?
      end
      
      def call
        return false unless valid?
        @client.drink_a_beer(@beer_brand)
      end
    end

Two new things shown up around. First is validation, thus this is only 
a dummy example is enough to return false if someone can't drink the
beer. Otherwise we can consider returning some errors hash. In fact,
validations are very hard problem itself. There's holly war where 
validations should belong to? To model, like ActiveRecord does? But
this requires dealing with various contexts very often. To the service,
or form? Well, this may cause unncecessery repetitions, but we don't want
to repeat ourselves. Or maybe validators should be totally separated
objects, service-like callables for checking various requirements on
the passed objects? I personally think that what belongs to model,
should be there, what belongs to service/form should be there. No
mixing contexts, there's nothing worse than dealing with extra states.
I think validations itself are good topic for future blog post, 
stay tuned for it.

Second new thing is `ClientsRepository`, what's that? This is our
proxy to data storage. **Some, undefined data storage**. You shouldn't
imagine storage as a database. Storage is just a detail. It may be
simple Ruby hash. Speaking shortly, **It doesn't mather at all**. 
Here's how our clients repository may look like:

    #!ruby
    class ClientsMockRepository
      DB = {}

      def self.auto_increment
        @auto_increment ||= 0
        @auto_increment += 1
      end
      
      def self.find_by_id(client_id)
        DB[client_id]
      end
      
      def self.create
        DB[auto_increment] = Client.new
      end
      
      def self.find_by_id_or_create(client_id)
        find_by_id(client_id) or create
      end
    end
    
    class ClientsRepository < ClientsMockRepository
    end
    
Now I can hear bunch of people saying, _Ohh, but how I can retrieve list
of all the clients_? Let me answer you with a question... Does your domain
model require that feature? 

Second thing, you see that `ClientsRepository` inherits from mock repository
implementation. That's how it works, repository is just a plugin, when
you decide that you need to have your data persisted, you can just switch
it to MySQL, Redis or whatever you like other driver. You can use global
variable as well, use whatever it's cleaner for you:

    #!ruby
    $clients_repository = ClientsMockRepository

We can go further and further, checking if beer is available, charging
the client for his drink, etc. etc. You can play with it at your home - 
yeah, treat it as a homework - you will see by yourself how easy is
to implement new features, changing existing ones and move project forward
when you simply don't care about the details - storage, delivery method,
views, etc.

Oh, let me tell ya, **the tests are blazingly fast** no matter if you're 
using RSpec, Cucumber or God knows what other invent. But, what's way 
more important for your clients, it tests what they actually do want to
test. It doesn't test GUI or other shit which **doesn't matter** at the
moment.

As I said, after a while, when you may need a database, you can simply 
write a driver for it, a plugin, because **database is nothing more 
than a plugin**... The same happens with visual representation, we can 
wrap our interaction around with some boundries, write some presenter 
for it, write bunch of Rails spaghetti. We can expose it as a webservice
and present using only JavaScript. There's no limits, can you see it now? 
**You should always keep as much doors open as possible. Good architectural 
decisions allows you to keep that doors open**, use it wisely.

### Optimize... pivot?

Well, that's all for today. Some of you guys may consider this article
as a pivot against your mindset, for some it may be just optimization,
for many others it may be total bullshit. I will be happy to meet
all of you and listen to your constructive feedback. Maybe your
feedback will cause pivot in my mindset? For sure it's gonna optimize
it!

At the end, I would like to also thank Cubox for how they helped me to
change my mindset during last year. Thanks to [apotonick](http://twitter.com/apotonick)
again! Big thanks to [Jim Gay](https://twitter.com/#!/saturnflyer) for 
great talk at wroc_love.rb about DCI - thus I don't agree with all the 
presented ideas it helped me a lot to clarify mines :P. Also, thanks
to [Tim Lossen](https://twitter.com/#!/tlossen) for raising the glove
in the battle between monolythic apps versus web-services I go for,
which caused me to dig deeper and deeper about this. I can't wait to see 
your talk at EuRuKo! And of course thanks to [rabble](http://anarchogeek.com)
for infecting me with Lean Startup stuff and making me understand it 
in practice.
