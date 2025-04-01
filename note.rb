require 'bundler/setup'
require 'mechanize'
require "logger"
require 'uri'
require 'byebug'
require_relative 'page'
require 'date'

class Note
  def initialize(io, file, line)
    @file = file
    @line = line
    @headline = io.sub(/\s*\n.*/m, "").chomp
    @body = io.sub(/^[^\n]*(\s*\n)?/m, "").sub(/\s+\Z/m, "")
    @errors = []
  end

  def headline
    @headline
  end

  def body
    @body.gsub(/^  /m, "")
  end

  def linked_pages
    result = []
    @body.lines.each_with_index do |l, i|
      l.scan(/https?:\/\/\S+/).each do |u|
        result << Page.new(URI(u), i + 2 + @line, @file)
      end
    end
    result
  end

  def errors
    @errors
  end

  def check(date)
    if(@checked.nil?) then
      if linked_pages.any? then
        @body << "\n\n  Checked:"
        @updated = true
        linked_pages.each do |p|
          error "Opening: #{p.url.to_s}"
          IO.popen("sensible-browser '#{p.url.to_s}'")
        end
      end
    else
      linked_pages.each do |p|
        u = p.updated
        if(u.kind_of? Date)
          if u - @checked > 0
            @updated = true
            error "Updated #{u} (checked #{@checked})"
            error "Opening: #{p.url.to_s}"
            IO.popen("sensible-browser '#{p.url.to_s}'")
          end
        end
      end
    end
    if @updated then
      @body.gsub!(/\n\s*Checked:[^\n]*/, "\n  Checked: #{date.to_s}")
    end
  end

  def updated?
    @updated
  end

  def checked_date
    @checked ||= date("Checked")
  end

  def date(field)
    dates = []
    @body.lines.each_with_index do |l, i|
      l.match(/^\s*#{field}:\s*(\d+-\d+-\d+)/i) do |md|
        if(md.kind_of? MatchData)
          begin
            dates << Date.parse(md.match(1).to_s.strip)
          rescue Error => e
            error "Bad date #{md.match(1)}", i
          end
        end
      end
    end
    if dates.empty? then
      nil
    else
      dates.max
    end
  end

  def to_s
    if @body.nil? || @body.empty?
      "#{@headline}\n"
    else
      "#{@headline}\n\n#{@body}\n"
    end
  end

  private

  def error(message, l = 0)
    @errors << "#{@file}:#{l+@line}: #{message}\n"
  end
end
