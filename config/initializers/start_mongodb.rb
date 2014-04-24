require 'rbconfig'

unless  Rails.env.production? || (RbConfig::CONFIG['host_os'] !~ /mswin|mingw|cygwin/) || File.exists?('db/mongod.lock')
  spawn "mongostart.cmd"
end