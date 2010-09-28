require 'camping'
require 'active_record'
require 'action_view'
Camping.goes :Nano
#require 'rubygems'
#gem 'actionpack'
include ActionView::Helpers::DateHelper

dbconfig = YAML.load(File.read('config/database.yml'))
#ActiveRecord::Base.establish_connection dbconfig['production']

# decide if we are running on Heroku based on the presence of their DB environment variable and use the appropriate DB
environment = ENV['DATABASE_URL'] ? 'production' : 'development'

# attach to the DB and run the create method for the Blog app
Nano::Models::Base.establish_connection dbconfig[environment]
Nano.create if Nano.respond_to? :create

module Nano::Models
  class Post < Base
  end
	
  class BasicFields < V 1.0
    def self.up
      create_table Post.table_name do |t|
        t.string :author
        t.text   :content
        # This gives us created_at and updated_at
        t.timestamps
      end
    end

    def self.down
      drop_table Post.table_name
    end

  end
  
end

def Nano.create
  Nano::Models.create_schema
end

module Nano::Controllers
  class Index
    def get
	  if @input.author and @input.author.strip.length > 0
		redirect AuthorX, @input.author
	  end
      @posts = Post.all(:order=>"created_at DESC",:limit=>30)	
	  @ttl = "Nanoblogger"
      render :home
    end
  end

  class AuthorX
    def get(author)
      @posts = Post.find_all_by_author(author,:order=>"created_at DESC")
	  @author = author
	  @ttl = "%s on Nanoblogger" % author
      render :singleAuthor
    end
	  
	  def post(author)
	    if @input.content.strip.length > 0
			@post = Post.create(:author=>author,:content=>@input.content,:created_at=>Time.now)
		end
		redirect AuthorX, author
	  end
  end
	
  class AuthorXNew
    def get(author)
      @author = author
	  @ttl = "%s on Nanoblogger" % author
      render :edit
    end
  end
  
  class Style < R '/styles.css'
	  def get
	   @headers["Content-Type"] = "text/css"
	   @body = %{
			.author {font-weight: bold; margin: 0.5em}
			.timestamp {font-style: italic; margin: 0.5em}
			li:nth-child(even){background-color:white}
			li:nth-child(odd){background-color:\#eee}
	   }
	  end
   end

end

module Nano::Views
  def layout
    html do
      head do
        title ttl
		link :rel => 'stylesheet',:type => 'text/css',:href => '/styles.css'
      end
      body { self << yield }
    end
	p do
		a "home", :href => R(Index)
	end
  end

  def home
    h1 "Recent updates"
    ul do
      @posts.each do |post|
        li do
			span.author do
				a post.author, :href => R(AuthorX, post.author)
			end
			span.content post.content
			span.timestamp "%s ago" % ActionView::Helpers::DateHelper.time_ago_in_words(post.created_at)
        end
      end
    end
    form :action => R(Index), :method => :get do
	  input :type => :submit, :value => "new user"
      input "", :type=>"text",:name => :author
    end
  end

  def singleAuthor
    h1 author
    ul do
      @posts.each do |post|
        li do
			  span.content post.content
			  span.timestamp "%s ago" % ActionView::Helpers::DateHelper.time_ago_in_words(post.created_at)
		  end
      end
    end
	  p do
		a "new post", :href => R(AuthorXNew, author)
	  end
  end
	
  def edit
    h1 "#{@author} writes:"
    form :action => R(AuthorX, @author), :method => :post do
      textarea "", :name => :content, :rows => 10, :cols => 50
      br
      input :type => :submit, :value => "blog!"
    end
  end
end

