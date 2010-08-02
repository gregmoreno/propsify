ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  out = "<span class='error field_error'>#{html_tag}</span>"
  out += Array(instance.error_message).each_with_object('') do |error, list|
    list << %[<span class="error field_error">&rarr; #{error}</span>]
  end unless html_tag =~ /label/

  out
end
