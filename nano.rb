#!/usr/bin/ruby
require 'camping'
require 'active_record'
require 'action_view'
require 'pusher'
include ActionView::Helpers::DateHelper
Camping.goes :Nano

Pusher.app_id = '3664'
Pusher.key    = '3e0eaf103f5b0f5ef114'
Pusher.secret = '317b66dc033fec42247e'

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
    
    def post
      if @input.content.strip.length > 0
        @post = Post.new(:author=>@input.author.strip,:content=>@input.content.strip)
        if @post.save
            Pusher['posts'].trigger('post-create', @post.attributes)
        end
      end
      redirect Index
    end

  end

  class AuthorX
    def get(author)
      @posts = Post.find_all_by_author(author,:order=>"created_at DESC")
      @author = author
      @ttl = "%s on Nanoblogger" % author
      render :singleAuthor
    end
    
  end
  
  class New
    def get
      @ttl = "Nanoblogger"
      render :new
    end
  end
  
  class NewX
    def get(author)
      @ttl = "Nanoblogger"
      @author = author
      render :new
    end
  end
  
  class Js < R '/nano.js'
    def get
        @headers['Content-Type'] = 'text/javascript'
        File.read('nano.js')
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
        script "", :type => 'text/javascript', :src => 'https://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js'
        script "", :type => 'text/javascript', :src => 'http://js.pusherapp.com/1.6/pusher.min.js'
      end
      body { self << yield }
    end
  p do
    a "home", :href => R(Index)
  end
  end

  def home
    script "", :type => 'text/javascript', :src => '/nano.js'
    h1 "Recent updates"
    ul.posts! do
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
    h2 "New post"
    form.new! :action => R(Index), :method => :post do
      p "your name:"
      input "", :type => "text", :name => :author
      p "your message:"
      textarea "", :name => :content, :rows => 10, :cols => 50
      br
      input :type => :submit, :value => "post!"
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
      a "new post", :href => R(NewX, author)
    end
  end
  
  def new
    h2 "New post"
    form :action => R(Index), :method => :post do
      p "your name:"
      input "", :type => "text", :name => :author, :value => @author
      p "your message:"
      textarea "", :name => :content, :rows => 10, :cols => 50
      br
      input :type => :submit, :value => "post!"
    end
  end
end
