ruby-hStore
------------

The following project is an implementation of the [hData Network Transport](http://www.projecthdata.org/documents.html) using [Sinatra](http://www.sinatrarb.com/) and [Mongoid](http://mongoid.org).

Setup and Running
-----------------

This project uses [Bundler](http://gembundler.com/) to manage its dependencies. To setup run:

    sudo gem install bundler

Then you can grab the necessary gems to run the project by:

    bundle install

The project uses [MongoDB](http://www.mongodb.org) to store data. The application assumes that mongo is running on localhost on the default port. This can be changed in the config.ru file.

Finally you can run the application with:

    rackup config.ru

The application will run on http://localhost:4567. You need to do a POST to /records to create a new record to work with. It should respond with a status code of 201 stating the the record was created and a pointer to the location of the new record to work with. For working with the hData Network Transport, I would recommend using the [Poster Firefox Add-on](https://addons.mozilla.org/en-US/firefox/addon/2691).

Testing
-------

Just run:

    rake test

To Do
-----
1. Implement metadata POSTing

License
-------

Copyright 2010 The MITRE Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.