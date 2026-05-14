# frozen_string_literal: true

module Miti
  module Rails
    module Calendar
      class DayPresenter
        attr_reader :date

        delegate :gatey, :barsa, :mahina, :bar, :tarik, :to_s, :descriptive, to: :date

        def initialize(date, today:)
          @date = date
          @today = today
        end

        def today?
          @date.tarik == @today
        end

        def to_param
          @date.to_s
        end

        def ad_date
          @date.tarik
        end

        def to_ad
          @date.tarik
        end

        def sunday?
          @date.bar.zero?
        end

        def saturday?
          @date.bar == 6
        end
      end
    end
  end
end
