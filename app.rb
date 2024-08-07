require 'sinatra/base'
require 'sinatra/flash'
require './lib/wordguesser_game'

class WordGuesserApp < Sinatra::Base
  enable :sessions
  register Sinatra::Flash

  before do
    @game = session[:game]
  end

  after do
    session[:game] = @game
  end

  # Route to start a new game
  get '/' do
    redirect '/new'
  end

  get '/new' do
    erb :new
  end

  # Route to create a new game
  post '/create' do
    @game = WordGuesserGame.new(WordGuesserGame.get_random_word)
    redirect '/show'
  end

  # Route to show the game state
  get '/show' do
    case @game.check_win_or_lose
    when :win
      redirect '/win'
    when :lose
      redirect '/lose'
    else
      erb :show
    end
  end

  # Route to make a guess
  post '/guess' do
    letter = params[:guess].to_s[0]
    if letter.nil? || letter.empty? || !letter.match?(/[a-zA-Z]/)
      flash[:message] = "Invalid guess."
    else
      begin
        if !@game.guess(letter)
          flash[:message] = "You have already used that letter"
        end
      rescue ArgumentError => e
        flash[:message] = e.message
      end
    end
    redirect '/show'
  end

  # Route to display win page
  get '/win' do
    if @game.check_win_or_lose == :win
      erb :win
    else
      redirect '/show'
    end
  end

  # Route to display lose page
  get '/lose' do
    if @game.check_win_or_lose == :lose
      erb :lose
    else
      redirect '/show'
    end
  end

  run! if app_file == $0
end