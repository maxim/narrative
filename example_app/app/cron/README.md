# Cron objects

For every cron cadence (i.e. daily at 10am, every 10 minutes, weekly on sunday morning, etc) you:

1. Add a new class into this directory. Name this class after the cadence, so it is clear when it runs.
2. Create a similar-named rake task in cron.rake, which will call the code in this class.
3. Hook up your deployment environments to run those rake tasks at the promised times.

Now all you need to do is keep adding code into these files, and when deployed, it will run at the right times.

## Isolating cron logic

Be mindful of errors. If you want to run 2 or more different jobs at this time, and you don't want an error in the first one to stop the second one, you can wrap each piece of code into an `isolate` block.

```ruby
class DailyAt1000UtcCron < ApplicationCron
  def call
    isolate { do_something }
    isolate { do_something_else }
  end
end
```
