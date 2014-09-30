Card = Struct.new(:number, :suite, :color)

class Player
  attr_accessor :playercards #wrapped in accessor so can be elaborated upon in method later if one is needed
  attr_reader :name
  attr_accessor :score
  attr_accessor :busted
  
  def initialize (name)
  	@name = name
  	@acecount = 0
    @busted = false
    @playercards = Array.new()
  end

  def hand (newcards=nil)
  	@playercards << newcards if newcards != nil
    return @playercards
  end

end

class Session
  attr_reader :deck
  attr_reader :PlayersInTheGame
  attr_reader :playing
  attr_reader :split
 
  def initialize()
    @playing = true
    @PlayersInTheGame = Hash.new{}
    @PlayersInTheGame["Dealer"] = Player.new("Dealer") 
    $cardvalue = {:two => 2, :three => 3, :four => 4, :five => 5, :six => 6, :seven => 7, :eight => 8, :nine => 9, :ten => 10, :jack => 10, :queen => 10, :king => 10, :ace => 1}
    @split = false
    @deck = generatedeck()
    puts "Welcome to Blackjack!"
    puts "What might your name be?" if $playername == nil
    $playername = gets.chomp if $playername == nil
    @PlayersInTheGame["Player"] = Player.new($playername)
    dealersetup()
  end

  def checkbust(player)
    if score(player) > 21
      puts player.name + " has busted!"
      player.busted = true
      return true
    else return false
    end
  end

  def dealerAI()
    while score(@PlayersInTheGame["Dealer"]) < 15
      puts "The dealer wants to hit. Press Enter to continue"
      blank = gets.chomp
      @PlayersInTheGame["Dealer"].hand(@deck.pop)
      displayboard()
    end
      puts "The dealer stands.\n\n"

  end


  def generatedeck()
    newdeck = Array.new()
      $cardvalue.each do |key, value|
        newdeck << Card.new(key, "Diamonds", "Red")
        newdeck << Card.new(key, "Hearts", "Red")
        newdeck << Card.new(key, "Clubs", "Black")
        newdeck << Card.new(key, "Spades", "Black")
    end
    newdeck.shuffle!
  end

  def dealersetup()
    hit("Dealer")
    hit("Player")
    hit("Player")
    @split = true if @PlayersInTheGame["Player"].hand[0].number == @PlayersInTheGame["Player"].hand[1].number
    displayboard()
  end

  def displayboard()
    @PlayersInTheGame.each do |key, value|
      puts value.name.to_s + " has the following cards:"
      value.hand.each { |card| print "*****   "}
      print "\n" 
      value.hand.each do |card| 
        if card.number == :ten
          print "*#{$cardvalue[card.number].to_s} *   "
        elsif card.number != :ace &&  card.number != :jack && card.number != :queen &&  card.number != :king
          print "* #{$cardvalue[card.number].to_s} *   "
        else
          print "* #{card.number.to_s[0].capitalize} *   "
        end
      end
      print "\n"
      value.hand.each { |card| print "* #{card.suite[0]} *   "}
      print "\n"
      value.hand.each { |card| print "*****   "}
      print "\n\n"
    end
  end

  def finalscoring()
    @dscore = @PlayersInTheGame["Dealer"].score
    if @split
      @pscore = [@PlayersInTheGame[1].score, @PlayersInTheGame[2].score].max
    else
      @pscore = @PlayersInTheGame["Player"].score
    end

    if @dscore > @pscore
      return "The Dealer has won with #{@dscore}!"
    elsif @dscore < @pscore
      $wincount = $wincount + 1
      return "#{$playername} has won with #{@pscore}!"
    else
      return "It's a tie! #{@dscore} points each."
    end
  end

  def hit(who)
    @PlayersInTheGame[who].hand(@deck.pop)
  end


  def playerloop()
    puts "What would you like to do? You may HIT, STAND, or QUIT"
    puts "And this game, you may SPLIT as well!" if @split==true
    @playeroption = gets.chomp.downcase
    case @playeroption
      when "hit"
        @split = false
        hit("Player")
        displayboard()
        @playing = false if checkbust(@PlayersInTheGame["Player"])
      when "stand"
        @split = false
        puts "You have scored " + score(@PlayersInTheGame["Player"]).to_s
        puts "Now let's see what the dealer does..."
        dealerAI()
        endgame()
      when "split"
        specialsplitmoves() if @split == true
        dealerAI() if @playing
        endgame()  if @playing
      when "quit"
        @split = false
        @playing = false
      else
        puts "Come again?"
    end

   
  end

  def specialsplitmoves()
    @PlayersInTheGame[1] = Player.new($playername)
    @PlayersInTheGame[1].hand(@PlayersInTheGame["Player"].hand[0])
    @PlayersInTheGame[2] = Player.new($playername)
    @PlayersInTheGame[2].hand(@PlayersInTheGame["Player"].hand[1])
    @PlayersInTheGame.delete("Player")
    for i in 1..2
      puts "Okay sure. Let's take care of split hand ##{(i).to_s}."
      @stillgoing = true
      while @stillgoing == true
        puts "Alrighty, HIT or STAND?"
        @splitoption = gets.chomp.downcase
        case @splitoption
          when "hit"
            hit(i)
            displayboard()
            if checkbust(@PlayersInTheGame[i])== true
              puts "Aw man, you busted!"
              @stillgoing = false
            end
          when "stand"
            @stillgoing = false
        end
      end
    end
    puts "And we're done with both hands!"
    displayboard()
    if @PlayersInTheGame[1].busted && @PlayersInTheGame[2].busted
      puts "Dang, double busts! You're out!"
      @playing = false
    end
  end


  def endgame()
    if checkbust(@PlayersInTheGame["Dealer"]) == true
      puts "You win!"
      $wincount = $wincount + 1
    else
      puts "The Dealer has scored " + score(@PlayersInTheGame["Dealer"]).to_s
      puts finalscoring()
    end
    @playing = false
  end

  def score(currentplayer)
    if currentplayer.busted
      currentplayer.score = 0 
    else
      @score = 0
      @acecount = 0
      currentplayer.playercards.each do |card|
        @score = @score + $cardvalue[card.number]
      end
      currentplayer.playercards.each do |card|
        @acecount = @acecount + 1 if card.number == :ace
      end
      while @score < 12 && @acecount != 0# at this point no longer helpful to convert the ace
        @score = @score + 10
        @acecount = @acecount - 1
      end
      currentplayer.score = @score
    end
  end
end

Sessions = Hash.new()
$wincount = 0
for i in 1..1000                       # this all seems cumbersome/not idiomatic.
  Sessions[i] = Session.new()
  while Sessions[i].playing == true
    Sessions[i].playerloop()
  end
  puts "\nYou have now won #{$wincount} of #{i} games. Ready for another? Y for yes"
  break if gets.chomp.downcase != "y"
end