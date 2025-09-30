# lib/wordguesser_game.rb
class WordGuesserGame
  attr_accessor :word, :guesses, :wrong_guesses

  def initialize(word)
    @word = word.to_s.downcase
    @guesses = ""         # correct letters guessed (unique, lowercased)
    @wrong_guesses = ""   # wrong letters guessed (unique, lowercased)
  end

  # Process a single-letter guess.
  # Returns true if the guess is in the word, false otherwise.
  def guess(letter)
    raise ArgumentError if letter.nil? || letter == "" || letter !~ /[A-Za-z]/

    ch = letter.downcase

    # If already guessed (right or wrong), do nothing (controller will message)
    return false if @guesses.include?(ch) || @wrong_guesses.include?(ch)

    if @word.include?(ch)
      @guesses << ch
      true
    else
      @wrong_guesses << ch
      false
    end
  end

  # Reveal the word with dashes for unguessed letters
  def word_with_guesses
    @word.chars.map { |c| @guesses.include?(c) ? c : '-' }.join
  end

  # :win if fully guessed, :lose if too many wrong, else :play
  def check_win_or_lose
    return :win  if word_with_guesses == @word
    return :lose if @wrong_guesses.length >= 7
    :play
  end

  # Provided in the starter; keep as-is
  def self.get_random_word
    require 'uri'
    require 'net/http'
    uri = URI('http://randomword.saasbook.info/RandomWord')
    Net::HTTP.new('randomword.saasbook.info').start do |http|
      return http.post(uri, "").body
    end
  end
end
