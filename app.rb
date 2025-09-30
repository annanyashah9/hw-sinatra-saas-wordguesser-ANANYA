require 'sinatra/base'
require 'sinatra/flash'
require_relative 'lib/wordguesser_game'

class WordGuesserApp < Sinatra::Base
  enable :sessions
  register Sinatra::Flash

  set :host_authorization, { permitted_hosts: [] }  

  before do
    @game = session[:game] || WordGuesserGame.new('')
  end

  after do
    session[:game] = @game
  end

  # These two routes are good examples of Sinatra syntax
  # to help you with the rest of the assignment
  get '/' do
    redirect '/new'
  end

  get '/new' do
    erb :new
  end

  post '/create' do
    word = WordGuesserGame.get_random_word
    session[:game] = WordGuesserGame.new(word)
    redirect '/show'
  end
  

  # Use existing methods in WordGuesserGame to process a guess.
  # If a guess is repeated, set flash[:message] to "You have already used that letter."
  # If a guess is invalid, set flash[:message] to "Invalid guess."
  post '/guess' do
    @game = session[:game] or redirect '/new'
    # Safely take only the first character the user typed
    letter = (params[:guess].to_s)[0].to_s
  
    if letter.empty? || letter !~ /[A-Za-z]/
      flash[:message] = 'Invalid guess.'
    else
      ch = letter.downcase
      if @game.guesses.include?(ch) || @game.wrong_guesses.include?(ch)
        flash[:message] = 'You have already used that letter.'
      else
        @game.guess(ch)  # updates guesses / wrong_guesses
      end
    end
    redirect '/show'
  end
  

  # Everytime a guess is made, we should eventually end up at this route.
  # Use existing methods in WordGuesserGame to check if player has
  # won, lost, or neither, and take the appropriate action.
  # Notice that the show.erb template expects to use the instance variables
  # wrong_guesses and word_with_guesses from @game.
  get '/show' do
    @game = session[:game] or redirect '/new'
    case @game.check_win_or_lose
    when :win  then redirect '/win'
    when :lose then redirect '/lose'
    else            erb :show
    end
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
