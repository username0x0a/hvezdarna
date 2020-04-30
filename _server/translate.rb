#!/usr/bin/env ruby
# encoding: utf-8

require 'net/https'
require 'uri'
require 'json'

exit if !File.exists? 'program.json'

begin

	e = `cat program.json`
	e = JSON.parse e
	e = e['events']
	voc = { }

	e.each{|i|

		voc[i['name']] = 1 if i['name'].is_a?(String) && i['name'].length > 0
		voc[i['short_desc']] = 1 if i['short_desc'].is_a?(String) && i['short_desc'].length > 0
		voc[i['desc']] = 1 if i['desc'].is_a?(String) && i['desc'].length > 0

		if i['options'].is_a?(Array) then
			i['options'].each{|o| voc[o] = 1 if o.is_a?(String) && o.length > 0 }
		end
	}

	voc.keys.each{|key|

		encoded = URI.encode key
		uri = URI('https://translate.google.com/translate_a/single?client=gtx&sl=cs&tl=en&hl=en&dt=at&dt=bd&dt=ex&dt=ld&dt=md&dt=qca&dt=rw&dt=rm&dt=ss&dt=t&ie=UTF-8&oe=UTF-8&source=btn&ssel=3&tsel=0&kc=2&q='+encoded)
		req = Net::HTTP::Get.new uri.request_uri
		req.add_field 'Accept', 'application/json'
		http = Net::HTTP.new uri.hostname, uri.port
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		res = http.request req
#		raise StandardError, res.body if res.code.to_i != 200
		next if res.code.to_i != 200
		translated = JSON.parse res.body
		translated = translated[0].map{|e| e[0] }.join
		voc[key] = translated if translated.is_a? String
	}

	e.each{|i|

		i['name'] = voc[i['name']] if i['name'].is_a?(String) && voc[i['name']].is_a?(String)
		i['short_desc'] = voc[i['short_desc']] if i['short_desc'].is_a?(String) && voc[i['short_desc']].is_a?(String)
		i['desc'] = voc[i['desc']] if i['desc'].is_a?(String) && voc[i['desc']].is_a?(String)

		i['options'].map! {|e| voc[e].is_a?(String) ? voc[e] : e; } if i['options'].is_a?(Array)
	}

	if e.count then
		File.open('program-english.json', 'w') {}
		f = File.open('program-english.json','w')
		f << '{"events":' + e.to_json + '}'
		f.close
	end

#rescue

#	exit

end
