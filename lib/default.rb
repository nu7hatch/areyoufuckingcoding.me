# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.

$stdout.sync = true

require 'time'

include Nanoc3::Helpers::Rendering
include Nanoc3::Helpers::Blogging
include Nanoc3::Helpers::HTMLEscape

# Custom extensions...

module DateFormatters
  def format_as_date
    %[#{Date::MONTHNAMES[self.mon]} #{self.mday.to_i}, #{self.year}]
  end

  def format_as_date_id
    "#{self.year}-#{self.mon}-#{self.mday}"
  end
end

module StringExt
  def to_localtime
    Time.parse(self).localtime
  end
end

module ItemExt
  def blogpost_id
    [ self[:created_at].to_localtime.format_as_date_id,
      self[:title].downcase
    ].join(" ").
      gsub(/[^\d\w\-\_\s]+/, '').
      gsub(/[\s\-]/, '_')
  end
end

class Date
  include DateFormatters
end

class Time
  include DateFormatters
end

class String
  include StringExt
end

class Nanoc3::Item
  include ItemExt
end

# Extra configuration...

$GOOGLE_ANALYTICS_UID = "UA-28812082-1"
