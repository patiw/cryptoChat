#Test of Qt-lib

#Requested gems and files
  require 'Qt4'
  require './connection'
  require './encryption'
  require './message'
  require './user'
  #in future classes gonna be pushed outside and linked here
  #awaiting for Patryk to decide on server choice

#"main"
  if __FILE__ == $0

    #key must be entered before the message process
    #suggestion: make the key generator and loading in other place
    key = '00000000 00100010 00111111 01011100 01010101 01100110 01110111 10001001
           10000111 10011000 01111001 01000101 00110101 00100001 00110101 01000100'

    loop do
        puts "Write something: (type qqqqq to exit)"
        x = $stdin.gets.chomp

        break if x == "qqqqq"

        puts "Encrypted text: "
        #make class with initial varaibles of message and key
        message1 = Encryption.new(x, key)
        #x1 is the output of 3DES encrypt witch is an array
        x1 = message1.tripledes_encrypt
        #format the array to readable form
        puts x1.blocks(8).to_text

        puts "After decryption: "
        #make class with initial varaibles of message and key
        message2 = Encryption.new(x1, key)
        #x2 is the output of 3DES decrypt witch is an array
        x2 = message2.tripledes_decrypt
        #format the array to readable form
        puts x2.blocks(8).to_text.recover_end_lines

        ###TO DO: make x1 a string and encrypt the string, not an array

    end

    class QtApp < Qt::Widget

        def initialize
            super

            setWindowTitle "cryptoChat preAlpha-Omega v0.0.0.1"

            setToolTip "Test"

            resize 450, 600
            move 300, 300

            show
        end
    end

    app = Qt::Application.new ARGV
    QtApp.new
  #  app.exec

  end
