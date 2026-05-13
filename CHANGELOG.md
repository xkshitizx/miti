## [Unreleased]

### Rails integration
- Add `Miti::Engine` (Rails Engine) for auto-exposing `app/assets` paths
- Add `nepali_calendar` helper for monthly grid view with Turbo Frame nav
- Add `nepali_calendar_agenda` helper for agenda/list view grouped by week or month
- Add `nepali_date_field` form helper with Stimulus-powered popover date picker
- Add `nepali_date_select` form helper with 3-dropdown BS date selector
- Add `has_nepali_date` model concern for AD↔BS auto-conversion on ActiveRecord attributes
- Add `include_miti_date_picker_data` helper for injecting calendar data into layouts
- Add `Miti::Rails::Calendar::DayPresenter` for calendar/agenda view blocks
- Add `rails generate miti:install` generator (importmap, Stimulus, stylesheets) with `--copy-styles`
- Add Stimulus date picker controller with day/month/year grid views and adaptive positioning
- Add `converter.js` — BS↔AD conversion engine as ES module
- Add calendar.css with theming via CSS custom properties (`--miti-*`)
- Add `value:` parameter support to `nepali_date_field` for default values
- Move controller from input to wrapper for calendar icon button support
- Add hover effects, smaller input sizing, and calendar icon to date field

### Breaking changes
- **Ruby minimum raised to 3.1** (from 3.0)
- Month name constants renamed: `Baishakh` → `Baisakh`, `वैशाख` → `बैशाख`
- Error classes refactored into `Miti::NepaliDate::FormatError`, `Miti::NepaliDate::DateRangeError`
- `to_s` refactored into `Miti::NepaliDate::Formatter`
- `NepaliDate` parsing extracted into `Miti::NepaliDate::Parser`
- Date validation extracted into `Miti::NepaliDate::Validator`
- Date comparison extracted into `Miti::NepaliDate::Comparison`
- Date difference extracted into `Miti::NepaliDate::Difference`

### Dev & CI
- Bump development Ruby to 4.0.3
- Bump `required_ruby_version` to `>= 3.1, < 5.0`
- Update CI to test Ruby 3.1, 3.4, and 4.0
- Update rubocop configurations and fix all offenses

## [1.1.0] - 2025-01-01

- Fix bug in `parse_nepali_date` where passing a `Miti::NepaliDate` object raised an error
- Fix stray closing brace in `descriptive(nepali: true)` output
- Add comprehensive test coverage for `BsToAd`, `NepaliDate`, and integration specs
- Bump minimum Ruby version to 3.0
- Update CI to test against Ruby 3.0–3.4 and use actions/checkout@v4
- Update Rubocop config (target 3.0, correct date_data path, relaxed MethodLength)

## [1.0.1] - 2023-07-01
- add gem dependency thor
- Update documentation for CLI app usage and readme.md

## [1.0.0] - 2023-06-27
- New release 1.0.0
- Integrate Miti CLI
- Miti CLI now accepts arguments for date conversion

## [0.1.0] - 2023-05-21
- Change Class method to constant for fetching date. Add corresponding date for Baisakh 1 and Jan 1.
- Simplify logic for AD to BS conversion
- Refactor and add comments

## [0.0.1] - 2022-09-24

- Initial release
