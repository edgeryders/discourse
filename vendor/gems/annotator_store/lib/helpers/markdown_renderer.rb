# Source: https://stackoverflow.com/questions/23051568/how-to-embed-a-youtube-video-in-markdown-with-redcarpet-for-rails
require 'redcarpet'

class MarkdownRenderer < Redcarpet::Render::HTML

  def autolink(link, link_type)
    case link_type
    when :url then
      url_link(link)
    when :email then
      email_link(link)
    end
  end

  def url_link(link)
    case link
    when /^https:\/\/youtube/ then
      youtube_link(link)
    when /\.mp4$/ then
      video_link(link)
    else
      normal_link(link)
    end
  end

  # @todo add poster attribute: poster=\"http://....com/file.png\"
  def video_link(link)
    upload = Upload.get_from_url(link)
    "<div id=\"video-wrapper\">
      <video class=\"video-js vjs-default-skin\" controls preload=\"none\" width=\"640\" height=\"264\" >
        <source src=\"#{upload.url}\" type=\"video/mp4\"/>
      </video>
      <div style=\"margin-top:10px;\"><a href=\"/annotator_store/video/#{upload.id}\" target=\"_blank\">See annotations / add annotations</a></div>
    </div>"
  end

  def youtube_link(link)
    parameters_start = link.index('?')
    video_id = link[15..(parameters_start ? parameters_start - 1 : -1)]
    "<iframe width=\"560\" height=\"315\" src=\"//www.youtube.com/embed/#{video_id}?rel=0\" frameborder=\"0\" allowfullscreen></iframe>"
  end

  def normal_link(link)
    "<a href=\"#{link}\">#{link}</a>"
  end

  def email_link(email)
    "<a href=\"mailto:#{email}\">#{email}</a>"
  end

  def image(link, title, alt_text)
    upload = Upload.find_by(sha1: Upload.sha1_from_short_url(link) )
    if upload.present?
      "<div class=\"annotator-image\" id=\"image-#{upload.id}\"><img src=\"#{upload.url}\" alt=\"#{alt_text}\" /></div>"
    end
  end


end
