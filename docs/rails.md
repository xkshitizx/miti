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
<%= form.nepali_date_field :happened_on %>
<!-- Renders a readonly text input with a calendar icon that opens a popover -->
<!-- Submits as event[happened_on] — the custom type auto-converts BS string to AD Date -->
```

With a default value:

```erb
<%= form.nepali_date_field :happened_on, value: "2082-01-15" %>
<%= form.nepali_date_field :happened_on, value: @event.happened_on_bs %>
```

Without a form builder:

```erb
<%= nepali_date_field :event, :happened_on %>
```

#### Themes

```erb
<%= form.nepali_date_field :happened_on, theme: :dark %>
<%= form.nepali_date_field :happened_on, theme: :tokyo_night %>
<!-- Use underscores in Ruby symbols (converted to hyphens in CSS) -->
```

Available themes: `light` (default), `dark`, `indigo`, `midnight`, `tokyo_night`, `nord`.

Use `data-miti-theme` on any ancestor to style a group of pickers.

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

### Date range picker

```erb
<%= form.nepali_date_range_field :start_date, :end_date %>
<!-- Renders a single clickable display input + two hidden inputs for form submission -->
<!-- Selecting a range via drag or click opens a single popover -->
```

With a default value:

```erb
<%= form.nepali_date_range_field :start_date, :end_date,
      start_value: "2082-01-15", end_value: "2082-02-10" %>
```

Without a form builder:

```erb
<%= nepali_date_range_field :event, :start_date, :end_date %>
```

The display shows a human-friendly range like "Baisakh 15 – Jestha 3, 2082". If both dates are in the same month it shortens to "Baisakh 15–28".

**Interaction:** Click or focus the display input to open the popover. Drag across days to select a range, or click once for start then again for end. The range popover re-opens to the start date's month and allows adjusting either endpoint.

A `miti:range-selected` custom event fires on the wrapper element when the range is confirmed:

```javascript
document.querySelector(".miti-date-range-wrapper")
  .addEventListener("miti:range-selected", (e) => {
    console.log(e.detail.startDate, e.detail.endDate)
  })
```

Available options:

| Option | Default | Description |
|--------|---------|-------------|
| `theme` | — | Theme name (`:dark`, `:nord`, etc.) |
| `start_value` | — | Default BS start date string |
| `end_value` | — | Default BS end date string |
| `trigger_html` | `{}` | Extra HTML attributes merged onto the display input (use `data: {}` for Stimulus attrs) |

### Date select (3 dropdowns)

```erb
<%= form.nepali_date_select :happened_on %>
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
- `event.happened_on = "2082-01-15"` — auto-converts BS string to AD via `:miti_nepali_date` type

#### Optional BS column storage

```ruby
class Event < ApplicationRecord
  include Miti::Rails::ModelConcern
  has_nepali_date :happened_on, store_bs: true
end
```

Writes the BS string to the `happened_on_bs` column on assignment. Generate the migration:

```
$ rails generate miti:store_bs Event happened_on
```

With `store_bs: true`:
- `event.happened_on_bs` reads from the DB column directly (zero conversion cost)
- Falls back to converting from AD if the column is empty
- The BS string is written to the column immediately by the setter

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
