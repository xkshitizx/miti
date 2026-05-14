# Miti
[![Gem Version](https://badge.fury.io/rb/miti.svg)](https://badge.fury.io/rb/miti)
[![CI](https://github.com/xkshitizx/miti/actions/workflows/main.yml/badge.svg)](https://github.com/xkshitizx/miti/actions/workflows/main.yml)

Converts between English (AD) and Nepali (BS) dates. Includes a CLI app, Rails helpers (date picker, calendar, model concern), and full Rails integration.

## Installation

    $ gem install miti

Or add to your Gemfile:

    $ bundle add miti

## CLI

All date arguments must be in `YYYY-MM-DD` or `YYYY/MM/DD` format.

    $ miti today
    # [2082-01-15 BS] Baisakh 15, 2082 Wednesday
    # [2025-04-28 AD] April 28, 2025 Monday

    $ miti to_bs 2025-04-28
    # [2082-01-15 BS] Baisakh 15, 2082 Wednesday

    $ miti to_ad 2082-01-15
    # [2025-04-28 AD] April 28, 2025 Monday

    $ miti next
    # 17 days left until 1st Jestha
    # Current month's last date => 31 Baisakh

## Ruby API

```ruby
require "miti"

Miti.to_bs("2025-04-28")
#=> #<Miti::NepaliDate:0x... @barsa=2082, @mahina=1, @gatey=15>

Miti.to_bs("2025-04-28").descriptive
#=> "Baisakh 15, 2082 Wednesday"

Miti.to_bs("2025-04-28").descriptive(nepali: true)
#=> "बैशाख 15, 2082 Wednesday(बुधबार)"

Miti.to_bs("2025-04-28").to_s
#=> "2082-01-15"

Miti.to_ad("2082-01-15")
#=> #<Date: 2025-04-28 ...>
```

## Rails Integration

### Setup

    $ rails generate miti:install

To copy styles into your app for customization:

    $ rails generate miti:install --copy-styles

To undo: `rails destroy miti:install`

### Date picker (popover calendar)

```erb
<%= form.nepali_date_field :happened_on_bs %>
<!-- readonly text input with calendar icon that opens a month/year picker popover -->
```

With a default value:

```erb
<%= form.nepali_date_field :happened_on_bs, value: "2082-01-15" %>
```

### Date select (3 dropdowns)

```erb
<%= form.nepali_date_select :happened_on_bs %>
<!-- renders year, month, day select elements -->
```

### Model concern

```ruby
class Event < ApplicationRecord
  include Miti::Rails::ModelConcern
  has_nepali_date :happened_on
end
```

This defines:
- `event.happened_on_bs` — returns BS date as `Miti::NepaliDate`
- `event.happened_on_bs = "2082-01-15"` — sets the AD column from a BS string
- `event.happened_on_bs_human` — readable description (respects `I18n.locale`)

### Calendar grid

```erb
<%= nepali_calendar(year: 2082, month: 1) do |day| %>
  <%= day.gatey %>
<% end %>
```

Renders a monthly grid with Turbo Frame navigation.

### Agenda view

```erb
<%= nepali_calendar_agenda(start_date, end_date, group_by: :week) do |day| %>
  <%= day.descriptive %>
<% end %>
```

Renders a grouped list of dates.

### DayPresenter

Yielded to calendar/agenda blocks:

| Method | Returns |
|--------|---------|
| `day.gatey` | Day of month (1-32) |
| `day.barsa` | Year |
| `day.mahina` | Month (1-12) |
| `day.bar` | Weekday index (0=Sunday) |
| `day.tarik` | Equivalent AD `Date` |
| `day.to_s` | BS date as `yyyy-mm-dd` |
| `day.descriptive` | Human readable |
| `day.today?` / `day.sunday?` / `day.saturday?` | Boolean checks |

### Ruby version

Supports Ruby 3.1 through 4.x. Rails integration loads automatically when `Rails` is defined.

## Development

    $ bin/setup
    $ bundle exec rake spec
    $ bin/console

## Contributing

Bug reports and pull requests are welcome at [github.com/xkshitizx/miti](https://github.com/xkshitizx/miti).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
