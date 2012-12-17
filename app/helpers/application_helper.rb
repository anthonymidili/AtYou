module ApplicationHelper

  #Returns the full title on a per-paage basis.
  def full_title(page_title)
    base_title = "Bookkeeping"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

end
