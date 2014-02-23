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
school_codes = school_codes + data.map { |r| r[:new_school_code] }
school_codes.reject! { |code| code == '' }
school_codes.uniq!.sort!

school_codes.each do |code|
	schools[code] = { :in => {}, :out => {} }
end

school_codes.each do |code|

	rows = data.select { |r| r[:school_code] == code }
	rows.each do |r|
		r[:count] = r[:count] == -1 ? 5 : r[:count]

		case r[:new_school_code]
		when code
			# Do nothing.
		when ''
			# Do nothing.
		else
			if !schools[code][:out][r[:new_school_code]] then
				schools[code][:out][r[:new_school_code]] = 0
			end
			if !schools[r[:new_school_code]][:in][code] then
				schools[r[:new_school_code]][:in][code] = 0
			end
			schools[code][:out][r[:new_school_code]] =
				schools[code][:out][r[:new_school_code]] + r[:count]

			schools[r[:new_school_code]][:in][code] =
				schools[r[:new_school_code]][:in][code] + r[:count]
		end
	end
end

def clean (c)
	a = []
	c.each do |k, v|
		h = {
			:code => k.to_s,
			:n => v
		}

		if h[:n] == 5 then
			h[:n] = -1
		end

		a.push(h)
	end

	return a
end

schools.each do |k, v|
	v[:in] = clean(v[:in])
	v[:out] = clean(v[:out])
end

File.open(OUTPUT_FILE,"w") do |f|
  f.write(schools.to_json)
end