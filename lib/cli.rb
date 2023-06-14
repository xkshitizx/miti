# frozen_string_literal: true

require "thor"
require "date"
require_relative "miti"

module Miti
  # class to integrate CLI
  class CLI < Thor
    def initialize(*args)
      super
      @shell = Thor::Shell::Color.new
    end

    desc "today", "today's nepali miti"
    def today
      current_nepali_miti = Miti.to_bs(Date.today)
      output_txt = "[#{current_nepali_miti}] #{current_nepali_miti.descriptive}"

      @shell.say(output_txt, :green)
    end

    desc "on ENGLISH_DATE", "converts english date to nepali miti"
    def on(english_date)
      converted_nepali_miti = Miti.to_bs(english_date)
      output_txt = "[#{converted_nepali_miti}] #{converted_nepali_miti.descriptive}"

      @shell.say(output_txt, :green)
    end

    desc "to NEPALI_DATE", "converts nepali miti to english date"
    def to(nepali_date)
      converted_english_date = Miti.to_ad(nepali_date)
      output_txt = "[#{converted_english_date}] #{converted_english_date.strftime('%B %d, %Y %A')}"

      @shell.say(output_txt, :green)
    end

    no_commands do
      def self.exit_on_failure?
        true
      end
    end
  end
end
