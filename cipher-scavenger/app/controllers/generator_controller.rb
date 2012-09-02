class GeneratorController < ApplicationController
	
	def self.initialize_database
		name = "Ramrod"
		decoded1 = "Test with a period."
		decoded2 = "Woah a QR code on a phone"
		encoded = ""
		parity = ""
		level = rand(3) + 1
		pin = rand(8999) + 1000

		encoded = encode_level1(decoded1)
		puts "Decoded " + decoded1 + " Encoded " + encoded + " parity " + parity

		encoded = encode_level2(decoded1)
		puts "Decoded " + decoded1 + " Encoded " + encoded + " parity " + parity

		encoded = decoded2
		parity = encode_level3(decoded1, decoded2)
		puts "Decoded " + decoded1 + " Encoded " + encoded + " parity " + parity

	end

	private 

	def self.encode_level1(string)
		encoded = ""
		string.split("").each do |char|
			encoded += char + "."
		end

		return encoded
	end

	def self.encode_level2(string)
		return Base64.encode64(string)
	end

	def self.encode_level3(string1, string2)
		encoded = ""
		string1.each_byte.zip(string2.each_byte).each do |c1, c2|
			c1 = 0 if c1.nil?
			c2 = 0 if c2.nil?

			encoded += (c1 ^ c2).chr
		end

		return Base64.encode64(encoded)
	end

end