module ApplicationHelper
  def breadcrumb_tag(&block)
    render 'application/breadcrumb', block: capture(&block)
  end

  def ru_date(date)
    "#{date.day}.#{date.month}.#{date.year}"
  end
end
