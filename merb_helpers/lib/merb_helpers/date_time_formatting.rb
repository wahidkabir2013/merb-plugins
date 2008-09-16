module DateAndTimeFormatting
  
  def self.included(base)
    base.class_eval do
      include DateAndTimeFormatting::InstanceMethods
      include OrdinalizedFormatting
      extend DateAndTimeFormatting::ClassMethods
    end
  end
  
  module InstanceMethods
    
    # ==== Parameters
    # format<Symbol>:: of the format key from Date.date_formats
    #
    # ==== Returns
    # String:: formattred string
    def formatted(format = :default)
      self.strftime(Date.formats[format])
    end
  
  end
  
  module ClassMethods
    
    @@formats = {
      :db           => "%Y-%m-%d %H:%M:%S",
      :time         => "%H:%M",
      :short        => "%d %b %H:%M",
      :long         => "%B %d, %Y %H:%M",
      :long_ordinal => lambda { |time| time.strftime("%B #{time.day.ordinalize}, %Y %H:%M") },
      :rfc822       => "%a, %d %b %Y %H:%M:%S %z"
    }
    
    # ==== Returns
    # Hash:: a hash with all formats available
    def formats
      @@formats
    end
    
    # ==== Parameters
    # key<Symbol>:: name of the format
    # format<Hash>:: time format to use
    #
    # ==== Returns
    # Hash:: a hash with all formats available
    def add_format(key, format)
      @@formats.merge!({key => format})
    end
    
    def reset_formats
      original_formats = [:db, :time, :short, :long, :long_ordinal, :rfc822]
      @@formats = @@formats.delete_if{|format, v| !original_formats.include?(format)}
    end

  end
  
end

module Ordinalize
  # Ordinalize turns a number into an ordinal string used to denote the
  # position in an ordered sequence such as 1st, 2nd, 3rd, 4th.
  #
  # Examples
  #   1.ordinalize     # => "1st"
  #   2.ordinalize     # => "2nd"
  #   1002.ordinalize  # => "1002nd"
  #   1003.ordinalize  # => "1003rd"
  def ordinalize
    if (11..13).include?(self % 100)
      "#{self}th"
    else
      case self % 10
        when 1; "#{self}st"
        when 2; "#{self}nd"
        when 3; "#{self}rd"
        else    "#{self}th"
      end
    end
  end
end

Integer.send :include, Ordinalize

# Time.now.to_ordinalized_s :long
# => "February 28th, 2006 21:10"
module OrdinalizedFormatting
  
  def to_ordinalized_s(format = :default)
    format = Date.formats[format] 
    return self.to_s if format.nil?
    strftime_ordinalized(format)
  end

  # Gives you a relative date in an attractive format
  #
  # ==== Parameters
  # format<String>:: strftime string used to formatt a time/date object
  # locale<String, Symbol>:: An optional value which can be used by localization plugins
  #
  # ==== Returns
  # String:: Ordinalized time/date object
  #
  # ==== Examples
  #    5.days.ago.strftime_ordinalized('%b %d, %Y')     # => 
  def strftime_ordinalized(fmt, format=nil)
    strftime(fmt.gsub(/(^|[^-])%d/, '\1_%d_')).gsub(/_(\d+)_/) { |s| s.to_i.ordinalize }
  end
end