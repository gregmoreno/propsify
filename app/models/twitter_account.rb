class TwitterAccount < ActiveRecord::Base

  belongs_to :owner, :polymorphic => true

  attr_accessor :client

  delegate :authorized?, :to => :client

  def client
    @client ||= TwitterOAuth::Client.new config.merge(
      :token => access_token,
      :secret => access_token_secret
    )
  end

  def request_authorization!(options = {})
    token = client.request_token :oauth_callback => options[:callback]
    update_attributes! :request_token => token.token, :request_token_secret => token.secret,
      :request_authorization_url => token.authorize_url
  end

  def authorize!(options = {})
    token = client.authorize request_token, request_token_secret, :oauth_verifier => options[:verifier]
    if authorized?
      update_attributes! :access_token => token.token, :access_token_secret => token.secret
    end
  end

  def deauthorize!
    update_attributes! :access_token => nil, :access_token_secret => nil
  end

  def tweet(text)
    client.update(text) if authorized?
  end

  private

    cattr_reader :config
    @@config = YAML.load_file("#{Rails.root}/config/twitter.yml")[Rails.env].symbolize_keys

end
