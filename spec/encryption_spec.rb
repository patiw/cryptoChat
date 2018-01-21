require_relative '../lib/encryption.rb'
require 'openssl'

describe String do
  context 'to_bits' do
    it 'string to array convert' do
      tester = String.new
      tester = '1010110'
      expect(tester.to_bits).to match_array([1, 0, 1, 0, 1, 1, 0])
    end
  end
end

describe Encryption do
  context 'des_encrypt' do
    it 'encrypt like OpenSSL version' do
      data = 'abcdefgh'
      cipher = OpenSSL::Cipher::DES.new
      cipher.encrypt
      key = cipher.random_key
      puts "    random key: " << key.to_bytes

      encrypted_ssl = cipher.update(data) + cipher.final
      # convert to our encoding
      encrypted_ssl_convert = encrypted_ssl.to_bytes.to_bits.blocks(8).to_text
      encrypted_ssl_convert = encrypted_ssl_convert[0..15]

      puts "    encrypt OpenSSL: " << encrypted_ssl_convert

      encrypt_chat = Encryption.new(data, key.to_bytes)
      # puts encrypt_chat.instance_variable_get(:@key)
      key_new = encrypt_chat.instance_variable_get(:@key).to_bits
      key_new = encrypt_chat.expand(key_new)
      encrypted_message_chat = encrypt_chat.des_encrypt(data.to_bytes.to_bits, \
                                                        key_new)
      encrypted_message_chat = encrypted_message_chat.blocks(8).to_text

      puts "    encrypt cryptoChat: " << encrypted_message_chat

      expect(encrypted_message_chat).to eq(encrypted_ssl_convert)
    end
  end

  context 'des_decrypt' do
    it 'decrypt like OpenSSL version' do
      data = 'projekt5'
      cipher = OpenSSL::Cipher::DES.new
      cipher.encrypt
      key = cipher.random_key
      puts "    random key: " << key.to_bytes

      encrypted_ssl = cipher.update(data) + cipher.final
      # convert to our encoding
      encrypted_ssl_convert = encrypted_ssl.to_bytes.to_bits.blocks(8).to_text
      encrypted_ssl_convert = encrypted_ssl_convert[0..15]
      # decrypt the message
      decipher = OpenSSL::Cipher::DES.new
      decipher.decrypt
      decipher.key = key
      plain_text_ssl = decipher.update(encrypted_ssl) + decipher.final

      puts "    encrypt OpenSSL: " << encrypted_ssl_convert
      puts "    decrypt OpenSSL: " << plain_text_ssl

      encrypt_chat = Encryption.new(data, key.to_bytes)
      # puts encrypt_chat.instance_variable_get(:@key)
      key_new = encrypt_chat.instance_variable_get(:@key).to_bits
      key_new = encrypt_chat.expand(key_new)
      encrypted_message_chat = encrypt_chat.des_encrypt(data.to_bytes.to_bits, \
                                                        key_new)
      # decrypt by cryptoChat
      plain_text_chat = encrypt_chat.des_decrypt(encrypted_message_chat, \
                                                 key_new)
      # encrypt formating encode
      encrypted_message_chat = encrypted_message_chat.blocks(8).to_text
      plain_text_chat = plain_text_chat.blocks(8).to_text.delete!(" ")

      puts "    encrypt cryptoChat: " << encrypted_message_chat
      puts "    decrypt cryptoChat: " << plain_text_chat

      expect(plain_text_chat).to eq(plain_text_ssl)
    end
  end
end
