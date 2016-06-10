FROM ubuntu:latest

# Install Ruby 2.3 using rvm, install passenger, install nodejs and npm
RUN apt-get update &&\
    apt-get install -y --no-install-recommends curl ca-certificates git &&\
    gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3 &&\
    curl -sSL https://get.rvm.io | bash -s stable --ruby=2.3 --gems=bundler,passenger &&\
    /bin/bash -c "source /usr/local/rvm/scripts/rvm && gem update --system" &&\ 
    curl -sL https://deb.nodesource.com/setup_4.x | bash - &&\
    apt-get install -y --no-install-recommends nodejs &&\
    npm install -g npm

# Copy bundler files
COPY Gemfile* /root/osc/
COPY lib/sdl-ng/sdl-ng.gemspec lib/sdl-ng/Gemfile* /root/osc/lib/sdl-ng/
COPY lib/sdl-ng/lib/sdl/version.rb /root/osc/lib/sdl-ng/lib/sdl/version.rb

# Work in osc
WORKDIR /root/osc

# Install gems of osc
RUN /bin/bash -c "source /usr/local/rvm/scripts/rvm && bundle update && bundle install"

# Copy npm and bower files
COPY package.json bower.json .bowerrc /root/osc/

# Install npm modules, bower, and bower modules
RUN npm install -g grunt-cli@^0.1.13 &&\
    npm install &&\
    npm install -g bower grunt-cli &&\
    bower install --allow-root --config.interactive=false

# Copy OSC source
COPY . /root/osc/

# Create OSC assets
RUN grunt --force

# Run the OSC
CMD ["/bin/bash", "-c", "source /usr/local/rvm/scripts/rvm && RAILS_ENV=production passenger start"]
