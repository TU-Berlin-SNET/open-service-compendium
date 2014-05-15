TRESOR Open Service Broker
==========================

Requirements
------------

* Ruby 2.1
* A recent version of MongoDB

Development environment
-----------------------

The broker was developed using Ubuntu 12.04.4 LTS with Ruby 2.1 installed using [RVM](http://rvm.io/) and the [official MongoDB packages](http://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/).

DB Setup
--------

The rake task `tresor:reset_and_load_examples` resets the DB and loads the examples from the bundled SDL-NG.

More
====

More documentation will follow.

License
=======

Licensed under the [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).
