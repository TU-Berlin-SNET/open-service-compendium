FROM dockerfile/ubuntu

# Install Ruby 2.1 using rvm and install gems of broker
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3 &&\
    curl -sSL https://get.rvm.io | bash -s stable --ruby=2.1 &&\
    /bin/bash -c "source /usr/local/rvm/scripts/rvm && gem install passenger"

# Copy Proxy files
ADD . /root/tresor-broker
WORKDIR /root/tresor-broker

# Install gems of broker and make docker-broker.sh executable
RUN /bin/bash -c "source /usr/local/rvm/scripts/rvm && bundle install && rake assets:precompile"

# Run the Broker
CMD ["/bin/bash", "-c", "source /usr/local/rvm/scripts/rvm && RAILS_ENV=production passenger start"]