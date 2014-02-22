require 'rubygems'
require 'json'
require 'csv'
require 'fileutils'

OUTPUT_FILE = "data.json"

data = []
schools = {}

CSV.foreach('odd2014-feeder-pattern-enrollment-sy1112.csv', :headers => true, :header_converters => :symbol, :converters => :all) do |row|
  data.push(Hash[row.headers[0..-1].zip(row.fields[0..-1])])
end

school_codes = data.map { |r| r[:school_code] }
school_codes.uniq!.sort!

school_codes.each do |code|
	schools[code] = {}
	rows = data.select { |r| r[:school_code] == code }
	rows.each do |r|
		r[:count] = r[:count] == -1 ? 5 : r[:count]

		case r[:new_school_code]
		when code
			# Do nothing.
		when ''
			if !schools[code]['Other'] then schools[code]['Other'] = 0 end
			schools[code]['Other'] = schools[code]['Other'] + r[:count]
		else
			if !schools[code][r[:new_school_code]] then schools[code][r[:new_school_code]] = 0 end
			schools[code][r[:new_school_code]] = schools[code][r[:new_school_code]] + r[:count]
		end
	end

	schools[code].each do |k, v|
		if v == 5 then
			schools[code][k] = -1
		end
	end
end

File.open(OUTPUT_FILE,"w") do |f|
  f.write(schools.to_json)
end