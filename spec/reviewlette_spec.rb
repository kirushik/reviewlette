require 'spec_helper'

describe Reviewlette do

  # set instance variable from local variable
  def instance_variable!(variable_name)
    Reviewlette.instance_variable_set("@#{variable_name}", send(variable_name.to_sym))
  end

  let(:number) { 23 }
  let(:title) { 'title' }
  let(:body) { 'body' }
  let(:githubname) { 'gitty' }
  let(:trelloname) { 'trello' }
  let(:board) { stub_boards_call }
  let(:repo) { 'repo/repo' }
  let(:id) { 23 }
  let(:card) { stub_card_call }
  let(:trello_connection) { double 'trello_connection' }
  let(:reviewer) {double 'reviewer'}
  let(:github_connection) { double 'github_connection' }
  let(:full_comment) { @full_comment = "@#{trelloname} will review https://github.com/#{repo}/issues/#{number.to_s}" }

  describe '.transform_name' do
    it 'transforms trelloname to github name' do
      Reviewlette.instance_variable_set("@trelloname", 'jschmid')
      Reviewlette.transform_name
      expect(Reviewlette.instance_variable_get("@githubname")).to be_a_kind_of String
      #good
    end
  end

  describe '.find_id' do
    it 'finds the id' do
      instance_variable! :id
      instance_variable! :trello_connection
      expect(trello_connection).to receive(:find_card_by_id).with(id).and_return card
      Reviewlette.find_id
    end

    it 'does not find the id' do
      Reviewlette.instance_variable_set("@id", nil)
      instance_variable! :trello_connection
      expect(Reviewlette.find_id).to be_nil
      Reviewlette.find_id
    end
  end

  describe '.set_reviewer' do
    it 'sets the reviewer' do
      instance_variable! :trello_connection
      instance_variable! :card
      expect(trello_connection).to receive(:determine_reviewer).with(card).and_return reviewer
      expect(reviewer).to receive(:username).and_return String
      Reviewlette.set_reviewer
    end
  end

  describe '.add_reviewer_on_github' do
    it 'adds the reviewer on github as assignee' do
      instance_variable! :github_connection
      instance_variable! :title
      instance_variable! :body
      instance_variable! :number
      instance_variable! :githubname
      expect(github_connection).to receive(:add_assignee).with(23, 'title', 'body', 'gitty').and_return true
      Reviewlette.add_reviewer_on_github
    end
  end

  describe '.comment_on_github' do
    it 'comments on the issue' do
      instance_variable! :card
      instance_variable! :number
      instance_variable! :githubname
      instance_variable! :github_connection
      expect(card).to receive(:url).and_return 'www.example.url'
      expect(github_connection).to receive(:comment_on_issue).with(23, 'gitty', 'www.example.url').and_return true
      Reviewlette.comment_on_github
    end
  end

  describe '.add_to_trello_card' do
    it 'adds a reviewer to the right trello card' do
      instance_variable! :trello_connection
      instance_variable! :reviewer
      instance_variable! :card
      expect(trello_connection).to receive(:add_reviewer_to_card).with(reviewer, card).and_return true
      Reviewlette.add_to_trello_card
    end

    it 'rescues with: already assigned' do
      # instance_variable! :trello_connection
      # Reviewlette.instance_variable_set("@reviewer", nil)
      # Reviewlette.instance_variable_set("@card", nil)
      # expect(trello_connection).to receive(:add_reviewer_to_card).with(nil, nil).to raise_error 'already assigned'
      # expect(Reviewlette.add_to_trello_card).to raise_error 'already '
      # Reviewlette.add_to_trello_card
      #EXCEPTOINHANDLING ??
      expect{raise 'already assigned'}.to raise_error 'already assigned'
    end
  end

  describe '.comment_on_trello' do
    it 'puts a comment on the trello card ' do
      instance_variable! :repo
      instance_variable! :trelloname
      instance_variable! :number
      instance_variable! :full_comment
      instance_variable! :card
      expect(full_comment).to eq '@trello will review https://github.com/repo/repo/issues/23'
    end
    it 'actually posts' do
      instance_variable! :trello_connection
      instance_variable! :full_comment
      instance_variable! :card
      expect(trello_connection).to receive(:comment_on_card).with(full_comment, card).and_return true
      Reviewlette.comment_on_trello
    end
  end

  describe '.move_to_list' do
    it 'moves the card to #Done list if the pull is merged' do
      instance_variable! :github_connection
      instance_variable! :trello_connection
      instance_variable! :card
      instance_variable! :repo
      instance_variable! :id
      # instance_variable! :column
      expect(trello_connection).to receive(:find_column).with('Done').and_return 'Done'
      expect(trello_connection).to receive(:move_card_to_list).with(card,'Done').and_return Object
      expect(github_connection).to receive(:pull_merged?).with(repo, id).and_return true
      Reviewlette.move_to_list
    end

    it 'moves the card to #in-Review list if the pull is not merged' do
      instance_variable! :github_connection
      instance_variable! :trello_connection
      instance_variable! :card
      instance_variable! :repo
      instance_variable! :id
      # instance_variable! :column
      expect(trello_connection).to receive(:find_column).with('In review').and_return 'In review'
      expect(trello_connection).to receive(:move_card_to_list).with(card,'In review').and_return Object
      expect(github_connection).to receive(:pull_merged?).with(repo, id).and_return false
      Reviewlette.move_to_list
    end
  end

  describe '.setup' do

    it 'sets up repo variable' do

    end
  end
end
