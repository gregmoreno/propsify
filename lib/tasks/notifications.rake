namespace :notifications do

  desc "Request for feedback"
  task :requests => :environment do
    Authorization.current_user = User.root

    Invitation.status_is_sending.each do |invitation|
      Notifier.deliver_request_for_recommendation(invitation)
      invitation.sent!
    end
  end

end
