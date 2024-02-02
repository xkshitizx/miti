# frozen_string_literal: true

require "date"

# Class to render English and Nepali Calendar
class Calendar
  attr_reader :english_date_today, :nepali_date_today

  def initialize
    @english_date_today = Date.today
    @nepali_date_today = Miti.to_bs(english_date_today.to_s)
  end

  def english_calendar
    first_day_of_month = Date.new(english_date_today.year, english_date_today.month, 1)
    last_day_of_month = Date.new(english_date_today.year, english_date_today.month, -1)

    puts "Calendar for #{english_date_today.strftime("%B %Y")}"
    puts "Sun Mon Tue Wed Thu Fri Sat"

    print_calendar(first_day_of_month, last_day_of_month)
  end

  def nepali_calendar
    barsa = nepali_date_today.barsa
    mahina = nepali_date_today.mahina
    number_of_days = Miti::Data::NEPALI_YEAR_MONTH_HASH[barsa][mahina - 1]
    first_day_of_month = Miti.to_ad("#{barsa}/#{mahina}/01")
    last_day_of_month = Miti.to_ad("#{barsa}/#{mahina}/#{number_of_days}")

    puts "Calendar for #{Miti::NepaliDate.months_in_english[mahina - 1]} #{barsa}"
    puts "Sun Mon Tue Wed Thu Fri Sat"

    print_calendar(first_day_of_month, last_day_of_month)
  end

  def print_calendar(first_day_of_month, last_day_of_month)
    (first_day_of_month..last_day_of_month).each_with_index do |date, idx|
      idx += 1
      if date == first_day_of_month
        print " " * (date.wday * 4) # Add spaces for the first week
      end

      if date == english_date_today
        # Highlight the current day in a different color
        print "\e[1;32m#{idx.to_s.rjust(3)}\e[0m" # Green text
      else
        print idx.to_s.rjust(3) # Right-align day number
      end

      if date.wday == 6
        puts "\n"  # Start a new line for the next week on Saturday
      else
        print " "  # Add space between days
      end
    end
    puts "\n"
  end
end
