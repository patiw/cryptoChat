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
      puts "random key: " << key.to_bytes

      encrypted_ssl = cipher.update(data) + cipher.final
      # convert to our encoding
      encrypted_ssl_convert = encrypted_ssl.to_bytes.to_bits.blocks(8).to_text
      encrypted_ssl_convert = encrypted_ssl_convert[0..15]

      puts "encrypt OpenSSL: \n" << encrypted_ssl_convert

      encrypt_chat = Encryption.new(data, key.to_bytes)
      # puts encrypt_chat.instance_variable_get(:@key)
      key_new = encrypt_chat.instance_variable_get(:@key).to_bits
      key_new = encrypt_chat.expand(key_new)
      encrypted_message_chat = encrypt_chat.des_encrypt(data.to_bytes.to_bits, \
                                                        key_new)
      encrypted_message_chat = encrypted_message_chat.blocks(8).to_text

      puts "encrypt cryptoChat: \n" << encrypted_message_chat

      expect(encrypted_message_chat).to eq(encrypted_ssl_convert)

    end
  end
end
