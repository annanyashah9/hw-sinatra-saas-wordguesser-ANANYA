# app.rb
require 'sinatra/base'
require 'sinatra/flash'
require_relative 'lib/wordguesser_game'

class WordGuesserApp < Sinatra::Base
  enable :sessions
  register Sinatra::Flash
  set :host_authorization, { permitted_hosts: [] }

  # SHOW the "Start New Game" button (browser does GET /new)
  get '/new' do
    erb :new
  end

  # CREATE a new game (form on /new will POST here)
  post '/create' do
    word = WordGuesserGame.get_random_word
    session[:game] = WordGuesserGame.new(word)
    redirect '/show'
  end

  get '/show' do
    @game = session[:game] or redirect '/new'
    case @game.check_win_or_lose
    when :win  then redirect '/win'
    when :lose then redirect '/lose'
    else            erb :show
    end
  end

  post '/guess' do
    @game = session[:game] or redirect '/new'
    letter = (params[:guess].to_s)[0].to_s
    flash[:message] = 'Please enter a letter.' if letter.empty?
    @game.guess(letter) unless letter.empty?
    redirect '/show'
  end

  get '/win' do
    @game = session[:game] or redirect '/new'
    redirect '/show' unless @game.check_win_or_lose == :win
    erb :win
  end

  get '/lose' do
    @game = session[:game] or redirect '/new'
    redirect '/show' unless @game.check_win_or_lose == :lose
    erb :lose
  end
end
