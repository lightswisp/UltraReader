require 'smartcard'

context = Smartcard::PCSC::Context.new()
begin
	readers = context.readers
rescue Smartcard::PCSC::Exception
	puts "No readers!"
	context.release
	exit
end

READER = readers[0]
puts "reader selected: #{READER}"

begin 
	CARD = Smartcard::PCSC::Card.new(context, READER, :exclusive)
rescue Smartcard::PCSC::Exception
	puts "No smartcard detected!"
	exit
end

memory = []

CARD.transaction do |t|
	0.upto(4) do |i|
		p = 4 * i
		cmd = [0x30, p].map{|a| a.chr}.join
		
		response = CARD.transmit(cmd)
		memory << response.unpack("H*")[0].chars.each_slice(8).map(&:join).map{|c|c.upcase}
	end
	memory.flatten!
end

pp memory



context.release
