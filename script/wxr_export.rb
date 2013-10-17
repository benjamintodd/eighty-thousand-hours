# script/wxr_export.rb
require 'builder'
require 'pry'


#!/usr/bin/env ruby

APP_PATH = File.expand_path('../../config/application',  __FILE__)
require File.expand_path('../../config/boot',  __FILE__)
require APP_PATH
# set Rails.env here if desired
Rails.application.require_environment!



xml = Builder::XmlMarkup.new

xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"

def comment_render(xml, comment, parent=0) 
  comment_xml(xml,comment,parent)
  comment.comments.each do |c|
    comment_render(xml,c, comment.id)
  end
end

def comment_xml(xml, comment, parent)
  xml.wp(:comment) do

    xml.wp(:comment_id) { |x| x << comment.id.to_s }

    xml.wp(:comment_author) do |x| 
      user = comment.user
      if user.present?
        x << comment.user.name
      elsif !comment.name.nil?
        x << comment.name
      else
        x << ""
      end
    end

    xml.wp(:comment_author_email) do |x| 
      if comment.user.present? && comment.user.email.present?
        x << comment.user.email
      elsif !comment.email.nil?
        x << comment.email
        x << ""
      end
    end

    xml.wp(:comment_author_url) do |x|
      if comment.user.present? and !comment.user.url.nil?
        x << comment.user.url
      else
        x << ""
      end
    end

    xml.wp(:comment_author_IP) { |x| x << "255.255.255.255" }

    xml.wp(:comment_date_gmt) { |x| x << comment.created_at.utc.to_formatted_s(:db) }

    xml.wp(:comment_content) { |x| x << "<![CDATA[" + comment.body + "]]>" }
    #xml.message { |x| x <<  comment.body }

    xml.wp(:comment_approved) { |x| x << '1' } #approve all comments

    xml.wp(:comment_parent) { |x| x << parent.to_s }

  end #xml.wp(:comment)
end

xml.rss 'version' => "2.0",
  'xmlns:content' => "http://purl.org/rss/1.0/modules/content/",
  'xmlns:dsq' => "http://www.disqus.com/",
  'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
  'xmlns:wp' => "http://wordpress.org/export/1.0/" do

    xml.channel do
      BlogPost.all.each do |article|
        xml.item do

          xml.title article.title

          xml.link article.url

          xml.content(:encoded) { |x| x << "<![CDATA[" + article.body + "]]>" }

          xml.dsq(:thread_identifier) { |x| x << article.id }

          xml.wp(:post_date_gmt) { |x| x << article.created_at.utc.to_formatted_s(:db) }

          xml.wp(:comment_status) { |x| x << "open" } #all comments open

          article.comments.each do |comment|
            comment_render(xml, comment)

          end#article.comments.each
        end   #xml.item
      end       #Articles.all.each
    end         #xml.channel
  end           #xml.rss




  puts xml.xml
