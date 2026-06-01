
A **Miti::NepaliDate** (nepali miti) object is created with **Miti.to_bs**, while **Date**(english date) object is created with **Miti.to_ad**

#### ***(Note: All the date argument must be provided in YYYY/MM/DD OR YYYY-MM-DD format)***

```ruby
require 'miti'

Miti.to_bs("2022/10/12") # args can also be sent as "2022-12-12"
  #=> #<Miti::NepaliDate:0x00007fec31b93ac8 @barsa=2079, @gatey=26, @mahina=6>

Miti.to_bs("2022/10/12").descriptive
  #=> "Asoj 26, 2079 Wednesday"

Miti.to_bs("2022/10/12").descriptive(nepali: true)
  #=> "आश्विन 27, 2079 Thursday(बिहिबार)"

Miti.to_bs("2022/10/12").tarik
  #=> #<Date: 2022-10-12 ((2459865j,0s,0n),+0s,2299161j)>

Miti.to_bs("2022/10/12").to_h
  #=> {:barsa=>2079, :mahina=>6, :gatey=>26, :bar=>3, :tarik=>#<Date: 2022-10-12 ((2459865j,0s,0n),+0s,2299161j)>}

Miti.to_bs("2022/10/12").to_s
  #=> "2079-06-26"

Miti.to_bs("2022/10/12").to_s(separator: "/") # separator can be [" ", "/"]
  #=> "2079/06/26" when (separator: "/")
  #=> "2079 06 26" when (separator: " ")

Miti.to_ad("2079/06/26")
  #=> #<Date: 2022-10-12 ((2459865j,0s,0n),+0s,2299161j)>
```

## Rails

### Custom ActiveRecord type (auto-loaded in Rails apps)

Miti registers a `:miti_nepali_date` type that auto-converts BS strings to AD dates when assigned to a column:

```ruby
class Event < ApplicationRecord
  include Miti::Rails::ModelConcern
  has_nepali_date :happened_on
  # This registers: attribute :happened_on, :miti_nepali_date
end

event = Event.new(happened_on: "2082-01-15")
event.happened_on # => #<Date: 2025-04-28> (auto-converted)
```

This means form fields using `nepali_date_field :happened_on` submit BS strings directly to the AD column. No `_bs` suffix needed in strong params — just permit `:happened_on`.

### store_bs: true

```ruby
has_nepali_date :happened_on, store_bs: true
```

Syncs the BS date to a `happened_on_bs` column on save (requires DB column). The `_bs` getter reads from the column directly for fast access, falling back to conversion from AD if empty.

Generate the migration:

    $ rails generate miti:store_bs Event happened_on
