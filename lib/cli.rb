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
      date = Date.today
      current_nepali_miti = Miti.to_bs(date.to_s)
      formatted_miti = "[#{current_nepali_miti} BS] #{current_nepali_miti.descriptive}"
      formatted_date = "[#{date} AD] " + date.strftime("%B %d, %Y %A")

      @shell.say("#{formatted_miti}\n#{formatted_date}", :green)
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
      next_month = Miti.to_bs(Date.today.to_s).next_month_first
      days_left_description = "\n#{next_month[:days_left]} days left until 1st #{next_month[:month_name]}"
      current_month_last_description = "Current month's last date => #{next_month[:antim_gatey]}"

      @shell.say(days_left_description, :green)
      @shell.say(current_month_last_description, :cyan)
    end

    desc "english_calendar", "show current month's english calendar"
    def english_calendar
      Calendar.new.english_calendar
    end

    desc "nepali_calendar", "show current month's nepali calendar"
    def nepali_calendar
      Calendar.new.nepali_calendar
    end

    no_commands do
      def self.exit_on_failure?
        true
      end
    end
  end
end
