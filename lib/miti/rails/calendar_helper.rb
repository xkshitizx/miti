# frozen_string_literal: true

module Miti
  module Rails
    module CalendarHelper
      def nepali_calendar(options = {}, &)
        today = options[:today] || Date.today
        year  = options[:year]  || Miti::NepaliDate.today.barsa
        month = options[:month] || Miti::NepaliDate.today.mahina
        turbo = options.key?(:turbo_frame) ? options[:turbo_frame] : "nepali_calendar"
        html  = options[:html] || {}

        days_in_month = Miti::Data::NEPALI_YEAR_MONTH_HASH[year][month - 1]
        first_day_ad  = Miti.to_ad("#{year}/#{month}/01")
        start_wday    = first_day_ad.wday

        content = build_calendar(year, month, days_in_month, start_wday, today, turbo, html, &)
        turbo ? tag.div(content, data: { turbo_frame: turbo }) : content
      end

      def nepali_calendar_agenda(start_date, end_date, options = {}, &block)
        today    = options[:today] || Date.today
        group_by = options[:group_by] || :week

        start_bs = parse_bs_date(start_date)
        end_bs   = parse_bs_date(end_date)

        tag.div(class: "miti-agenda") do
          safe_join(build_agenda_groups(start_bs, end_bs, group_by, today, &block))
        end
      end

      private

      def build_calendar(year, month, days_in_month, start_wday, today, turbo, html, &block)
        months_english = Miti::NepaliDate.months_in_english

        nav = tag.div(class: "miti-calendar__nav") do
          prev_link = calendar_nav_link(year, month, -1, turbo, "\u2190")
          next_link = calendar_nav_link(year, month, 1, turbo, "\u2192")
          title     = tag.span("#{months_english[month - 1]} #{year}", class: "miti-calendar__title")
          safe_join([prev_link, title, next_link])
        end

        table = tag.table(html, class: "miti-calendar") do
          safe_join([
                      tag.thead(tag.tr(safe_join(
                                         %w[Sun Mon Tue Wed Thu Fri Sat].map do |d|
                                           tag.th(d, class: "miti-calendar__header")
                                         end
                                       ))),
                      tag.tbody(safe_join(build_weeks(year, month, days_in_month, start_wday, today, &block)))
                    ])
        end

        safe_join([nav, table])
      end

      def build_weeks(year, month, days_in_month, start_wday, today, &block)
        weeks = []
        cells = []

        start_wday.times do
          cells << tag.td("", class: "miti-calendar__day miti-calendar__day--other")
        end

        (1..days_in_month).each do |gatey|
          nepali_date = Miti::NepaliDate.new(barsa: year, mahina: month, gatey: gatey)
          presenter   = Miti::Rails::Calendar::DayPresenter.new(nepali_date, today: today)

          classes = %w[miti-calendar__day]
          classes << "miti-calendar__day--today" if presenter.today?
          classes << "miti-calendar__day--sun" if presenter.sunday?
          classes << "miti-calendar__day--sat" if presenter.saturday?

          inner = safe_join([
                              tag.span(gatey.to_s, class: "miti-calendar__gatey"),
                              tag.span(presenter.ad_date.strftime("%d"), class: "miti-calendar__ad-date")
                            ])

          inner << capture(presenter, &block) if block

          cells << tag.td(inner, class: classes.join(" "))

          if presenter.saturday? || gatey == days_in_month
            weeks << tag.tr(safe_join(cells))
            cells = []
          end
        end

        weeks
      end

      def calendar_nav_link(year, month, direction, turbo_frame, label)
        new_month = month + direction
        if new_month < 1
          new_month = 12
          new_year  = year - 1
        elsif new_month > 12
          new_month = 1
          new_year  = year + 1
        else
          new_year = year
        end

        attrs = { class: "miti-calendar__nav-link" }
        attrs[:data] = { turbo_frame: turbo_frame } if turbo_frame
        link_to(label, { bs_year: new_year, bs_month: new_month }, attrs)
      end

      def build_agenda_groups(start_bs, end_bs, group_by, today, &)
        groups = []
        current = start_bs

        while current && current <= end_bs
          months_english = Miti::NepaliDate.months_in_english

          days = if group_by == :month
                   header = "#{months_english[current.mahina - 1]} #{current.barsa}"
                   collect_same_month(current, end_bs)
                 else
                   header = "Week of #{current.descriptive}"
                   collect_week(current, end_bs)
                 end

          groups << render_agenda_group(header, days, today, &)
          current = days.last ? next_bs_day(days.last) : nil
        end

        groups
      end

      def collect_same_month(start, end_bs)
        days = []
        c = start
        while c && c <= end_bs && c.mahina == start.mahina && c.barsa == start.barsa
          days << c
          c = next_bs_day(c)
        end
        days
      end

      def collect_week(start, end_bs)
        days = []
        c = start
        while c && c <= end_bs
          days << c
          break if c.bar == 6

          c = next_bs_day(c)
        end
        days
      end

      def render_agenda_group(header, days, today, &block)
        tag.section(class: "miti-agenda__group") do
          safe_join([
                      tag.h3(header, class: "miti-agenda__header"),
                      tag.ul(class: "miti-agenda__list") do
                        safe_join(days.map { |day| render_agenda_item(day, today, &block) })
                      end
                    ])
        end
      end

      def render_agenda_item(day, today, &block)
        presenter = Miti::Rails::Calendar::DayPresenter.new(day, today: today)
        item_content = block ? capture(presenter, &block) : ""

        classes = %w[miti-agenda__item]
        classes << "miti-agenda__item--today" if presenter.today?

        tag.li(class: classes.join(" ")) do
          safe_join([
                      tag.div(class: "miti-agenda__date") do
                        safe_join([
                                    tag.span(day.descriptive, class: "miti-agenda__bs"),
                                    tag.span(day.tarik.strftime("%a %d %b"), class: "miti-agenda__ad")
                                  ])
                      end,
                      tag.div(item_content, class: "miti-agenda__content")
                    ])
        end
      end

      def parse_bs_date(date)
        case date
        when Miti::NepaliDate then date
        when String then Miti::NepaliDate.parse(date)
        else raise ArgumentError, "Expected String or Miti::NepaliDate"
        end
      end

      def next_bs_day(date)
        max_day = Miti::Data::NEPALI_YEAR_MONTH_HASH[date.barsa][date.mahina - 1]
        if date.gatey < max_day
          Miti::NepaliDate.new(barsa: date.barsa, mahina: date.mahina, gatey: date.gatey + 1)
        elsif date.mahina < 12
          Miti::NepaliDate.new(barsa: date.barsa, mahina: date.mahina + 1, gatey: 1)
        else
          Miti::NepaliDate.new(barsa: date.barsa + 1, mahina: 1, gatey: 1)
        end
      end
    end
  end
end
