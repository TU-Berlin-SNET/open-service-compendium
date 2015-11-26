Open Service Compendium
=======================

Installation
============

Prerequisites
-------------

The Open Service Compendium requires the following components:

* Ruby >=2.1
* NodeJS >= 0.12
* MongoDB >= 3.0
* Grunt >= 0.4
* Bower >= 1.4.1
* Bundler >= 1.10

It should run under Windows, Linux and on a Mac.

Installation procedure
----------------------

After installing the required components, check out the source:

`git clone https://github.com/TU-Berlin-SNET/open-service-compendium --recursive`

You then have to install required Ruby Gems, Node modules, and bower components:

* `bundle install` installs all required Ruby Gems
* `npm install` installs all required Node modules into `node_modules`
* `bower install` installs all bower components (frontend assets) into `vendor/bower_components`
* `grunt watch-dev` builds the frontend assets into `assets/scripts`

DB Setup
--------

The rake task `tresor:reset_and_load_examples` resets the DB and loads the examples from the bundled SDL-NG. To run OSC, `bundle exec rake tresor:reset_and_load_examples`. This creates the database if it does not exist. 

More
====

More documentation will follow.

License
=======

Licensed under the [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).
