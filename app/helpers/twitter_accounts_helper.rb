module TwitterAccountsHelper

  # See TwitterAccountsController for notes regarding the funky path helpers

  def polymorphic_twitter_account_path
    polymorphic_path([ @workspace, :twitter_account ])
  end

  def polymorphic_edit_twitter_account_path
    edit_polymorphic_path([ @workspace, :twitter_account ])
  end

end
