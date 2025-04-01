require 'bundler/setup'
require_relative 'notes'

notes = Notes.new
notes.read("notes")
notes.check
print notes.errors
notes.write("notes") if notes.updated.count > 0
