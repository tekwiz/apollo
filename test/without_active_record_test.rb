require File.join(File.dirname(__FILE__), 'test_helper')
require 'apollo'

class WithoutApolloTest < Test::Unit::TestCase
  class Article
    include Apollo
    apollo do
      state :new do
        event :submit, :to => :awaiting_review
      end
      state :awaiting_review do
        event :review, :to => :being_reviewed
      end
      state :being_reviewed do
        event :accept, :to => :accepted
        event :reject, :to => :rejected
      end
      state :accepted
      state :rejected
    end
  end

  def test_readme_example_article
    article = Article.new
    assert article.new?
  end

  test 'better error message on to typo' do
    assert_raise Apollo::ApolloDefinitionError do
      Class.new do
        include Apollo
        apollo do
          state :new do
            event :event1, :transitionnn => :next # missing to target
          end
          state :next
        end
      end
    end
  end

  test 'check transition_to alias' do
    Class.new do
      include Apollo
      apollo do
        state :new do
          event :event1, :transition_to => :next
        end
        state :next
      end
    end
  end
end

