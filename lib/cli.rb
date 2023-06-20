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
      @output_color = :green
    end

    desc "today", "today's nepali miti"
    def today
      current_nepali_miti = Miti.to_bs(Date.today.to_s)
      output_txt = "[#{current_nepali_miti}] #{current_nepali_miti.descriptive}"

      @shell.say(output_txt, :green)
    end

    desc "on ENGLISH_DATE", "converts english date to nepali miti"
    def to_bs(english_date)
      converted_nepali_miti = Miti.to_bs(english_date)
      output_txt = "[#{converted_nepali_miti}] #{converted_nepali_miti.descriptive}"
    rescue ConversionUnavailableError => e
      output_txt = e
      @output_color = :red
    ensure
      @shell.say(output_txt, @output_color)
    end

    desc "to NEPALI_DATE", "converts nepali miti to english date"
    def to_ad(nepali_date)
      converted_english_date = Miti.to_ad(nepali_date)
      output_txt = "[#{converted_english_date}] #{converted_english_date.strftime('%B %d, %Y %A')}"
    rescue ConversionUnavailableError => e
      output_txt = e
      @output_color = :red
    ensure
      @shell.say(output_txt, @output_color)
    end

    no_commands do
      def self.exit_on_failure?
        true
      end
    end
  end
end
