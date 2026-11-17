

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
    # [2082-01-15 BS] Baisakh 15, 2082 Monday
    # [2025-04-28 AD] April 28, 2025 Monday

    $ miti to_bs 2025-04-28
    # [2082-01-15 BS] Baisakh 15, 2082 Monday

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
#=> "Baisakh 15, 2082 Monday"

Miti.to_bs("2025-04-28").descriptive(nepali: true)
#=> "बैशाख 15, 2082 Monday(सोमबार)"

Miti.to_bs("2025-04-28").to_s
#=> "2082-01-15"

Miti.to_bs("2025-04-28").format("%g %b %m")
#=> "15 2082 01"

Miti.to_bs("2025-04-28").format("%B %g, %Y %A")
#=> "Baishakh 15, 2082 Monday"

Miti.to_bs("2025-04-28").format("%B %g, %Y %A", nepali: true)
#=> "वैशाख 15, 2082 सोमबार"

Miti.to_ad("2082-01-15")
#=> #<Date: 2025-04-28 ...>
```

`format` tokens. The named form (e.g. `%<gatey>g`) works too.

| Token | Output |
|-------|--------|
| `%g` | Day, zero-padded (`05`) |
| `%m` | Month, zero-padded (`01`) |
| `%b` / `%Y` | Year (`2082`) |
| `%B` | Month name |
| `%A` | Weekday name |

With `nepali: true`, `%B` and `%A` come out in Nepali.

## Rails Integration

### Setup

    $ rails generate miti:install

The generator:
- adds `import "miti"` to `app/javascript/application.js`. Importmap apps get the pins from the gem automatically
- adds `stylesheet_link_tag "miti/calendar"` to your application layout
- copies the JS files into `app/javascript/miti/` when it detects a bundler (esbuild, webpack, rollup or vite)

Options:

    $ rails generate miti:install --copy-styles      # copy calendar.css into your app for customization
    $ rails generate miti:install --copy-javascript  # force-copy the JS files into app/javascript/miti/

To copy JavaScript into your app for bundler setup: `rails generate miti:install --copy-javascript`

To undo: `rails destroy miti:install`

To set things up by hand, use `miti_assets` in your layout's `<head>`. It includes the calendar data and the stylesheet:

```erb
<%= miti_assets %>
```

#### Upgrading from 1.2.x

- `nepali_date_field` now submits the BS string (e.g. `event[happened_on] = "2082-01-15"`) instead of a hidden AD input. `has_nepali_date` converts it to AD on assignment. Without the model concern, convert it in the controller (see [Controller concern](#controller-concern))
- The calendar data endpoint is now `POST`. Re-run `rails generate miti:install --copy-javascript` if you copied the JS files earlier

### Date picker (popover calendar)

```erb
<%= form.nepali_date_field :happened_on %>
<!-- readonly text input with calendar icon that opens a month/year picker popover -->
<!-- submits as event[happened_on] — no _bs suffix needed -->
```

With a default value:

```erb
<%= form.nepali_date_field :happened_on, value: "2082-01-15" %>
```

#### Themes

```erb
<%= form.nepali_date_field :happened_on, theme: :dark %>
<%= form.nepali_date_field :happened_on, theme: :tokyo_night %>
```

Available themes: `light` (default), `dark`, `indigo`, `midnight`, `tokyo_night`, `nord`.

Use `data-miti-theme` on any ancestor to style a group of pickers:

```erb
<div data-miti-theme="dark">
  <%= form.nepali_date_field :start_date %>
  <%= form.nepali_date_field :end_date %>
</div>
```

Dark mode auto-detects `prefers-color-scheme: dark`. Set `data-miti-theme-auto="false"` on any ancestor to disable:

```erb
<div data-miti-theme-auto="false">
  <%= form.nepali_date_field :happened_on %>
</div>
```

#### Date range picker

```erb
<%= form.nepali_date_range_field :start_date, :end_date %>
<!-- Single clickable input + two hidden inputs; drag-to-select or click-to-select range -->
```

With defaults:

```erb
<%= form.nepali_date_range_field :start_date, :end_date,
      start_value: "2082-01-15", end_value: "2082-02-10" %>
```

Without a form builder:

```erb
<%= nepali_date_range_field :event, :start_date, :end_date %>
```

The display shows a friendly range like "Baisakh 15 – Jestha 3, 2082". Opens a single popover with drag-to-select. Fires `miti:range-selected` custom event on selection.

Options: `theme`, `start_value`, `end_value`, `trigger_html`.

### Date select (3 dropdowns)

```erb
<%= form.nepali_date_select :happened_on %>
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
- `event.happened_on = "2083-01-15"` — auto-converts BS string to AD via custom type

#### Optional BS column storage

```ruby
class Event < ApplicationRecord
  include Miti::Rails::ModelConcern
  has_nepali_date :happened_on, store_bs: true
end
```

The setter writes the BS string to the `happened_on_bs` column on assignment. Generate the migration:

```
$ rails generate miti:store_bs Event happened_on
```

With `store_bs: true`:
- `event.happened_on_bs` reads from the DB column directly (zero conversion cost)
- Falls back to converting from AD if the column is empty
- The setter writes the BS string to the column immediately
- If only the BS column is set, it is synced to the AD column in `before_validation`

### Controller concern

Converts BS date params to AD `Date` objects before an action runs. Use it for params that don't go through `has_nepali_date`, such as filters:

```ruby
class EventsController < ApplicationController
  include Miti::Rails::ControllerConcern
  auto_convert_bs_dates :from, :to, only: :index   # params[:from], params[:to] become AD Dates; invalid values are left as-is

  def index
    date = parse_date_param(params[:date])  # BS string -> AD Date, Date.current if blank or invalid
  end
end
```

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
