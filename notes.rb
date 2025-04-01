require 'bundler/setup'
require 'mechanize'
require "logger"
require 'uri'
require 'byebug'
require_relative 'note'

class Notes
  attr_reader :notes

  def read(name)
    l = 1
    @notes = File.read(name).split(/^(?!\s)/m).map do |s|
      result = Note.new(s, name, l)
      l = l + s.lines.count
      result
    end
  end

  def write(name)
    File.write(name, to_s)
  end

  def count
    @notes.count
  end

  def updated
    @notes.select{ |n| n.updated? }
  end

  def linked_pages
    @notes.map{ |n| n.linked_pages }.flatten
  end

  def errors
    @notes.map{ |n| n.errors }.select{ |e| !e.empty? }.join
  end

  def check(date = Date.today)
    print "notes: #{@notes.count}\n"
    @notes.each{ |n| n.check(date) }
  end

  def to_s
    @notes.map{|n| n.to_s}.join("\n\n")
  end
end

