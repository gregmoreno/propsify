class VoteTweeter < ActiveRecord::Observer

  observe :vote

  MAX_TWEET_LENGTH = 140

  include ActionController::UrlWriter
  include ActionView::Helpers::TextHelper

  default_url_options[:host] = $BASE_HOST
  default_url_options[:port] = $BASE_PORT unless $BASE_PORT.blank?

  def after_create(vote)
    tweet_vote_notice_to_business(vote)
    tweet_vote_notice_to_voter(vote)

    tweet_vote_notice_to_propsify(vote)
  end

  protected

    def tweet_vote_notice_to_business(vote)
      vote.voteable.tweet vote_tweet_text(vote, "Has been recommended by #{vote.voter.name}")
    end

    def tweet_vote_notice_to_voter(vote)
      vote.voter.tweet vote_tweet_text(vote, "Recommends #{vote.voteable.name}")
    end

    def tweet_vote_notice_to_propsify(vote)
      self.class.propsify.tweet vote_tweet_text(vote, "#{vote.voteable.name} has been recommended by #{vote.voter.name}")
    end

    def vote_tweet_text(vote, default)
      text = vote.comment ? vote.comment.text : default
      url = url_for_vote(vote)

      truncate(text, :length => MAX_TWEET_LENGTH-url.length-1) + ' ' + url
    end

    def url_for_vote(vote)
      user_vote_url(vote.voter, vote)
    end

  private

    def self.propsify
      @@propsify ||= User.find_by_name('propsroot')
    end

end
