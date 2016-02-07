require 'json'

class Emoji

	@@emoji = {}

	@@current_list = "all"

	def self.square(size)
		list = @@emoji[@@current_list]
		square = ""
		(0...(size ** 2)).each do |i|
			square << list.sample
			if ((i + 1) % size) == 0
				square << "\n"
			end
		end
		return square
	end

	def self.choose(list)
		@@current_list = list
	end

	def self.list
		@@emoji.keys
	end

	def self.load(path)
		file = File.read(path)
		@@emoji = JSON.parse(file)
	end

end

# Load emoji sets
Emoji.load('./lib/json/emoji.json')
