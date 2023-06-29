
## MITI CLI
Open your terminal or command prompt and run the `miti` command to access the available features.

    $ miti

The MITI CLI app will display the available commands. To execute a specific command, type the command followed by any required arguments.

## Available Commands

#### ***(Note: All the date argument must be provided in YYYY/MM/DD OR YYYY-MM-DD format)***

### **today**

The `today` command displays current day's miti as well as date. To use the `today` command, run the following:

    $ miti today

Output:
```ruby
[2080-03-13 BS] Ashadh 13, 2080 Wednesday
[2023-06-28 AD] June 28, 2023 Wednesday

```
### **to_bs**
The `to_bs` command converts an English date to the Miti (Nepali Date). Takes a argument ***ENGLISH DATE*** for conversion from English Date to Miti.

    $ miti to_bs 2023-06-28


Output:
```ruby
[2080-03-13 BS] Ashadh 13, 2080 Wednesday
```

### **to_ad**

The `to_ad` command converts a Miti to the English date. Takes a argument ***NEPALI MITI*** for conversion from Miti to English Date.

    $ miti to_ad 2080-03-13

Output:
```ruby
[2023-06-28 AD] June 28, 2023 Wednesday
```