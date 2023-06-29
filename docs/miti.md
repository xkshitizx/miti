
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
