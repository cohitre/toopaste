#!/usr/local/bin/ruby -rubygems

require 'sinatra'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'syntax/convertors/html'

require 'haml'
require 'sass'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/toopaste.sqlite3")

set :haml, {:format => :html5}

class Snippet
  include DataMapper::Resource

  property :id,         Serial # primary serial key
  property :title,      String, :required => true, :length => 32
  property :body,       Text,   :required => true
  property :created_at, DateTime
  property :updated_at, DateTime

  def format_body(language)
    convertor = Syntax::Convertors::HTML.for_syntax "ruby"
    "<div class=\"syntax syntax_ruby\">#{convertor.convert(self.body)}</div>"
  end
end

DataMapper.auto_upgrade!

get '/application.css' do
  headers 'Content-Type' => 'text/css'
  sass :application
end

# new
get '/' do
  haml :new
end

# create
post '/' do
  @snippet = Snippet.new(:title => params[:snippet_title],
  :body  => params[:snippet_body])
  if @snippet.save
    redirect "/#{@snippet.id}"
  else
    redirect '/'
  end
end

# show
get '/:id' do
  @snippet = Snippet.get(params[:id])
  if @snippet
    haml :show
  else
    redirect '/'
  end
end
