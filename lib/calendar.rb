# frozen_string_literal: true

require "date"
require_relative "miti"

module Miti
  # Class to render English and Nepali Calendar
  class Calendar
    attr_reader :english_date_today, :nepali_date_today

    def initialize(shell: nil)
      @shell = shell
      @english_date_today = Date.today
      @nepali_date_today = Miti.to_bs(english_date_today.to_s)
    end

    def english_calendar
      first_day_of_month = Date.new(english_date_today.year, english_date_today.month, 1)
      last_day_of_month = Date.new(english_date_today.year, english_date_today.month, -1)

      render_calendar("Calendar for #{english_date_today.strftime("%B %Y")}", first_day_of_month, last_day_of_month)
    end

    def nepali_calendar
      barsa = nepali_date_today.barsa
      mahina = nepali_date_today.mahina
      number_of_days = Miti::Data::NEPALI_YEAR_MONTH_HASH[barsa][mahina - 1]
      first_day_of_month = Miti.to_ad("#{barsa}/#{mahina}/01")
      last_day_of_month = Miti.to_ad("#{barsa}/#{mahina}/#{number_of_days}")

      months = %w[Baishakh Jestha Ashadh Shrawan Bhadra Asoj Kartik Mangsir Poush Magh Falgun Chaitra]
      render_calendar("Calendar for #{months[mahina - 1]} #{barsa}", first_day_of_month, last_day_of_month)
    end

    private

    def render_calendar(title, first_day_of_month, last_day_of_month)
      lines = [title, "Sun Mon Tue Wed Thu Fri Sat"]
      lines += build_weeks(first_day_of_month, last_day_of_month)
      lines.join("\n")
    end

    def build_weeks(first_day, last_day)
      lines = []
      week = " " * (first_day.wday * 4)

      (first_day..last_day).each_with_index do |date, idx|
        week += format_day(idx + 1, date)
        if date.wday == 6
          lines << week.rstrip
          week = ""
        else
          week += " "
        end
      end

      lines << week.rstrip unless week.empty?
      lines
    end

    def format_day(day_value, date)
      day = day_value.to_s.rjust(3)
      date == english_date_today ? colorize_today(day) : day
    end

    def colorize_today(day)
      return day unless @shell.respond_to?(:set_color)

      @shell.set_color(day, :green, true)
    end
  end
end
