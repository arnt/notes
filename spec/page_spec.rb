# encoding: utf-8
# frozen_string_literal: true
require 'page'

RSpec.describe Page do

  describe "initialization" do
    it "should record the arguments" do
      p=Page.new("https://invalid.invalid", "notes", 2)
      expect(p.file).to eq "notes"
      expect(p.line).to eq 2
      expect(p.page).to eq nil
      expect(p.error).to eq nil
    end
  end

  describe "processing of github issues" do
    before(:each) do
      @p=Page.new(URI("https://github.com/symfony/symfony/pull/58361"),
                  "notes", 2)
    end

    it "should find the date of the last comment" do
      expect(@p.updated.to_date).to eq Date.new(2024,9,27)
    end

    it "should not return an error" do
      expect(@p.error).to eq nil
    end
  end
end
