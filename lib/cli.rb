# frozen_string_literal: true

require "thor"
require "date"
require_relative "miti"
require_relative "miti/cli/next"

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
      date = Date.today
      current_nepali_miti = Miti.to_bs(date.to_s)
      formatted_miti = "[#{current_nepali_miti} BS] #{current_nepali_miti.descriptive}"
      formatted_date = "[#{date} AD] " + date.strftime("%B %d, %Y %A")

      @shell.say(formatted_miti.to_s, :green)
      @shell.say(formatted_date.to_s, :green)
    end

    desc "to_bs ENGLISH_DATE", "converts ENGLISH_DATE to Nepali Miti"
    long_desc <<-DESC
    Converts english date to nepali miti.
    The `to_bs` command takes a argument <ENGLISH_DATE>, argument must be in YYYY/MM/DD or YYYY-MM-DD format

    Example: $ miti to_bs 2023-06-28

    Output: [2080-03-13 BS] Ashadh 13, 2080 Wednesday
    DESC

    def to_bs(english_date)
      converted_nepali_miti = Miti.to_bs(english_date)
      output_txt = "[#{converted_nepali_miti} BS] #{converted_nepali_miti.descriptive}"
    rescue ConversionUnavailableError => e
      output_txt = e
      @output_color = :red
    ensure
      @shell.say(output_txt, @output_color)
    end

    desc "to_ad NEPALI_MITI", "converts NEPALI_MITI to English Date"
    long_desc <<-DESC
    Converts nepali miti.
    The `to_ad` command takes a argument <NEPALI_MITI>, argument must be in YYYY/MM/DD or YYYY-MM-DD format

    Example: $ miti to_ad 2080-03-13

    Output: [2023-06-28 AD] June 28, 2023 Wednesday
    DESC

    def to_ad(nepali_date)
      converted_english_date = Miti.to_ad(nepali_date)
      output_txt = "[#{converted_english_date} AD] #{converted_english_date.strftime("%B %d, %Y %A")}"
    rescue ConversionUnavailableError => e
      output_txt = e
      @output_color = :red
    ensure
      @shell.say(output_txt, @output_color)
    end

    desc "next", "get remaining days for 1st of next month and last day of current month"
    def next
      days_left_description, current_month_last_description = Cli::Next.new(NepaliDate.today).calculate
      @shell.say(days_left_description, :green)
      @shell.say(current_month_last_description, :green)
    end

    desc "difference", "get remaining days for 1st of next month and last day of current month"
    def difference(date1, date2)
      @shell.say(Miti.differentiate(date1, date2), :cyan)
    end

    no_commands do
      def self.exit_on_failure?
        true
      end
    end

    map ad: :to_ad
    map bs: :to_bs
  end
end
