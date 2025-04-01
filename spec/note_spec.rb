# encoding: utf-8
# frozen_string_literal: true
require 'note'

RSpec.describe Note do

  describe "initialization" do
    it "should accept single-line text" do
      n = nil;
      expect { n=Note.new("test", "notes", 1) }.not_to raise_error
      expect(n.headline).to eq "test"
    end
    it "should accept three-line text" do
      n = nil;
      expect { n=Note.new("test\n\n  foo\n", "notes", 1) }.not_to raise_error
      expect(n.headline).to eq "test"
      expect(n.body).to eq "foo"
    end
    it "should accept two-paragraph body" do
      n = Note.new("test\n\n  a\n  b\n\n  c\n", "notes", 1)
      expect(n.body).to eq "a\nb\n\nc"
    end
  end

  describe "github issue processing" do
    before(:each) do
      @note = Notes.new.read("spec/fixtures/single-entry").first
    end

    it "should find a link" do
      expect(@note.linked_pages.count).to eq 1
    end

    it "should find a check date" do
      expect(@note.checked_date).to eq Date.new(2024,9,20)
    end
  end
end
