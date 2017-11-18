##############
# message.rb #
##############
# Require the encryption.rb file for de/encrypt text
require './encryption'
require './key'

# Message module responsible for coresponding with files, database
module Message
  def refreshTextBox(box)
    stringText = File.read('message')
    # puts stringText
    stringText = stringText.encode('UTF-8', :invalid => :replace)
    stringText = stringText.scan(/.{1,8}/)
    textHistory = CipherMessage::decode(stringText)
    box.setText(textHistory)
  end

  def sendTextBox(box, adres)
    file = File.open(adres, 'a+')
    sendMessage = box.toPlainText
    sendMessage = CipherMessage::init(sendMessage)
    sendMessage = sendMessage.force_encoding('UTF-8')
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
      #puts x1.blocks(8).to_text
      cipherMessage << x1.blocks(8).to_text
    end
    #puts @key
    return cipherMessage
  end

  def mapText
    @text = @text.scan(/.{1,8}/)
    # Fix sizes of blocks with less than 8 chars
    @text.each do |block|
      if block.size < 8
        (8-block.size).times do
          # Add spaces yo make block 8 chars
          block << "*"
          #puts block
        end
      end
    end
  end

  def decode(sText)
    decryptMessage = ""
    sText.each do |block|
      # puts block
      code = block.to_bytes.to_bits
      # puts code
      message1 = Encryption.new(code, @key)
      x1 = message1.tripledes_decrypt
      # puts x1
      decryptMessage << x1.force_encoding('UTF-8')
    end
    return decryptMessage
  end

  module_function :init, :mapText, :decode
end
