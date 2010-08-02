module RatingsHelper

  def render_number(number, option=nil)
    number = number.to_i

    if option == :sign
      text = "+#{number}" if number > 0
      text = "-#{number}" if number < 0
      text = "0" if number == 0
    else
      text = "#{number}"
    end
    
    content_tag(:span, text, :class => (option.nil? ? "number" : "number #{option}"))
  end

end
