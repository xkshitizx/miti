## Rails Integration

Miti provides helpers, controllers, and assets for using Nepali dates in Rails applications.

### Setup

Run the installer generator:

    $ rails generate miti:install

The generator auto-detects your JavaScript setup:

- **Importmap** (default Rails 7+): pins `miti/converter` and `miti/date_picker_controller` in `config/importmap.rb`
- **esbuild / webpack / other bundler** (no `config/importmap.rb`): copies the JS files into `app/javascript/miti/` so your bundler can resolve them

To force file copy even with importmap (e.g., to customize the JS):

    $ rails generate miti:install --copy-javascript

To customize the calendar styles, copy them into your app:

    $ rails generate miti:install --copy-styles

To undo everything:

    $ rails destroy miti:install

### Date picker field

```erb
<%= form.nepali_date_field :happened_on_bs %>
<!-- Renders a readonly text input with a calendar icon that opens a popover -->
```

With a default value:

```erb
<%= form.nepali_date_field :happened_on_bs, value: "2082-01-15" %>
<%= form.nepali_date_field :happened_on_bs, value: @event.happened_on_bs %>
```

Without a form builder:

```erb
<%= nepali_date_field :event, :happened_on_bs %>
```

### Date select (3 dropdowns)

```erb
<%= form.nepali_date_select :happened_on_bs %>
```

### Model concern

```ruby
class Event < ApplicationRecord
  include Miti::Rails::ModelConcern
  has_nepali_date :happened_on
end
```

This defines:
- `event.happened_on_bs` — returns the date as a `Miti::NepaliDate`
- `event.happened_on_bs = "2082-01-15"` — sets the AD column from a BS string
- `event.happened_on_bs_human` — returns a readable description (respects `I18n.locale`)

### Calendar

Renders a monthly grid table with navigation links. Navigation uses Turbo Frames by default — prev/next links update `?bs_year=` and `?bs_month=` query params, and the helper reads them to determine the displayed month.

```erb
<%# Current BS month (no arguments) %>
<%= nepali_calendar %>

<%# Specific month with block for custom day content %>
<%= nepali_calendar(year: 2082, month: 1) do |day| %>
  <%= day.gatey %>
<% end %>
```

The title shows the Nepali month name followed by the corresponding English month abbreviation in brackets, e.g. **Baisakh *(Apr-May)* 2083**.

Options:

| Option | Default | Description |
|--------|---------|-------------|
| `year` | current BS year | |
| `month` | current BS month | |
| `turbo_frame` | `"nepali_calendar"` | Turbo Frame ID; pass `nil` to disable frame wrapping |
| `html` | `{}` | Custom HTML attributes merged onto the `<table>` |
| `today` | `Date.today` | Override the "today" reference date |

### Agenda view

```erb
<%= nepali_calendar_agenda(start_date, end_date, group_by: :week) do |day| %>
  <%= day.descriptive %>
<% end %>
```

Renders a grouped list of dates with headers.

### Date picker data

If you need the BS calendar data in your own JavaScript:

```erb
<%= include_miti_date_picker_data %>
```

This injects a `<script id="miti-calendar-data">` tag with all month/year data used by the JS converter.

### DayPresenter

Yielded to calendar and agenda blocks:

| Method | Returns |
|--------|---------|
| `day.gatey` | Day of month (1-32) |
| `day.barsa` | Year |
| `day.mahina` | Month (1-12) |
| `day.bar` | Weekday index (0=Sunday) |
| `day.tarik` | Equivalent AD Date |
| `day.ad_date` | Alias for `tarik` |
| `day.to_ad` | Alias for `tarik` |
| `day.to_s` | BS date as `yyyy-mm-dd` |
| `day.to_param` | BS date string |
| `day.descriptive` | Human readable (e.g. "Baisakh 15, 2082 Sunday") |
| `day.today?` | Is today? |
| `day.sunday?` | Is Sunday? |
| `day.saturday?` | Is Saturday? |

### Ruby version

Miti supports Ruby 3.1 through 4.x. Rails integration requires `actionview`, `activerecord`, and `railties` (loaded automatically in a Rails app).
