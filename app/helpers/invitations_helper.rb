module InvitationsHelper
  def render_invitation_status(invitation)
    case invitation.status
    when Invitation::SENDING:  "sending"
    when Invitation::SENT:     "sent"
    when Invitation::ACCEPTED: "accepted"
    end
  end

end
