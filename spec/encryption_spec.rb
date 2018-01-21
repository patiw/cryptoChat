require_relative '../lib/encryption.rb'

describe String do
  context 'to_bits' do
    it 'string to array convert' do
      tester = String.new
      tester = '1010110'
      expect(tester.to_bits).to match_array([1, 0, 1, 0, 1, 1, 0])
    end
  end
end
