## [1.1.0] - 2025-01-01

- Fix bug in `parse_nepali_date` where passing a `Miti::NepaliDate` object raised an error
- Fix stray closing brace in `descriptive(nepali: true)` output
- Add comprehensive test coverage for `BsToAd`, `NepaliDate`, and integration specs
- Bump minimum Ruby version to 3.0
- Update CI to test against Ruby 3.0–3.4 and use actions/checkout@v4
- Update Rubocop config (target 3.0, correct date_data path, relaxed MethodLength)

## [0.0.1] - 2022-09-24

- Initial release

## [0.1.0] - 2023-05-21
- Change Class method to constant for fetching date. Add corresponding date for Baisakh 1 and Jan 1.
- Simplify logic for AD to BS conversion
- Refactor and add comments

## [1.0.0] - 2023-06-27
- New release 1.0.0
- Integrate Miti CLI
- Miti CLI now accepts arguments for date conversion

## [1.0.1] - 2023-07-01
- add gem dependency thor
- Update documentation for CLI app usage and readme.md
