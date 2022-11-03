#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'
require 'net/http'
require 'uri'
require 'json'
require 'pp'

ENV['TZ'] = 'Europe/Prague'

FileUtils.cd File.dirname File.realpath File.expand_path __FILE__

class String

	def getValue(begins, end_)
		si = 0
		ei = 0
		begins.each {|b|
			si = self.index(b, si)
			return nil if si == nil
			si += b.length
		}
		return self[si..] if end_ == nil
		ei = self.index(end_, si)
		return nil if ei == nil
		ei -= 1
		return self[si..ei]
	end

	def removeHTML
		out = self
		out = out.gsub /<[^>]+>/, ''
		return out
	end

	def removeEntities
		out = self
		occurrences = out.scan(/&#[0-9]{1,4};/).uniq
		occurrences.each{|o|
			n = o.sub('&#','').to_i
			s = '%4.4x' % n
			c = [s.to_i(16)].pack('U')
			out = out.gsub o, c
		}
		# out = out.gsub /&#(8192|8193|8194|8195|8196|8197|8198|8199|8200);/, ' '
		# out = out.gsub /&#[0-9]{1,4};/, ''
		out = out.gsub '&nbsp;', ' '
		return out
	end

	def clearParagraphs
		out = self.clone
		out = out.gsub "\r", ''
		out = out.gsub "\t", ''
		out = out.split "\n"
		out.map!{|e| e.strip }
		out.select!{|e| e.length > 0 }
		out = out.join "\n\n"
		return out
	end

end

def month_to_number(mon)
	if    mon.index('led') != nil then return 1
	elsif mon.index('únor') != nil then return 2
	elsif mon.index('břez') != nil then return 3
	elsif mon.index('dub') != nil then return 4
	elsif mon.index('květ') != nil then return 5
	elsif mon.index('července') != nil || mon.index('červenec') != nil then return 7
	elsif mon.index('červ') != nil then return 6
	elsif mon.index('srp') != nil then return 8
	elsif mon.index('zář') != nil then return 9
	elsif mon.index('říj') != nil then return 10
	elsif mon.index('list') != nil then return 11
	elsif mon.index('pros') != nil then return 12
	end
	throw :badMonthException
end

def string_difference_percent(a, b)
	longer = [a.size, b.size].max
	same = a.each_char.zip(b.each_char).count { |a,b| a == b }
	(longer - same) / a.size.to_f
end


###

tm = Time.now
events = [ ]

src = Net::HTTP.get(URI('https://www.hvezdarna.cz/?type=verejnost')).force_encoding('UTF-8')
src = src.getValue(['id="main-program-content"', '</h1'], '<!-- main-program-content -->')

programs = src.split('<!-- main-program-porad -->')
programs.each {|p|

	name = p.getValue(['<h3', '"main-program-title"', '>'], '</h3')
	next if name == nil
	name = name.removeHTML.removeEntities.strip

	detail = p.match(/https:\/\/.*?hvezdarna.cz\/porad\/.*?"/)
	detail = detail[0] if detail != nil

	desc = nil
	price = nil

	if detail

	end

	shortDesc = p.getValue(['class="main-program-desc"', '<p>'], '</p')
	if shortDesc != nil then
		shortDesc = shortDesc.removeHTML.removeEntities
		if shortDesc.index('ZRUŠENO') != nil then
			shortDesc = shortDesc.gsub('ZRUŠENO', '')
			shortDesc = "ZRUŠENO\n\n" + shortDesc
		end
		shortDesc = shortDesc.clearParagraphs
	end

	options = p.getValue(['class="main-program-desc"'], '-->')
	options = options.split('<div class')
	options = options.map {|option|
		next nil if option.index('"main-program-tecky"') == nil
		option = option.getValue(['"main-program-tecky"', '>'], '<')
		next nil if option == nil || option.length == 0
		option
	} || []
	options = options.compact

	date_links = {}

	dates = p.getValue(['class="main-program-terminy"', '>'], nil)
	dates = dates.split('<a ')
	dates.each {|date|
		next if date.index('href=') == nil
		link = date.getValue(['href=', '"'], '"')
		link = nil if link.start_with?('https') == false
		date = date.getValue(['href=', '>'], '</a')
		next if date == nil
		time = date.getValue(['</strong', '>'], nil)
		next if time == nil
		date = date.getValue(['<strong', '>'], '</strong').strip
		next if time == nil
		date = date.strip.split('.').map{|n|
			n = n.strip
			n.to_i < 10 && n.length < 2 ? "0#{n}" : n
		}.reverse.join('-')
		time = time.strip.split(':').map{|n|
			n = n.strip
			n.to_i < 10 && n.length < 2 ? "0#{n}" : n
		}.join(':')
		date_links["#{date}T#{time}"] = link
	}

	# # Letní kino special
	# if p.index('Letní kino')
	# 	movieName = p.getValue(['"cal-day-desc"','<br>'], "\n")
	# 	if movieName != nil
	# 		movieName = movieName.strip
	# 		name = name + ": " + movieName
	# 		shortDesc = shortDesc.gsub movieName, ''
	# 	end
	# end

	date_links.keys.each{|datetime|
		y, m, d, h, s = datetime.split(/[-T:]/).map{|i|i.to_i}
		time = Time.new y, m, d, h, s

		e = { }
		e['name'] = name
		e['price'] = price
		e['time'] = time.to_i
		e['desc'] = desc
		e['short_desc'] = shortDesc
		e['link'] = date_links[datetime]
		e['options'] = options

		events << e
	}
}

events = events.sort_by {|a| a['time'] }

if events.count then

	events = events.to_json
	events.gsub! "\\r\\n", "\\n"

	File.open('program.json', 'w') {}
	f = File.open('program.json','w')
	f << '{"events":' + events + '}'
	f.close

end
