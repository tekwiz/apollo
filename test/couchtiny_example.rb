require File.join(File.dirname(__FILE__), 'test_helper')
require 'couchtiny'
require 'couchtiny/document'
require 'apollo'

class User < CouchTiny::Document
  include Apollo
  apollo do
    state :submitted do
      event :activate_via_link, :to => :proved_email
    end
    state :proved_email
  end

  def load_apollo_state
    self[:apollo_state]
  end

  def persist_apollo_state(new_value)
    self[:apollo_state] = new_value
    save!
  end
end


class CouchtinyExample < Test::Unit::TestCase

  def setup
    db = CouchTiny::Database.url("http://127.0.0.1:5984/test-apollo")
    db.delete_database! rescue nil
    db.create_database!
    User.use_database db
  end

  test 'CouchDB persistence' do
    user = User.new :email => 'manya@example.com'
    user.save!
    assert user.submitted?
    user.activate_via_link!
    assert user.proved_email?

    reloaded_user = User.get user.id
    puts reloaded_user.inspect
    assert reloaded_user.proved_email?, 'Reloaded user should have the desired apollo state'
  end
end
