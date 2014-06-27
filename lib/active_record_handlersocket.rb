require 'active_record'
require 'handlersocket'

%W[
  manager
  finder 
  writer
  connection
  active_record_handler_socket
  base
].each do |file|
  require File.join("active_record_handlersocket", file)
end

