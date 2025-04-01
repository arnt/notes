require 'bundler/setup'
require 'mechanize'
require "logger"
require 'uri'
require 'byebug'

class Page
  @@mechanize = Mechanize.new

  attr_reader :url
  attr_reader :file
  attr_reader :line
  attr_reader :mechanize
  attr_accessor :page

  def initialize(url, file, line)
    @url = url
    @line = line
    @file = file
    @page = nil
    @error = nil
    @mechanize = Mechanize.new
  end

  def retrieve_carefully
    begin
      @page = @mechanize.get(@url)
    rescue Exception => e
      @error = e
    end
  end

  def updated
    retrieve_carefully if (@page.nil? && @error.nil?)
    if(@page.nil?)
      nil
    elsif(@page.uri.host == "github.com")
      github_date
    else
      nil
    end
  end

  def github_date
    DateTime.parse(page.search("#partial-timeline").first.
                     attributes["data-last-modified"].
                     value).to_date
  end

  def error
    "#{file}:#{file}: #{@error.to_s}\n" unless @error.nil?
  end
end
