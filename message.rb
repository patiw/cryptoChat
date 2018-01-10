##############
# message.rb #
##############
# Require the encryption.rb file for de/encrypt text
require './encryption'
require './key'
gem 'pg'
require 'pg'

# Patch for String class
class String
  # Switch end lines
   def changeEndLines
     self.gsub("\n", '\n')
   end

   #Recovers end lines from decrypted message
    def recoverEndLines
      self.gsub('\n', "\n")
    end
end

# Message module responsible for coresponding with files, database
module Message
  ####################################################
  # To delete later, replace with database ~ Patryk
  def checkIfFileExist
    # Search for file in folder
    if File.exist?('message') == false
      # Make file if there isn't one
      file = File.open('message', 'wb+')
      file.close
    end
  end
  ####################################################

  def refreshTextBox(box)
    # Open file in binary mode
    db = PG.connect(
      dbname: 'cryptochat',
      user: 'cryptochat',
      password: 'haslo'
    )
    stringText = db.exec 'SELECT * FROM chatmessages WHERE (id > ((SELECT max(id) FROM chatmessages) - 15))'
    stringText = stringText.field_values('text').join('')
    db.close
    # stringText = File.binread('message')
    # Don't go to next step if file is empty
    return if stringText == ''
    # Unpack the binary string
    # puts stringText.to_s
    # stringText = stringText.unpack('B*')[0]
    # stringText = stringText.to_s(2)
    # puts stringText
    # Scan the history to 64 bits blocks = 8 chars
    stringText = stringText.scan(/.{1,64}/)
    # Decrypt whole convo-story
    textHistory = CipherMessage::decode(stringText).recoverEndLines
    # Refresh the box with current history
    box.setText(textHistory)
  end

  def sendTextBox(box, adres)
    # Convert end lines "\n" and add extra one at the end
    sendMessage = box.toPlainText.changeEndLines
    sendMessage << '\n'
    # Send text to encryption method
    sendMessage = CipherMessage::init(sendMessage)
    # Join the array to string
    sendMessage = sendMessage.join
    # Fix it to string without SPACE char
    sendMessage.delete!(' ') # you can use .gsub(" ", "")
    # later we'll move this to connection.rb
    time = DateTime.now
    time = time.strftime('%Y-%m-%dT%H:%M:%S')
    url = "http://138.68.173.185/cryptochat/product/addmessage.php?sender=9&receiver=9&text=#{sendMessage}&date=#{time}"
    RestClient.post(url, " ")
    ###
    db = PG.connect(
      dbname: 'cryptochat',
      user: 'cryptochat',
      password: 'haslo'
    )
      db.exec("INSERT INTO chatMessages(sender,receiver,date,text) VALUES ($1, $2, $3, $4)", [1, 2, Time.now, sendMessage])
    db.close
    # File.open(adres, 'ab+') do |output|
    #  output.write [sendMessage].pack('B*')
    # end
    box.clear
  end

  def deleteContent(box, adres)
    file = File.open(adres, 'ab+')
    file.truncate(0)
    file.close
    db = PG.connect(
      dbname: 'cryptochat',
      user: 'cryptochat',
      password: 'haslo'
    )
      db.exec("DELETE FROM chatMessages")
      db.exec("ALTER SEQUENCE chatMessages_id_seq RESTART WITH 1")
    db.close
    box.clear
  end

  module_function :refreshTextBox, :sendTextBox, :deleteContent, :checkIfFileExist
end

# Module for message transform
module CipherMessage
#  @key = GenerateKey::genkey
  @key = '01101010 01101010 01101010 01101010 01101010 01101010 01101010 01101010
          01101010 01101010 01101010 01101010 01101010 01101010 01101010 01101010'
  # Initialize Encryption method for input
  def init(text)
    # Map text into 8 char blocks
    text = mapText(text)
    # Encrypt given text
    cipherMessage = []
    text.each do |block|
      message1 = Encryption.new(block, @key)
      x1 = message1.tripledes_encrypt
      cipherMessage << x1.blocks(8) # .to_text
    end
    cipherMessage
  end

  # Mapping text into 8 chars blocks
  def mapText(text)
    text = text.scan(/.{1,8}/)
    # Fix sizes of blocks with less than 8 chars
    text.each do |block|
      if block.size < 8
        (8-block.size).times do
          # Add chars to satisfy 8char block
          block << " " # DO NOT EDIT " "
        end
      end
    end
    text
  end

  # Decode history of conversation
  def decode(sText)
    decryptMessage = ''
    sText.each do |block|
      message2 = Encryption.new(block.to_bits, @key)
      x2 = message2.tripledes_decrypt
      # Convert from 1010 string to ASCII string form
      x2 = x2.blocks(8).to_text
      # Fix the text to readable form
      x2.delete!(" ") # .gsub!(" ", "") # DO NOT EDIT " "
      # Add the decrypted block to final message
      decryptMessage << x2
    end
    decryptMessage
  end

  module_function :init, :mapText, :decode
end
