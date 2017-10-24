#Class for client-server/server-client actions

require './encryption'

class Connection
  attr_accessor :tekst

  def testNew
    puts "Elocha"
  end

  def testNewer

    testowy = Encryption.new
    testowy2 = Encryption.new

    puts "C'mon write something, nigga: "
     x = $stdin.gets
    puts "Plain text: "
    print x
    #y = x.twofishEncrypt
    puts "Encrypted text: "
    y = testowy.caesar_cipher(x, 3)
    z = y * ""
    puts z
    #z = y.twofishDecrypt
    puts "After decryption: "
    h = testowy2.caesar_cipher2(z, -3)
    i = h * ""
    puts i #z
  end

end
