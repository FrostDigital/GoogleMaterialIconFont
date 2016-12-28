#!/usr/bin/env ruby

class String 
    def camelize(uppercase_first_letter = true)
      string = self
      if uppercase_first_letter
        string = string.sub(/^[a-z\d]*/) { $&.capitalize }
      else
        string = string.sub(/^(?:(?=\b|[A-Z_])|\w)/) { $&.downcase }
      end
      string.gsub(/(?:_|(\/))([a-z\d]*)/) { "#{$1}#{$2.capitalize}" }.gsub('/', '::')
    end

    def undigitalize(digitalize_only_first_symbol = true)
      string = self
      if digitalize_only_first_symbol
        regex = "^[0-9]"
      else
        regex = "[0-9]"
      end
      string = string.gsub(/#{regex}/, '0' => 'zero_', '1' => 'one_', '2' => 'two_', '3' => 'three_', '4' => 'four_', '5' => 'five_', '6' => 'six_', '7' => 'seven_', '8' => 'eight_', '9' => 'nine_') 
    end
end

codepoints = File.open(File.expand_path('../codepoints.txt', __FILE__), 'r')
outfile = File.expand_path('../../Classes/Font.swift', __FILE__)

names = []
codes = []
codepoints.each_line do |line|
  (name, codepoint) = line.split(/ /)
  name = name.undigitalize.camelize(false)
  names << "case #{name}"
  codes << "\"\\u{#{codepoint.strip}}\""
end

File.open(outfile, 'w') do |file|
  file.puts <<-SWIFT
//
// THIS FILE IS GENERATED, DO NOT MODIFY BY HAND
//
// Use generate.rb to generate when codepoints.txt is updated
//
// Generated on #{Time.now}
//

@objc public enum MaterialIconFont: Int {
    #{names.join("\n    ")}
}

internal struct IconFont {
    static let codes = [
        #{codes.join(', ')}
    ]
}
SWIFT
end
