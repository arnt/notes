# encoding: utf-8
# frozen_string_literal: true
require 'notes'

RSpec.describe Notes do

  describe "initialization" do
    it "should instantiate empty" do
      expect { Notes.new }.not_to raise_error
    end
  end

  describe "reading" do
    it "should read a single-note entry" do
      @notes = Notes.new
      @notes.read("spec/fixtures/single-entry")
      expect(@notes.count).to eq 1
    end

    it "should read a three-note entry" do
      @notes = Notes.new
      @notes.read("spec/fixtures/three-entries")
      expect(@notes.count).to eq 3
    end
  end

  describe "writing" do
    it "should write a readable file" do
      @notes = Notes.new
      @notes.read("spec/fixtures/three-entries")
      tmp = Tempfile.new('three').path
      @notes.write(tmp)
      @notes2 = Notes.new
      @notes2.read(tmp)
      expect(@notes.to_s).to eq @notes2.to_s
    end
  end

  describe "Github issue processing" do
    before(:each) do
      @notes = Notes.new
      @notes.read("spec/fixtures/single-entry")
    end

    it "should find a github link" do
      l = @notes.linked_pages
      expect(l.count).to eq 1
      expect(l.first.url.to_s).to eq "https://github.com/symfony/symfony/pull/58361"
    end

    it "should see that the link has been updated" do
      allow_any_instance_of(Page).to receive(:updated).and_return(:nil)
      @notes.check(Date.new(2024,11,30))
      expect(@notes.errors.include?("Last checked")).to eq true
    end

    it "should see that the link has been updated" do
      @notes.check(Date.new(2024,9,30))
      expect(@notes.errors.include?("58361")).to eq true
    end
  end
end
