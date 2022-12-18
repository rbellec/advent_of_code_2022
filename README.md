# advent_of_code_2022

# Why a rails application ?
I decided this year to focus on using a set of tool I know and use on a daily basis to focus
on problems (yes, my psy already told me that I focus too much on problems !).

Since I work with Ruby on Rails on a daily basis, I decided to use a full rails app, generators, ActiveSupport...
even if I do not use any of RoR features. Extinguish candle with a shovel may be overkill, but it works and... I had a shovel.

# How to use

Every day has a class with its own methods. Data files are loaded automatically from the `problems_data` directory.
Note that they must be named properly like `data_day_18_1.txt`. Considering you already have installed gems (`bundle install`), this is how you can run day 18:

```sh
# Generate empty data file you can populate with your problem input data
$ rails generate day 18

# Open rails console
$ bundle exec rails console

# Resolve first part with demo data
> Day18.call(1)

# Resolve first part with your personal input from data_day_18_1.txt file
> Day18.call(1, true)

# Same for secont part, with example:
> Day18.call(2)

# And with your personal input from data_day_18_1.txt file
> Day18.call(2, true)

```

# Current status
Note that before Day18 I did not think of sharing this code, you may need to read a bit the code to see how you can
call the correct problem. Ask if you need anything, I am happy to answer and share !

Current status (Day 18):

- There is a solution for every problem except Day17 (I did not look a it yet).
- Solution to Day 16 part 2 works but will last hours. (I let it run for curiosity but had the solution trying set partitionning in console). It found the solution after ~20h but I did not let if run more.
- Some algo may not be the "proper form". Part of the fun for me is to not look for existing algos and try to redo
them. I used multiple Dijkstra algorithm in day 16 because I forgot how to do Floyd–Warshall (and I set up a time span to avoid spending too long on AoC).
- I am interested in reworking Day 16 with an A* search and day 15 too see how I could solve the linear problem instead of
iterating over solution space.
- You can find a visualization of day 10 in lib (or in its own repository https://github.com/rbellec/aoc2022_elve_terminal_emulator). It was fun but it definitely exceeds the time I have for AoC :)


