namespace :db do
  USER = "rails"

  DATABASES = %W[
    active_record_handler_socket
    active_record_handler_socket_test
  ]

  TABLES = {
    :people  => %W[
      id     int(11)      NOT NULL AUTO_INCREMENT,
      name   varchar(255) DEFAULT '',
      age    int(11)      DEFAULT NULL,
      status tinyint(1)   NOT NULL DEFAULT '1',
      PRIMARY KEY (id)
    ].join(" "),
    :hobbies => %W[
      id         int(11)          NOT NULL AUTO_INCREMENT,
      person_id  int(11)          NOT NULL,
      title      varchar(255)     DEFAULT '',
      created_at datetime DEFAULT NULL,
      updated_at datetime DEFAULT NULL,
      PRIMARY KEY (id)
    ].join(" ")
  }

  INDEXES = {
    :people => {
      :index_people_on_age_and_status => %W[age status]
    },
    :hobbies => {
      :index_hobbies_on_person_id => %W[person_id]
    }
  }

  def mysql(query, options = {})
    _user = options[:user] || USER
    _db   = options[:database]

    puts ""

    begin
      sh %Q|mysql -u #{_user} #{_db} -e "#{query}"|
    rescue => e
      puts e.message
    end
  end

  desc "create user for active_record_handler_socket"
  task :create_user do
    mysql "GRANT ALL PRIVILEGES ON *.* TO '#{USER}'@'localhost' WITH GRANT OPTION", :user => "root"
    mysql "SHOW GRANTS FOR 'rails'@'localhost'", :user => "root"
  end

  desc "create databases for active_record_handler_socket"
  task :create_databases do
    DATABASES.each do |database|
      mysql "CREATE DATABASE #{database} DEFAULT CHARACTER SET 'utf8'"
    end

    mysql "SHOW DATABASES"
  end

  desc "create tables for active_record_handler_socket"
  task :create_tables do
    DATABASES.each do |database|
      TABLES.each do |table, schema|
        mysql "CREATE TABLE #{table} (#{schema}) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8", :database => database
      end

      mysql "SHOW TABLES", :database => database
    end
  end

  desc "create indexes for active_record_handler_socket"
  task :create_indexes do
    DATABASES.each do |database|
      INDEXES.each do |table, indexes|
        indexes.each do |index_name, columns|
          mysql "CREATE INDEX #{index_name} USING btree ON #{table} (#{columns.join(",")})", :database => database
        end

        mysql "SHOW INDEXES FROM #{table}", :database => database
      end
    end
  end

  desc "run db tasks}"
  task :prepare do
    %W[
      db:create_user
      db:create_databases
      db:create_tables
      db:create_indexes
    ].each do |task|
      Rake::Task[task].invoke
    end
  end
end