##############
# message.rb #
##############
# Require the encryption.rb file for de/encrypt text
require './encryption'
require './key'

# Message module responsible for coresponding with files, database
module Message
  def refreshTextBox(box)
    stringText = File.read('message.txt')
    box.setText(stringText)
  end

  def sendTextBox(box, adres)
    file = File.open(adres, 'a+')
    sendMessage = box.toPlainText
    sendMessage = CipherMessage::init(sendMessage)
    file.puts(sendMessage)
    box.clear
    file.close
  end

  def deleteContent(adres)
    file = File.open(adres, 'a+')
    file.truncate(0)
    file.close
  end

  module_function :refreshTextBox, :sendTextBox, :deleteContent
end

module GenerateKey
  def genkey
    a = XorshiftGen.new
    key = a.bytes(32).scan(/......../)
    key = key*" "
  return key
  end

  module_function :genkey
end

# Module for message transform
module CipherMessage
  @key = GenerateKey::genkey

  def init(text)
    @text = text
    # Map text into 8 char blocks
    mapText
    # Encrypt given text
    cipherMessage = ""
    @text.each do |block|
      message1 = Encryption.new(block, @key)
      x1 = message1.tripledes_encrypt
      puts x1.blocks(8).to_text
      cipherMessage << x1.blocks(8).to_text
    end
    puts @key
    return cipherMessage
  end

  def mapText
    @text = @text.scan(/.{1,8}/)
    # Fix sizes of blocks with less than 8 chars
    @text.each do |block|
      if block.size < 8
        (8-block.size).times do
          # Add spaces yo make block 8 chars
          block << " "
        end
      end
    end
  end

  module_function :init, :mapText
end
