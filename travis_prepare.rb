def execute(command)
  command = command + " 2>&1"
  STDOUT.puts [ "**", "Exec:", command ].join " "
  result = system command
  STDOUT.puts [ "**", "Result:", result ].join " "
end

def handlersocket_plugin_installed?
  `mysql -e "SHOW PLUGINS" | grep handlersocket | wc -l`.chomp.to_i > 0
end

def clone_handler_socket
  execute "git clone https://github.com/DeNA/HandlerSocket-Plugin-for-MySQL.git"
end

def prepare_mysql_source
  execute "cd #{handlersocket_plugin_dir}; wget #{mysql_download_url}"
  execute "cd #{handlersocket_plugin_dir}; tar xvf #{mysql_filename}"
end

def make_handler_socket
  execute "cd #{handlersocket_plugin_dir}; ./autogen.sh"
  execute "cd #{handlersocket_plugin_dir}; ./configure --with-mysql-source=#{mysql_source} --with-mysql-bindir=#{mysql_bin}"
  execute "cd #{handlersocket_plugin_dir}; make"
  execute "cd #{handlersocket_plugin_dir}; make install"
end

def handlersocket_plugin_dir
  "HandlerSocket-Plugin-for-MySQL"
end

def mysql_source
  dirname = File.basename mysql_filename, ".tar.gz"
  File.expand_path dirname
end

def mysql_download_url
  "http://downloads.mysql.com/archives/mysql-#{mysql_version.split(".")[0..1].join(".")}/#{mysql_filename}"
end

def mysql_filename
  "mysql-#{mysql_version}.tar.gz"
end

def mysql_version
  `mysql_config --version`.chomp
end

def mysql_bin
  File.dirname `which mysql`.chomp
end

if handlersocket_plugin_installed?
  STDOUT.puts "HandlerSocket-Plugin-for-MySQL already installed"
else
  clone_handler_socket
  prepare_mysql_source
  make_handler_socket
end
