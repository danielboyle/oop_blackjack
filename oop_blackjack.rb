class Card
  attr_reader :face_value, :suit

  def initialize(face_value, suit)
    @face_value = face_value
    @suit = suit
  end

  def display_card
    "#{find_face_value} of #{find_suit}"
  end

  def to_s
    display_card
  end

  def find_suit
    case suit
      when 'H' then 'Hearts'
      when 'D' then 'Diamonds'
      when 'S' then 'Spades'
      when 'C' then 'Clubs'
    end
  end

  def find_face_value
    case face_value
      when 'J' then 'Jack'
      when 'Q' then 'Queen'
      when 'K' then 'King'
      when 'A' then 'Ace'
      else face_value
    end
  end
end

class Deck
  attr_accessor :cards

  FACE_VALUES = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  SUITS = ['H', 'D', 'S', 'C']

  def initialize
    @cards = []
    FACE_VALUES.each do |face_value|
      SUITS.each do |suit|
        @cards << Card.new(face_value, suit)
      end
    end
    shuffle_deck!
  end

  def shuffle_deck!
    cards.shuffle!
  end

  def deal_one
    cards.pop
  end

  def size
    cards.size
  end
end

module Hand
  def show_hand
    puts "----- #{name} -----"
    cards.each do |card|
      puts "=> #{card}"
    end
    puts "=> Total: #{total}"
  end

  def total
    face_values = cards.map { |card| card.face_value }

    total = 0
    face_values.each do |value|
      if value == 'A'
        total += 11
      else
        total += (value.to_i == 0 ? 10 : value.to_i)
      end
    end

    face_values.select { |value| value == 'A' }.count.times do
      break if total <= Blackjack::BLACKJACK_AMOUNT
      total -= 10
    end

    total
  end

  def add_card(new_card)
    cards << new_card
  end

  def is_busted?
    total > Blackjack::BLACKJACK_AMOUNT
  end

  def has_blackjack?
    total == Blackjack::BLACKJACK_AMOUNT
  end
end

class Player
  include Hand

  attr_accessor :name, :cards

  def initialize
    @name 
    @cards = []
  end

  def get_name
    begin
      puts "Please enter your name."
      @name = gets.chomp
    end until !@name.empty?
  end

  def print_result_message(message)
    puts "#{name} #{message}"
  end
end

class Dealer
  include Hand

  attr_accessor :name, :cards

  def initialize
    @name = "Dealer"
    @cards = []
  end

  def show_one_dealer
    puts "----- Dealer -----"
    puts "Showing:"
    puts "=> #{cards.last}"
  end

  def flip_dealer_card
    puts "Dealer flips the #{cards.first}"
    puts
    show_hand
  end

  def print_result_message(message)
    puts "Dealer #{message}"
  end
end

class Blackjack
  attr_accessor :deck, :player, :dealer

  BLACKJACK_AMOUNT = 21
  DEALER_HIT_MIN = 17

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def delay
    sleep 2.5
  end

  def clear_screen
    delay
    system "clear"
  end

  def line_divider
    puts "------------------"
  end

  def set_player_name
    system "clear"
    if !player.name
      player.get_name
    end
  end

  def deal_cards
    player.add_card(deck.deal_one)
    dealer.add_card(deck.deal_one)
    player.add_card(deck.deal_one)
    dealer.add_card(deck.deal_one)
  end

  def show_initial_hands
    clear_screen
    puts "Dealing..."
    line_divider
    player.show_hand
    line_divider
    dealer.show_one_dealer
  end

  def blackjack_or_bust(player_or_dealer)
    if player_or_dealer.has_blackjack?
      player_or_dealer.print_result_message("hit Blackjack!")
    elsif player_or_dealer.is_busted?
      player_or_dealer.print_result_message("busted!")
    end
  end

  def player_busted?
    if player.is_busted? 
      player.print_result_message("loses!")
      play_again
    end
  end

  def player_choice
    puts "Would you like to hit of stay? (h/s)"
    answer = gets.chomp.downcase

    if !['h', 's'].include?(answer)
      puts "Error. Please enter valid response."
      player_choice
    end

    case answer
    when 'h'
      hit_card = deck.deal_one
      player.add_card(hit_card)
      puts "#{player.name} dealt the #{hit_card}"
      puts "#{player.name}'s total is now #{player.total}"
      blackjack_or_bust(player)
      player_busted?
      player_turn unless player.has_blackjack?
    when 's'
      puts "#{player.name} stays."
    end
  end

  def dealer_choice
    until dealer.total >= DEALER_HIT_MIN
      delay
      line_divider
      hit_card = deck.deal_one
      dealer.add_card(hit_card)
      puts "Dealer hits"
      puts "Dealer dealt the #{hit_card}"
      puts "Dealer's total is now #{dealer.total}"
      blackjack_or_bust(dealer)
    end 
    unless dealer.is_busted? || dealer.has_blackjack?
      puts "Dealer stays at #{dealer.total}"
    end
  end

  def player_turn
    line_divider
    puts "Player's Turn"
    blackjack_or_bust(player)
    player_busted?
    player_choice unless player.has_blackjack?
  end

  def dealer_turn
    clear_screen
    puts "Dealer's Turn"
    line_divider
    dealer.flip_dealer_card
    blackjack_or_bust(dealer)
    dealer_choice
  end

  def determine_winner   
    if player.total == dealer.total
      puts "It's a push."
    elsif player.total < dealer.total
      if dealer.is_busted?
        puts "#{player.name} wins!"
      else
        puts "#{player.name} lost." 
      end
    else
      puts "#{player.name} wins!" 
    end 
  end

  def end_round
    delay
    unless dealer.is_busted?
      line_divider
      puts "#{player.name}'s total is #{player.total}"
      puts "Dealer's total is #{dealer.total}"
    end
    line_divider
    determine_winner
  end

  def play_again
    line_divider
    puts "Would you like to play another round? (y/n)"
    answer = gets.chomp.downcase
    if answer == 'y'
      new_round
    elsif answer == 'n'
      clear_screen
      puts "Thanks for playing!"
      line_divider
      exit
    else
      puts "ERROR. Try again."
      play_again
    end
  end

  def new_round
    if deck.size < 15
      @deck = Deck.new
    end
    player.cards = []
    dealer.cards = []

    run
  end

  def run
    set_player_name
    deal_cards
    show_initial_hands
    player_turn
    dealer_turn
    end_round
    play_again
  end
end

Blackjack.new.run
