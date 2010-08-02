class Notifier < ActionMailer::Base
  include PagesHelper
  include RoutesHelper

  def request_for_recommendation(invitation)
    set_email_params

    created_for = invitation.created_for
    created_by  = invitation.created_by
    voteable    = invitation.voteable

    recipients "#{created_for.name} <#{created_for.email}>"
    from       "#{voteable.name} <#{created_by.email}>"
    reply_to   "#{voteable.name} <#{created_by.email}>"
    subject    "Recommendation request from #{voteable.name}"
    headers    'return-path' => created_by.email

    body email_default.merge(
           :created_for => created_for,
           :created_by  => created_by,
           :voteable    => voteable,
           :invitation_url  => accept_invitation_url(:token => invitation.token))
  end

  def vote_notice_to_owner(vote)
    set_email_params

    voter    = vote.voter
    voteable = vote.voteable

    recipients "#{voteable.name} <#{voteable.owner.email}>"
    from       "Propsify <#{support_email}>" 
    reply_to   "Propsify <#{support_email}>"
    subject    "Good news! New recommendation for #{voteable.name}"
    headers    'return-path' => support_email

    body email_default.merge(
           :voter    => voter,
           :voteable => voteable,
           :vote_url => user_vote_url(voter, vote))
  end

  def vote_notice_to_voter(vote)
    set_email_params

    voter    = vote.voter
    voteable = vote.voteable

    recipients "#{voter.name} <#{voter.email}>"
    from       "#{voteable.name} <#{voteable.owner.email}>" 
    reply_to   "#{voteable.name} <#{voteable.owner.email}>"
    subject    "Thank you from #{voteable.name}"
    headers    'return-path' => voteable.owner.email

    body email_default.merge(
           :voter    => voter,
           :voteable => voteable,
           :voteable_url => voteable_url(voteable))
  end

  def password_reset_instructions(user)
    set_email_params

    recipients "#{user.name} <#{user.email}>"
    from       "Propsify <#{support_email}>"
    reply_to   "Propsify <#{support_email}>"
    subject    'Password reset instructions for your Propsify account'
    headers    'return-path' => support_email

    body email_default.merge(
           :user                    => user,
           :edit_password_reset_url => edit_password_reset_url(user.perishable_token))
  end

  def welcome(user)
    set_email_params

    recipients "#{user.name} <#{user.email}>"
    from       "Propsify <#{support_email}>"
    reply_to   "Propsify <#{support_email}>"
    subject    'Welcome to Propsify'
    headers    'return-path' => support_email

    body email_default.merge(:user  => user)
  end


  #######
  private
  #######


  def email_default
    { :site_name     => site_name,
      :site_url      => site_url,
      :site_tagline  => site_tagline,
      :support_email => support_email
    }
  end

  def set_email_params
    # Even though this is set in config/environments, sometimes
    # it still complains of missing host. 
    # That's why it was included here
    default_url_options[:host] = $BASE_HOST
  end
end
