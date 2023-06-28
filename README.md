# Miti 
[![Gem Version](https://badge.fury.io/rb/miti.svg)](https://badge.fury.io/rb/miti)

This gem can help to convert English date to Nepali date and vice-versa.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add miti

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install miti
## Usage

A Miti::NepaliDate(nepali miti) object is created with Miti.to_bs, while Date(english date) object is created with Miti.to_ad
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

## MITI CLI
Open your terminal or command prompt and run the `miti` command to access the available features.
```shell
$ miti
```
The MITI CLI app will display the available commands. To execute a specific command, type the command followed by any required arguments.

## Available Commands

### **today**

The `today` command displays current day's miti as well as date.

To use the `today` command, run the following:

```shell
$ miti today
```

Output:
```ruby
[2080-03-13 BS] Ashadh 13, 2080 Wednesday
[2023-06-28 AD] June 28, 2023 Wednesday

```
### **to_bs**
The `to_bs` command converts an English date to the Miti (Nepali Date). To use the `to_bs` command, run the following:

```shell
$ miti to_bs 2023-06-28
```

Output:
```ruby
[2080-03-13 BS] Ashadh 13, 2080 Wednesday
```

### **to_ad**

The `to_ad` command converts a Miti to the English date. To use the `to_ad` command, run the following:

```shell
$ miti to_ad 2080-03-13
```

Output:
```ruby
[2023-06-28 AD] June 28, 2023 Wednesday
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/xkshitizx/miti. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/xkshitizx/miti/blob/main/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the Miti project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/xkshitizx/miti/blob/main/CODE_OF_CONDUCT.md).
