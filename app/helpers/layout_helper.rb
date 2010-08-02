module LayoutHelper

  def single_column(options={}, &block)
    column(merge_kv({:class => 'single_column'}, options), &block)
  end

  def single_center(&block)
    column({:class => 'single_center'}, &block)
  end

  def wide_column(&block)
    column({:class => 'wide_column'}, &block)
  end

  def main_column(options={}, &block)
    column(merge_kv({:class => 'main_column'}, options), &block)
  end

  def sidebar_column(options={}, &block)
    column(merge_kv({:class => 'sidebar'}, options), &block)
  end


  def tabbed_column(tabs, &block)
    html = content_tag(:div, :class => 'tabbed_column') do
      content_tag(:div, '', :class => 'topLeft') +
      content_tag(:div, '', :class => 'topRight') +
      content_tag(:div) do
        render(:partial => tabs) +
        content_tag(:div, :class => 'tabbed_content') do
          content_tag(:div, :class => 'tab_wrapper') do
            content_tag(:div, '', :class => 'topRight') +
            content_tag(:div, capture(&block), :class => 'content') +
            content_tag(:div, '', :class => 'bottomLeft') +
            content_tag(:div, '', :class => 'bottomRight')
          end
        end
      end +
      content_tag(:div, '', :class => 'bottomLeft') +
      content_tag(:div, '', :class => 'bottomRight')
    end
    concat html
  end


  def nav_separator(html = '&#124')
    content_tag(:span, html, :class => 'separator') 
  end

  def paginate(collection)
    will_paginate(collection)
  end


  private

  
  def merge_kv(op1, op2)
    join = op1
    op2.keys.each do |k|
      if op1.has_key?(k)
        join[k] << ' ' << op2[k]
      else
        join[k] = op2[k]
      end
    end
    join
  end

  def column(options={}, &block)
    concat content_tag(:div, capture(&block), options)
  end

end
