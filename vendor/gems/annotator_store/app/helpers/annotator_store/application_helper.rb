module AnnotatorStore
  module ApplicationHelper

    require_relative '../../../lib/helpers/markdown_renderer'
    def markdown(content)
      @markdown ||= Redcarpet::Markdown.new(MarkdownRenderer, autolink: true)
      @markdown.render(content).html_safe
    end

  end
end
