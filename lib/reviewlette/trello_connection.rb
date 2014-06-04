require 'yaml'
require 'debugger'

class Trello::Card

  def assignees
    member_ids.map{|id| find_member_by_id(id)}
  end

end

module Reviewlette

  class TrelloConnection

    TRELLO_CONFIG = YAML.load_file('/home/jschmid/reviewlette/config/.trello.yml')
    attr_accessor :board

    def initialize
      setup_trello
      # build_team
    end

    def find_card(trelloid)
      re1='.*?'
      re2='\\d+'
      re3='.*?'
      re4='(\\d+)'
      re=(re1+re2+re3+re4)
      m=Regexp.new(re,Regexp::IGNORECASE)
      if m.match(trelloid)
        id=m.match(trelloid)[1]
        puts "found card nr: #{id}"
        find_card_by_id(id)
      else
        nil
      end
    end

    def determine_reviewer(card)
      (team - card.assignees).sample
    end

    def add_reviewer_to_card(reviewer) # parameter can be determine_reviewer?
      if reviewer
        card.add_member(reviewer)
        card.add_comment("#{reviewer.username} will review it")
        puts "added #{reviewer} to the card"
        true
      else
        puts "No available reviewer found"
      end
      false
    end

    def team
      @team ||= TRELLO_CONFIG['member'].map{|name| find_member_by_username(name) }
    end

    private

    def find_member_by_username(username)
      @board.members.find{|m| m.username == username}
    end

    def find_member_by_id(id)
      @board.members.find{|m| m.id == id}
    end

    def find_card_by_id(id)
      @board.cards.find{|c| c.short_id == id.to_i}
    end

    def setup_trello
      Trello.configure do |config|
        config.developer_public_key = TRELLO_CONFIG['consumerkey']
        config.member_token = TRELLO_CONFIG['oauthtoken']
      end
      @board = Trello::Board.find(TRELLO_CONFIG['board_id'])
    end
  end
end