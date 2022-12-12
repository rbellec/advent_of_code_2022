class DayGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def copy_day_file
    day = name.to_i
    new_code_file = "app/daily_problems/day_%02d.rb" % day

    copy_file("day.rb", new_code_file)
    gsub_file(new_code_file, '#DailyClassName', "Day%02d" % day)
    create_file("problems_data/data_day_%02d_1.txt" % day, "")
  end
end
