#!/usr/bin/env ruby
# encoding: utf-8

require 'net/http'
require 'uri'
#require 'sqlite3'
require 'json'

class String

	def getValue(begins, end_)
		si = 0
		ei = 0
		begins.each {|b|
			si = self.index(b, si)
			return nil if si == nil
			si += b.length
		}
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



#		out = out.gsub /&#(8192|8193|8194|8195|8196|8197|8198|8199|8200);/, ' '
#		out = out.gsub /&#[0-9]{1,4};/, ''
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
	elsif mon.index('září') != nil then return 9
	elsif mon.index('říj') != nil then return 10
	elsif mon.index('list') != nil then return 11
	elsif mon.index('pros') != nil then return 12
	end
	throw :badMonthException
end


###

tm = Time.now
events = [ ]

0.upto(3) {|i|

	src = Net::HTTP.get(URI('http://www.hvezdarna.cz/?page_id=442&cal_page='+i.to_s)).force_encoding('UTF-8')
	src = src.getValue(['<div id="cal-main">'], '<a name=priklad></a>')
	src = src.gsub(' cal-day-last','')

	days = src.split('<div class="cal-day"')
	days.each {|d|

		day_name = d.getValue(['cal-day-title','<h3>'], '</h3')
		next if day_name == nil

		day = day_name.to_i
		month = month_to_number(day_name)
		year = tm.year
		year+=1 if month < tm.month
		day = Time.new(year, month, day)

		programs = d.split('<div class="cal-day-item-desc-outer"')
		programs.each {|p|

			name = p.getValue(['cal-title-','<h5>'], '</h5')
			next if name == nil
			next if p.index('cal-day-item-gray') != nil
			e = { }
			e['name'] = name.strip
			e['price'] = p.getValue(['cal-day-price', '>', 'cena: '], '</div')
			e['time'] = p.getValue(['<h4>'], '</h4').split(':')
			e['time'] = Time.at(day.to_i + e['time'][0].to_i*60*60 + e['time'][1].to_i*60).to_i
			e['short_desc'] = p.getValue(['cal-day-desc','>'], '</div')
			e['desc'] = p.getValue(['cal-day-item-desc-inner','>','>'], /(<div|<\/div)/)
			e['short_desc'] = e['short_desc'].removeHTML.removeEntities if e['short_desc']
			e['desc'] = e['desc'].removeHTML.removeEntities if e['desc']

			while e['short_desc'][-1] == "\n" || e['short_desc'][-1] == "\r"
				e['short_desc'] = e['short_desc'][0..-2]
			end

			while e['desc'][-1] == "\n" || e['desc'][-1] == "\r"
				e['desc'] = e['desc'][0..-2]
			end

			e['short_desc'].strip!
			e['desc'].strip!

			link = nil
			programID = p.getValue(['<a href="', 'prdID='], '"')
			link = 'http://vstupenky.hvezdarna.cz/incoming.aspx?mrsid=2&eventid='+ programID if programID != nil
			e['link'] = link

			e['options'] = p.getValue(['<P','align=right>'],'</div')
			if (e['options'])
				e['options'] = e['options'].split('<br>')
				e['options'].map! {|opt| opt.strip}
#				e['options'] = e['options'].join('|')
			end
			events << e
		}

	}

}

if events.count then
=begin
	db = SQLite3::Database.open('db.sqlite')

	begin
		db.execute('SELECT * FROM events;')
	rescue
		db.execute('CREATE TABLE events (id integer NOT NULL PRIMARY KEY AUTOINCREMENT,name text NOT NULL,"time" int NOT NULL,"short_desc" text,"desc" text,opts text,price text,link text)')
	end

	db.transaction
	db.execute('DELETE FROM events;')
	events.each {|e|
		db.execute('INSERT INTO events VALUES(NULL, ?, ?, ?, ?, ?, ?, ?);', e.name, e.time, e.short_desc, e.desc, e.options, e.price, e.link) }
	db.commit
=end

	File.open('program.json', 'w') {}
	f = File.open('program.json','w')
	f << '{"events":' + events.to_json + '}'
	f.close

end
