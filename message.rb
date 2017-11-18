##############
# message.rb #
##############
# Require the encryption.rb file for de/encrypt text
require './encryption'

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

  module_function :refreshTextBox, :sendTextBox
end

# Module for message transform
module CipherMessage
  def init(text)
    @text = text
    # Map text into 8 char blocks
    mapText
    # Generate key, make it somewhere else
    # So it can be called during life of app
    # Without changes
    a = XorshiftGen.new
    key = a.bytes(32).scan(/......../)
    key = key*" "
    # Encrypt given text
    cipherMessage = ""
    @text.each do |block|
      message1 = Encryption.new(block, key)
      x1 = message1.tripledes_encrypt
      puts x1.blocks(8).to_text
      cipherMessage << x1.blocks(8).to_text
    end
    puts cipherMessage
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
