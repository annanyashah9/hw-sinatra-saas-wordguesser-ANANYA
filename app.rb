# app.rb
# app.rb
require 'sinatra/base'
require 'sinatra/flash'
require_relative 'lib/wordguesser_game'

class WordGuesserApp < Sinatra::Base
  enable :sessions
  register Sinatra::Flash
  set :host_authorization, { permitted_hosts: [] }

  # Show "Start New Game" button
  get '/new' do
    erb :new
  end

  # Create a new game and go to /show
  post '/create' do
    word = WordGuesserGame.get_random_word.to_s
    word = 'wordguesser' if word.strip.empty? # safe fallback
    session[:game] = WordGuesserGame.new(word)
    redirect '/show'
  end

  # Main game screen (or redirect if finished)
  get '/show' do
    @game = session[:game] or redirect '/new'
    case @game.check_win_or_lose
    when :win  then redirect '/win'
    when :lose then redirect '/lose'
    else            erb :show
    end
  end

  # Handle a guess and return to /show
  post '/guess' do
    @game = session[:game] or redirect '/new'

    letter = (params[:guess].to_s)[0].to_s
    if letter.empty? || letter !~ /[A-Za-z]/
      flash[:message] = 'Invalid guess.'
    else
      ch = letter.downcase
      if @game.guesses.include?(ch) || @game.wrong_guesses.include?(ch)
        flash[:message] = 'You have already used that letter.'
      else
        @game.guess(ch)
      end
    end
    redirect '/show'
  end

  # Win page (guard against direct URL “cheating”)
  get '/win' do
    @game = session[:game] or redirect '/new'
    redirect '/show' unless @game.check_win_or_lose == :win
    erb :win
  end

  # Lose page (guard against direct URL “cheating”)
  get '/lose' do
    @game = session[:game] or redirect '/new'
    redirect '/show' unless @game.check_win_or_lose == :lose
    erb :lose
  end
end
           
